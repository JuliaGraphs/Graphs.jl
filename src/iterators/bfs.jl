"""
    BFSIterator

`BFSIterator` is a subtype of [`VertexIterator`](@ref) to iterate through graph vertices using a 
breadth-first search. A source node(s) is optionally supplied as an `Int` or an array-like type 
that can be indexed if supplying multiple sources. If no source is provided, it defaults to the 
first vertex.
    
# Examples
```julia-repl
julia> g = smallgraph(:house)
{5, 6} undirected simple Int64 graph

julia> for node in BFSIterator(g,3)
           display(node)
       end
3
1
4
5
2
```
"""
struct BFSIterator{S} <: VertexIterator
    graph::AbstractGraph
    source::S
end

BFSIterator(g::AbstractGraph) = BFSIterator(g, one(eltype(g)))

Base.length(t::BFSIterator) = nv(t.graph)
Base.eltype(t::BFSIterator) = eltype(t.graph)


"""
    Base.iterate(t::BFSIterator)

First iteration to visit each vertex in a graph using breadth-first search.
"""
function Base.iterate(t::BFSIterator)
    visited = falses(nv(t.graph))
    visited[t.source] = true
    return (t.source, VertexIteratorState(visited, [t.source]))
end
function Base.iterate(t::BFSIterator{<:AbstractArray})
    visited = falses(nv(t.graph))
    visited[first(t.source)] = true
    return (first(t.source), VertexIteratorState(visited, t.source))
end

"""
    Base.iterate(t::BFSIterator, state::VertexIteratorState)

Iterator to visit each vertex in a graph using breadth-first search.
"""
function Base.iterate(t::BFSIterator, state::VertexIteratorState)
    while !isempty(state.queue)
        node_start = first(state.queue)
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
        popfirst!(state.queue)
    end
end

