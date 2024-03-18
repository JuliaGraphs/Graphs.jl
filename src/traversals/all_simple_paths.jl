"""
    all_simple_paths(g, u, v; cutoff=nv(g)) --> Graphs.SimplePathIterator

Returns an iterator that generates all simple paths in the graph `g` from a source vertex
`u` to a target vertex `v` or iterable of target vertices `vs`.

The iterator's elements (i.e., the paths) can be materialized via `collect` or `iterate`.
Paths are iterated in the order of a depth-first search.

## Keyword arguments
The maximum path length (i.e., number of edges) is limited by the keyword argument `cutoff`
(default, `nv(g)`). If a path's path length is greater than or equal to `cutoff`, it is
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
We can restrict the search to paths of length less than a specified cut-off (here, 2 edges):
```jldoctest allsimplepaths; setup = :(using Graphs)
julia> collect(all_simple_paths(g, 1, 4; cutoff=2))
3-element Vector{Vector{Int64}}:
 [1, 2, 4]
 [1, 3, 4]
 [1, 4]
```
"""
function all_simple_paths(
            g::AbstractGraph{T},
            u::T,
            vs;
            cutoff::T=nv(g)
            ) where T <: Integer

    vs = vs isa Set{T} ? vs : Set{T}(vs)
    return SimplePathIterator(g, u, vs, cutoff)
end

"""
    SimplePathIterator{T <: Integer}

Iterator that generates all simple paths in `g` from `u` to `vs` of a length at most
`cutoff`.
"""
struct SimplePathIterator{T <: Integer, G <: AbstractGraph{T}}
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
end
Base.IteratorSize(::Type{<:SimplePathIterator}) = Base.SizeUnknown()
Base.eltype(::SimplePathIterator{T}) where T = Vector{T}

mutable struct SimplePathIteratorState{T <: Integer}
    stack::Stack{Vector{T}} # used to restore iteration of child vertices; each vector has
                            # two elements: a parent vertex and an index of children
    visited::Stack{T}       # current path candidate
    queued::Vector{T}       # remaining targets if path length reached cutoff
end
function SimplePathIteratorState(spi::SimplePathIterator{T}) where T <: Integer
    stack = Stack{Vector{T}}()
    visited = Stack{T}()
    queued = Vector{T}()
    push!(visited, spi.u)    # add a starting vertex to the path candidate
    push!(stack, [spi.u, 1]) # add a child node with index 1
    SimplePathIteratorState{T}(stack, visited, queued)
end

function _stepback!(state::SimplePathIteratorState) # updates iterator state.
    pop!(state.stack)
    pop!(state.visited)
end


"""
    Base.iterate(spi::SimplePathIterator{T}, state=nothing)

Returns the next simple path in `spi`, according to a depth-first search.
"""
function Base.iterate(
            spi::SimplePathIterator{T},
            state::SimplePathIteratorState=SimplePathIteratorState(spi)
            ) where T <: Integer

    while !isempty(state.stack)
        if !isempty(state.queued) # consume queued targets
            target = pop!(state.queued)
            result = vcat(reverse(collect(state.visited)), target)
            if isempty(state.queued)
                _stepback!(state)
            end
            return result, state
        end

        parent_node, next_childe_index = first(state.stack)
        children = outneighbors(spi.g, parent_node)
        if length(children) < next_childe_index
            # all children have been checked, step back.
            _stepback!(state)
            continue
        end

        child = children[next_childe_index]
        first(state.stack)[2] += 1 # move child index forward
        child in state.visited && continue

        if length(state.visited) == spi.cutoff
            # collect adjacent targets if more exist and add them to queue
            rest_children = Set(children[next_childe_index: end])
            state.queued = collect(setdiff(intersect(spi.vs, rest_children), Set(state.visited)))

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
                push!(state.stack, [child, 1]) # add the child node as a parent for next iteration
            else
                pop!(state.visited) # step back and explore the remaining child nodes
            end

            if !isnothing(result) # found a new path, return it
                return result, state
            end
        end
    end
end