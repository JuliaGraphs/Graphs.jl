"""
    BFSIterator

`BFSIterator` is a subtype of [`VertexIterator`](@ref) to iterate through graph vertices using a breadth-first search. A source node(s) is optionally supplied as an `Int` or an array-like type that can be indexed if supplying multiple sources. If no source is provided, it defaults to the first vertex.
    
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
struct BFSIterator{S} <: VertexIterator
    graph::AbstractGraph
    source::S
end

BFSIterator(g::AbstractGraph) = BFSIterator(g, one(eltype(g)))


"""
    Base.iterate(t::BFSIterator)

First iteration to visit each vertex in a graph using breadth-first search.
"""
function Base.iterate(t::BFSIterator)
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
    Base.iterate(t::BFSIterator, state::SingleSourceIteratorState)

Iterator to visit each vertex in a graph using breadth-first search.
"""
function Base.iterate(t::BFSIterator, state::SingleSourceIteratorState)
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


"""
    Base.iterate(t::BFSIterator, state::SingleSourceIteratorState)

Iterator to visit each vertex in a graph using breadth-first search.
"""
function Base.iterate(t::BFSIterator, state::MultiSourceIteratorState)
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
    # reset state and begin traversal at next source
    state.source_id += 1
    state.source_id > length(t.source) && return nothing
    init_source =t.source[state.source_id]
    state.visited .= false
    state.visited[init_source] = true
    state.queue = [init_source]
    return (init_source, state)
end