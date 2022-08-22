"""
    abstract type IteratorAlgorithm

`IteratorAlgorithm` is an abstract type which specifies a particular algorithm to use when iterating through a graph.
"""
abstract type IteratorAlgorithm end


"""
    struct DFSIterator <: IteratorAlgorithm

`DFS` is a struct which specifies using depth-first traversal to iterate through a graph. A source node must be supplied to construct this iterator as `DFS(g::AbstractGraph, source::Int)`.

`DFSIterator` is a struct which specifies using depth-first traversal to iterate through a graph. A source node must be supplied to construct this iterator as `DFSIterator(g::AbstractGraph, source::Int)`.

# Examples
```julia-repl
julia> g = smallgraph(:house)
{5, 6} undirected simple Int64 graph

julia> for node in DFSIterator(g, 1)
           display(node)
       end
1
2
4
3
5
```
"""
struct DFSIterator <: IteratorAlgorithm
    graph::AbstractGraph
    source::Int
end


"""
    struct BFSIterator <: IteratorAlgorithm

`BFS` is a struct which specifies using breadth-first traversal to iterate through a graph. A source node must be supplied to construct this iterator as `BFS(g::AbstractGraph, source::Int)`.

# Examples
```julia-repl
julia> g = smallgraph(:house)
{5, 6} undirected simple Int64 graph

julia> for node in BFSIterator(g, 1)
           display(node)
       end
1
2
3
4
5
```
"""
struct BFSIterator <: IteratorAlgorithm
    graph::AbstractGraph
    source::Int
end


"""
    abstract type AbstractGraphIteratorState

`BasicGraphIteratorState` is an abstract type to hold the current state of iteration which is need for Julia's Base.iterate() function.
"""
abstract type AbstractGraphIteratorState end


"""
    mutable struct BasicGraphIteratorState

`BasicGraphIteratorState` is a struct to hold the current state of iteration which is need for Julia's Base.iterate() function. It is a basic implementation used for depth-first or breadth-first iterators.
"""
mutable struct BasicGraphIteratorState <: AbstractGraphIteratorState
    visited::BitArray
    queue::Vector{Int}
end


"""
    Base.iterate(t::Union{BFSIterator, DFSIterator})

First iteration to visit each node for depth-first or breadth-first type iterators.
"""
function Base.iterate(t::Union{BFSIterator, DFSIterator})
    visited = falses(nv(t.graph))
    visited[t.source] = true
    state = BasicGraphIteratorState(visited, [t.source])
    return (t.source, state)
end


"""
    Base.iterate(t::DFSIterator, state::BasicGraphIteratorState)

Iterator to visit each node in a depth-first manner.
"""
function Base.iterate(t::DFSIterator, state::BasicGraphIteratorState)
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
    return nothing
end

"""
    Base.iterate(t::BFSIterator, state::BasicGraphIteratorState)

Iterator to visit each node in a breadth-first manner.
"""
function Base.iterate(t::BFSIterator, state::BasicGraphIteratorState)
    while !isempty(state.queue)
        for node in outneighbors(t.graph, state.queue[1])
            if !state.visited[node]
                push!(state.queue, node)
                state.visited[node] = true
                return (node, state)
            end
        end
        popfirst!(state.queue)
    end
    return nothing
end
