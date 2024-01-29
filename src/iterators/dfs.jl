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
```
"""
struct DFSIterator{S} <: VertexIterator
    graph::AbstractGraph
    source::S
end

DFSIterator(g::AbstractGraph) = DFSIterator(g, one(eltype(g)))

Base.length(t::DFSIterator) = nv(t.graph)
Base.eltype(t::DFSIterator) = eltype(t.graph)

"""
    Base.iterate(t::DFSIterator)

First iteration to visit each vertex in a graph using depth-first search.
"""
function Base.iterate(t::DFSIterator)
    visited = falses(nv(t.graph))
    visited[t.source] = true
    return (t.source, VertexIteratorState(visited, [t.source]))
end
function Base.iterate(t::DFSIterator{<:AbstractArray})
    visited = falses(nv(t.graph))
    reverse!(t.source)
    visited[last(t.source)] = true
    return (last(t.source), VertexIteratorState(visited, t.source))
end

"""
    Base.iterate(t::DFSIterator, state::VertexIteratorState)

Iterator to visit each vertex in a graph using depth-first search.
"""
function Base.iterate(t::DFSIterator, state::VertexIteratorState)
    while !isempty(state.queue)
        node_start = last(state.queue)
        if !state.visited[node_start]
            state.visited[node_start] = true
            return (node_start, state)
        end
        for node in outneighbors(t.graph, node_start)
            if !state.visited[node]
                push!(state.queue, node)
                state.visited[node] = true
                return (node, state)
            end
        end
        pop!(state.queue)
    end
end