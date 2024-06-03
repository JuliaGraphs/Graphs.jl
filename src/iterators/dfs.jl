"""
    DFSIterator

`DFSIterator` is used to iterate through graph vertices using a depth-first search. 
A source node(s) is optionally supplied as an `Int` or an array-like type that can be 
indexed if supplying multiple sources.
    
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
struct DFSIterator{S,G<:AbstractGraph}
    graph::G
    source::S
    function DFSIterator(graph::G, source::S) where {S,G}
        if any(node -> !has_vertex(graph, node), source)
            error("Some source nodes for the iterator are not in the graph")
        end
        return new{S,G}(graph, source)
    end
end

"""
    DFSVertexIteratorState

`DFSVertexIteratorState` is a struct to hold the current state of iteration
in DFS which is needed for the `Base.iterate()` function. A queue is used to
keep track of the vertices which will be visited during DFS. Since the queue
can contains repetitions of already visited nodes, we also keep track of that
in a `BitVector` so that to skip those nodes.
"""
mutable struct DFSVertexIteratorState
    visited::BitVector
    queue::Vector{Int}
end

Base.IteratorSize(::DFSIterator) = Base.SizeUnknown()
Base.eltype(::Type{DFSIterator{S,G}}) where {S,G} = eltype(G)

"""
    Base.iterate(t::DFSIterator)

First iteration to visit vertices in a graph using depth-first search.
"""
function Base.iterate(t::DFSIterator{<:Integer})
    visited = falses(nv(t.graph))
    visited[t.source] = true
    return (t.source, DFSVertexIteratorState(visited, [t.source]))
end

function Base.iterate(t::DFSIterator{<:AbstractArray})
    visited = falses(nv(t.graph))
    source_rev = reverse(t.source)
    visited[last(source_rev)] = true
    state = DFSVertexIteratorState(visited, source_rev)
    return (last(source_rev), state)
end

"""
    Base.iterate(t::DFSIterator, state::VertexIteratorState)

Iterator to visit vertices in a graph using depth-first search.
"""
function Base.iterate(t::DFSIterator, state::DFSVertexIteratorState)
    graph, visited, queue = t.graph, state.visited, state.queue
    @inbounds while !isempty(queue)
        # we take the last node in the queue
        curr_node = last(queue)
        # we first return it
        if !visited[curr_node]
            visited[curr_node] = true
            return (curr_node, state)
        end
        # and then we visit a neighbor and push it at the
        # end of the queue
        for adj_node in outneighbors(graph, curr_node)
            if !visited[adj_node]
                push!(queue, adj_node)
                visited[adj_node] = true
                return (adj_node, state)
            end
        end
        # we pop the last node in the queue
        # when it and all its neighbors were visited
        pop!(queue)
    end
end
