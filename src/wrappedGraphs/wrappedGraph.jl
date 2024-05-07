"""
    AbstractWrappedGraph{T<:Integer, G <: AbstractGraph{T}} <: Graphs.AbstractGraph{T}

A graph type that wraps an `AbstractGraph{T}`.

"""
abstract type AbstractWrappedGraph{T<:Integer, G<:AbstractGraph{T}} <: Graphs.AbstractGraph{T} end
    
"""
    wrapped_graph(g::AbstractWrappedGraph)

Return the wrapped graph

"""
wrapped_graph(g::AbstractWrappedGraph) =_NI("wrapped_graph")


Graphs.is_directed(::AbstractWrappedGraph{T, G}) where {T, G} = Graphs.is_directed(G)
Graphs.is_directed(::Type{<:AbstractWrappedGraph{T, G}}) where {T, G} = Graphs.is_directed(G)
# Graphs.is_directed(::AbstractWrappedGraph) = Graphs.is_directed(wrapped_graph(g))
# Graphs.is_directed(::Type{<:AbstractWrappedGraph{T}}) where {G} = Graphs.is_directed(G)


Graphs.edges(g::AbstractWrappedGraph) = Graphs.edges(wrapped_graph(g))

Graphs.edgetype(g::AbstractWrappedGraph) = Graphs.edgetype(wrapped_graph(g))

Graphs.has_edge(g::AbstractWrappedGraph, s, d) = Graphs.has_edge(wrapped_graph(g), s, d)

Graphs.has_vertex(g::AbstractWrappedGraph, v) = Graphs.has_vertex(wrapped_graph(g), v)

Graphs.inneighbors(g::AbstractWrappedGraph, v) = Graphs.inneighbors(wrapped_graph(g), v)

Graphs.outneighbors(g::AbstractWrappedGraph, v) = Graphs.outneighbors(wrapped_graph(g), v)

Graphs.ne(g::AbstractWrappedGraph) = Graphs.ne(wrapped_graph(g))

Graphs.nv(g::AbstractWrappedGraph) = Graphs.nv(wrapped_graph(g))

Graphs.vertices(g::AbstractWrappedGraph) = Graphs.vertices(wrapped_graph(g))
