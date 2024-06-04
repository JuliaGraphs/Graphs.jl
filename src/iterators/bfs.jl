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
    added::BitVector
    curr_level::Vector{Int}
    next_level::Vector{Int}
    node_idx::Int
    n_visited::Int
end

Base.IteratorSize(::BFSIterator) = Base.SizeUnknown()
Base.eltype(::Type{BFSIterator{S,G}}) where {S,G} = eltype(G)

"""
    Base.iterate(t::BFSIterator)

First iteration to visit vertices in a graph using breadth-first search.
"""
function Base.iterate(t::BFSIterator{<:Integer})
    visited, added = falses(nv(t.graph)), falses(nv(t.graph))
    visited[t.source] = false
    state = BFSVertexIteratorState(visited, added, [t.source], Int[], 0, 0)
    return Base.iterate(t, state)
end

function Base.iterate(t::BFSIterator{<:AbstractArray})
    visited, added = falses(nv(t.graph)), falses(nv(t.graph))
    visited[first(t.source)] = false
    curr_level = unique(s for s in t.source)
    state = BFSVertexIteratorState(visited, added, curr_level, Int[], 0, 0)
    return Base.iterate(t, state)
end

"""
    Base.iterate(t::BFSIterator, state::VertexIteratorState)

Iterator to visit vertices in a graph using breadth-first search.
"""
function Base.iterate(t::BFSIterator, state::BFSVertexIteratorState)
    state.n_visited == nv(t.graph) && return nothing
    # we fill nodes in this level
    if state.node_idx == length(state.curr_level)
        @inbounds for node in state.curr_level
            for adj_node in outneighbors(t.graph, node)
                if !state.visited[adj_node] && !state.added[adj_node]
                    push!(state.next_level, adj_node)
                    state.added[adj_node] = true
                end
            end
        end
        state.curr_level, state.next_level = state.next_level, Int[]
        state.node_idx = 0
    end
    # we visit all nodes in this level
    @inbounds while state.node_idx < length(state.curr_level)
        state.node_idx += 1
        node = state.curr_level[state.node_idx]
        state.n_visited += 1
        state.visited[node] = true
        return (node, state)
    end
    return nothing
end
