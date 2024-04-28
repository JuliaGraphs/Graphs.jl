"""
    all_simple_paths(g, u, v; cutoff)  --> Graphs.SimplePathIterator
    all_simple_paths(g, u, vs; cutoff) --> Graphs.SimplePathIterator

Returns an iterator that generates all 
[simple paths](https://en.wikipedia.org/wiki/Path_(graph_theory)#Walk,_trail,_and_path) in 
the graph `g` from a source vertex `u` to a target vertex `v` or iterable of target vertices
`vs`. A simple path has no repeated vertices.

The iterator's elements (i.e., the paths) can be materialized via `collect` or `iterate`.
Paths are iterated in the order of a depth-first search.

If the requested path has identical source and target vertices, i.e., if `u = v`, a
zero-length path `[u]` is included among the iterates.

## Keyword arguments
The maximum path length (i.e., number of edges) is limited by the keyword argument `cutoff`
(default, `nv(g)-1`). If a path's path length is greater than `cutoff`, it is
omitted.

## Examples
```jldoctest allsimplepaths; setup = :(using Graphs)
julia> g = complete_graph(4);

julia> spi = all_simple_paths(g, 1, 4)
SimplePathIterator{SimpleGraph{Int64}}(1 → 4)

julia> collect(spi)
5-element Vector{Vector{Int64}}:
 [1, 2, 3, 4]
 [1, 2, 4]
 [1, 3, 2, 4]
 [1, 3, 4]
 [1, 4]
```
We can restrict the search to path lengths less than or equal to a specified cut-off (here, 
2 edges):
```jldoctest allsimplepaths; setup = :(using Graphs)
julia> collect(all_simple_paths(g, 1, 4; cutoff=2))
3-element Vector{Vector{Int64}}:
 [1, 2, 4]
 [1, 3, 4]
 [1, 4]
```
"""
function all_simple_paths(
    g::AbstractGraph{T}, u::T, vs; cutoff::T=nv(g) - one(T)
) where {T<:Integer}
    vs = vs isa Set{T} ? vs : Set{T}(vs)
    return SimplePathIterator(g, u, vs, cutoff)
end

# iterator over all simple paths from `u` to `vs` in `g` of length less than `cutoff`
struct SimplePathIterator{T<:Integer,G<:AbstractGraph{T}}
    g::G
    u::T       # start vertex
    vs::Set{T} # target vertices
    cutoff::T  # max length of resulting paths
end

function Base.show(io::IO, spi::SimplePathIterator)
    print(io, "SimplePathIterator{", typeof(spi.g), "}(", spi.u, " → ")
    if length(spi.vs) == 1
        print(io, only(spi.vs))
    else
        print(io, '[')
        join(io, spi.vs, ", ")
        print(io, ']')
    end
    print(io, ')')
    return nothing
end
Base.IteratorSize(::Type{<:SimplePathIterator}) = Base.SizeUnknown()
Base.eltype(::SimplePathIterator{T}) where {T} = Vector{T}

mutable struct SimplePathIteratorState{T<:Integer}
    stack::Stack{Tuple{T,T}} # used to restore iteration of child vertices: elements are ↩
    # (parent vertex, index of children)
    visited::Stack{T}         # current path candidate
    queued::Vector{T}         # remaining targets if path length reached cutoff
    self_visited::Bool        # in case `u ∈ vs`, we want to return a `[u]` path once only
end
function SimplePathIteratorState(spi::SimplePathIterator{T}) where {T<:Integer}
    stack = Stack{Tuple{T,T}}()
    visited = Stack{T}()
    queued = Vector{T}()
    push!(visited, spi.u)    # add a starting vertex to the path candidate
    push!(stack, (spi.u, one(T))) # add a child node with index 1
    return SimplePathIteratorState{T}(stack, visited, queued, false)
end

function _stepback!(state::SimplePathIteratorState) # updates iterator state.
    pop!(state.stack)
    pop!(state.visited)
    return nothing
end

# iterates to the next simple path in `spi`, according to a depth-first search
function Base.iterate(
    spi::SimplePathIterator{T}, state::SimplePathIteratorState=SimplePathIteratorState(spi)
) where {T<:Integer}
    while !isempty(state.stack)
        if !isempty(state.queued) # consume queued targets
            target = pop!(state.queued)
            result = vcat(reverse(collect(state.visited)), target)
            if isempty(state.queued)
                _stepback!(state)
            end
            return result, state
        end

        parent_node, next_child_index = first(state.stack)
        children = outneighbors(spi.g, parent_node)
        if length(children) < next_child_index
            _stepback!(state) # all children have been checked, step back
            continue
        end

        child = children[next_child_index]
        next_child_index_tmp = pop!(state.stack)[2]                      # move child ↩ 
        push!(state.stack, (parent_node, next_child_index_tmp + one(T))) # index forward
        child in state.visited && continue

        if length(state.visited) == spi.cutoff
            # collect adjacent targets if more exist and add them to queue
            rest_children = Set(children[next_child_index:end])
            state.queued = collect(
                setdiff(intersect(spi.vs, rest_children), Set(state.visited))
            )

            if isempty(state.queued)
                _stepback!(state)
            end
        else
            result = if child in spi.vs
                vcat(reverse(collect(state.visited)), child)
            else
                nothing
            end

            # update state variables
            push!(state.visited, child) # move to child vertex
            if !isempty(setdiff(spi.vs, state.visited)) # expand stack until all targets are found
                push!(state.stack, (child, one(T))) # add the child node as a parent for next iteration
            else
                pop!(state.visited) # step back and explore the remaining child nodes
            end

            if !isnothing(result) # found a new path, return it
                return result, state
            end
        end
    end

    # special-case: when `vs` includes `u`, return also a 1-vertex, 0-length path `[u]`
    if spi.u in spi.vs && !state.self_visited
        state.self_visited = true
        return [spi.u], state
    end
end
