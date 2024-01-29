"""
    abstract type Iterator

`Iterator` is an abstract type which specifies a particular algorithm to use when 
iterating through a graph.
"""
abstract type Iterator end


"""
    struct VertexIterator <: Iterator

`VertexIterator` is a type used to iterate through graph vertices.
"""
struct VertexIterator{S} <: Iterator
    graph::AbstractGraph
    source::S
    traversal_fn::Function
end


"""
    DFSIterator(g::AbstractGraph, sources)

`DFSIterator` is a struct which specifies using depth-first traversal to iterate through 
a graph. A source node must be supplied to construct this iterator as 
`DFSIterator(g::AbstractGraph, source::Int)`.

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
DFSIterator(g::AbstractGraph, sources=1) = VertexIterator(g, sources, traverse_dfs)


"""
    BFSIterator(g::AbstractGraph, sources)

`BFSIterator` is a struct which specifies using breadth-first traversal to iterate through 
a graph. A source node must be supplied to construct this iterator as 
`BFSIterator(g::AbstractGraph, source::Int)`.

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

julia> for node in BFSIterator(g,[1,3])
           display(node)
       end
1
2
3
4
5
3
1
4
5
2
```
"""
BFSIterator(g::AbstractGraph, sources=1) = VertexIterator(g, sources, traverse_bfs)


"""
    abstract type AbstractIteratorState

`IteratorState` is an abstract type to hold the current state of iteration which is need 
for Julia's Base.iterate() function.
"""
abstract type AbstractIteratorState end


"""
    mutable struct SingleSourceIteratorState

`SingleSourceIteratorState` is a struct to hold the current state of iteration which is need 
for Julia's Base.iterate() function. It is a basic implementation used for depth-first or 
breadth-first iterators when a single source is supplied.
"""
mutable struct SingleSourceIteratorState <: AbstractIteratorState
    visited::BitArray
    queue::Vector{Int}
end


"""
    mutable struct MultiSourceIteratorState

`MultiSourceIteratorState` is a struct to hold the current state of iteration which is need 
for Julia's Base.iterate() function. It is a basic implementation used for depth-first or 
breadth-first iterators when mutltiple sources are supplied.
"""
mutable struct MultiSourceIteratorState <: AbstractIteratorState
    visited::BitArray
    queue::Vector{Int}
    source_id::Int
end


"""
    Base.iterate(t::VertexIterator)

First iteration to visit each vertex in a graph.
"""
function Base.iterate(t::VertexIterator)
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
    Base.iterate(t::VertexIterator, state::SingleSourceIteratorState)

Iterator to visit each vertex in a graph.
"""
function Base.iterate(t::VertexIterator, state::SingleSourceIteratorState)
    t.traversal_fn(t, state)
end


"""
    Base.iterate(t::VertexIterator, state::MultiSourceIteratorState)

Iterator to visit each vertex in a graph.
"""
function Base.iterate(t::VertexIterator, state::MultiSourceIteratorState)
    result = t.traversal_fn(t, state)
    result !== nothing && return result
    # reset state and begin traversal at next source
    state.source_id += 1
    state.source_id > length(t.source) && return nothing
    init_source =t.source[state.source_id]
    state.visited .= false
    state.visited[init_source] = true
    state.queue = [init_source]
    return (init_source, state)
end


function traverse_dfs(t::VertexIterator, state::AbstractIteratorState)
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


function traverse_bfs(t::VertexIterator, state::AbstractIteratorState)
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
end
