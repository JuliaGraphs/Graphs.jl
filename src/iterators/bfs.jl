"""
    BFSIterator

`BFSIterator` is used to iterate through graph vertices using a breadth-first search. 
A source node(s) is optionally supplied as an `Int` or an array-like type that can be 
indexed if supplying multiple sources.
    
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
struct BFSIterator{S,G<:AbstractGraph}
    graph::G
    source::S
    function BFSIterator(graph::G, source::S) where {S,G}
        if any(node -> !has_vertex(graph, node), source)
            error("Some source nodes for the iterator are not in the graph")
        end
        return new{S,G}(graph, source)
    end
end

"""
    BFSVertexIteratorState

`BFSVertexIteratorState` is a struct to hold the current state of iteration
in BFS which is needed for the `Base.iterate()` function. A queue is used to
keep track of the vertices which will be visited during BFS. Since the queue
can contains repetitions of already visited nodes, we also keep track of that
in a `BitVector` so that to skip those nodes.
"""
mutable struct BFSVertexIteratorState
    visited::BitVector
    queue::Vector{Int}
    neighbor_idx::Int
    n_visited::Int
end

Base.IteratorSize(::BFSIterator) = Base.SizeUnknown()
Base.eltype(::Type{BFSIterator{S,G}}) where {S,G} = eltype(G)

"""
    Base.iterate(t::BFSIterator)

First iteration to visit vertices in a graph using breadth-first search.
"""
function Base.iterate(t::BFSIterator{<:Integer})
    visited = falses(nv(t.graph))
    visited[t.source] = true
    return (t.source, BFSVertexIteratorState(visited, [t.source], 1, 1))
end

function Base.iterate(t::BFSIterator{<:AbstractArray})
    visited = falses(nv(t.graph))
    visited[first(t.source)] = true
    state = BFSVertexIteratorState(visited, copy(t.source), 1, 1)
    return (first(t.source), state)
end

"""
    Base.iterate(t::BFSIterator, state::VertexIteratorState)

Iterator to visit vertices in a graph using breadth-first search.
"""
function Base.iterate(t::BFSIterator, state::BFSVertexIteratorState)
    graph, visited, queue = t.graph, state.visited, state.queue
    while !isempty(queue)
        if state.n_visited == nv(graph)
            return nothing
        end
        # we visit the first node in the queue
        node_start = first(queue)
        if !visited[node_start]
            visited[node_start] = true
            state.n_visited += 1
            return (node_start, state)
        end
        # which means we arrive here when the first node was visited.
        neigh = outneighbors(graph, node_start)
        if state.neighbor_idx <= length(neigh)
            node = neigh[state.neighbor_idx]
            # we update the idx of the neighbor we will visit,
            # if it is already visited, we repeat
            state.neighbor_idx += 1
            if !visited[node]
                push!(queue, node)
                state.visited[node] = true
                state.n_visited += 1
                return (node, state)
            end
        else
            # when the first node and its neighbors are visited
            # we remove the first node of the queue
            popfirst!(queue)
            state.neighbor_idx = 1
        end
    end
end
