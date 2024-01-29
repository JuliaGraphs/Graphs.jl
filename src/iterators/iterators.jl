"""
    abstract type Iterator

`Iterator` is an abstract type which specifies a particular algorithm to use when iterating through a graph.
"""
abstract type Iterator end

"""
    abstract type VertexIterator <: Iterator

`VertexIterator` is an abstract type to iterate through graph vertices.
"""
abstract type VertexIterator <: Iterator end

"""
    abstract type EdgeIterator <: Iterator

`EdgeIterator` is an abstract type to iterate through graph edges.
"""
abstract type EdgeIterator <: Iterator end

"""
    abstract type AbstractIteratorState

`IteratorState` is an abstract type to hold the current state of iteration which is need for the Base.iterate() function.
"""
abstract type AbstractIteratorState end

"""
    mutable struct VertexIteratorState

`VertexIteratorState` is a struct to hold the current state of iteration which is need for the Base.iterate() function. It is a basic implementation used for depth-first or breadth-first iterators when a single source is supplied.
"""
mutable struct VertexIteratorState <: AbstractIteratorState
    visited::BitArray
    queue::Vector{Int}
end

# traversal implementations
include("bfs.jl")
include("dfs.jl")
