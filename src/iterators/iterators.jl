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
    mutable struct SingleSourceIteratorState

`SingleSourceIteratorState` is a struct to hold the current state of iteration which is need for the Base.iterate() function. It is a basic implementation used for depth-first or breadth-first iterators when a single source is supplied.
"""
mutable struct SingleSourceIteratorState <: AbstractIteratorState
    visited::BitArray
    queue::Vector{Int}
end


"""
    mutable struct MultiSourceIteratorState

`MultiSourceIteratorState` is a struct to hold the current state of iteration which is need for Julia's Base.iterate() function. It is a basic implementation used for depth-first or breadth-first iterators when mutltiple sources are supplied.
"""
mutable struct MultiSourceIteratorState <: AbstractIteratorState
    visited::BitArray
    queue::Vector{Int}
    source_id::Int
end


include("bfs.jl")
include("dfs.jl")
include("kruskal.jl")







