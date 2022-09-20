"""
    DFSIterator

`DFSIterator` is a subtype of [`VertexIterator`](@ref) to iterate through graph vertices using a depth-first search. A source node(s) is optionally supplied as an `Int` or an array-like type that can be indexed if supplying multiple sources. If no source is provided, it defaults to the first vertex.
    
# Examples
```julia-repl
julia> g = smallgraph(:house)
{5, 6} undirected simple Int64 graph

julia> for node in DFSIterator(g, 3)
           display(node)
       end
1
2
4
3
5

julia> for node in DFSIterator(g,[1,5])
           display(node)
       end
1
2
4
3
5
5
3
1
2
4
```
"""
struct DFSIterator{S} <: VertexIterator
    graph::AbstractGraph
    source::S
end

DFSIterator(g::AbstractGraph) = DFSIterator(g, one(eltype(g)))


"""
    Base.iterate(t::DFSIterator)

First iteration to visit each vertex in a graph using depth-first search.
"""
function Base.iterate(t::DFSIterator)
    visited = falses(nv(t.graph))
    if t.source isa Number
        visited[t.source] = true
        return (t.source, SingleSourceIteratorState(visited, [t.source]))
    else
        init_source = first(t.source)
        visited[init_source] = true
        return (init_source, MultiSourceIteratorState(visited, [init_source], 1))
    end
end


"""
    Base.iterate(t::DFSIterator, state::SingleSourceIteratorState)

Iterator to visit each vertex in a graph using depth-first search.
"""
function Base.iterate(t::DFSIterator, state::SingleSourceIteratorState)
    while !isempty(state.queue)
        for node in outneighbors(t.graph, state.queue[end])
            if !state.visited[node]
                push!(state.queue, node)
                state.visited[node] = true
                return (node, state)
            end
        end
        pop!(state.queue)
    end
end


"""
    Base.iterate(t::DFSIterator, state::MultiSourceIteratorState)

Iterator to visit each vertex in a graph using depth-first search.
"""
function Base.iterate(t::DFSIterator, state::MultiSourceIteratorState)
    while !isempty(state.queue)
        for node in outneighbors(t.graph, state.queue[end])
            if !state.visited[node]
                push!(state.queue, node)
                state.visited[node] = true
                return (node, state)
            end
        end
        pop!(state.queue)
    end
    # reset state and begin traversal at next source
    state.source_id += 1
    state.source_id > length(t.source) && return nothing
    init_source =t.source[state.source_id]
    state.visited .= false
    state.visited[init_source] = true
    state.queue = [init_source]
    return (init_source, state)
end