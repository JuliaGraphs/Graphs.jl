
"""
    Graphs.Test

A module that provides utilities for testing functions that should work with any `Graphs.AbstractGraph`.
"""
module Test

using Graphs

"""
    AbstractWrappedGraph{G <: AbstractGraph{T}} <: Graphs.AbstractGraph{T}

An undirected graph type that wraps an `AbstractGraph{T}`.

"""
@traitfn abstract type  AbstractWrappedGraph{G::(!IsDirected)} <: Graphs.AbstractGraph{T} where {T, G<:AbstractGraph{T}}
# @traitfn abstract type  AbstractWrappedGraph{G<:AbstractGraph{T}} <: Graphs.AbstractGraph{T}

"""
    AbstractWrappedGraph{G <: AbstractGraph{T}} <: Graphs.AbstractGraph{T}

An undirected graph type that wraps an `AbstractGraph{T}`.

"""
@traitfn abstract type  AbstractWrappedDiGraph{G::IsDirected} <: Graphs.AbstractGraph{T} where {T, G<:AbstractGraph{T}}

"""
    wrapped_graph(g::AbstractWrappedGraph)

Return the wrapped graph

"""
function wrapped_graph(g::AbstractWrappedGraph) = _NI("wrapped_graph")

# """
#     AbstractWrappedDiGraph{T} <: Graphs.AbstractGraph{T}

Graphs.is_directed(::Type{<:AbstractWrappedGraph}) = false
Graphs.is_directed(::Type{<:AbstractWrappedDiGraph}) = true

Graphs.edges(g::AbstractWrappedGraph) = (e for e in Graphs.edges(g.g))
Graphs.edges(g::AbstractWrappedDiGraph) = (e for e in Graphs.edges(g.g))

Graphs.edgetype(g::AbstractWrappedGraph) = eltype(g)
Graphs.edgetype(g::AbstractWrappedDiGraph) = eltype(g)

Graphs.has_edge(g::AbstractWrappedGraph, s, d) = Graphs.has_edge(g.g, s, d)
Graphs.has_edge(g::AbstractWrappedDiGraph, s, d) = Graphs.has_edge(g.g, s, d)

Graphs.has_vertex(g::AbstractWrappedGraph, v) = Graphs.has_vertex(g.g, v)
Graphs.has_vertex(g::AbstractWrappedDiGraph, v) = Graphs.has_vertex(g.g, v)

Graphs.inneighbors(g::AbstractWrappedGraph, v) = (u for u in Graphs.inneighbors(g.g, v))
Graphs.inneighbors(g::AbstractWrappedDiGraph, v) = (u for u in Graphs.inneighbors(g.g, v))

Graphs.outneighbors(g::AbstractWrappedGraph, v) = (u for u in Graphs.outneighbors(g.g, v))
Graphs.outneighbors(g::AbstractWrappedDiGraph, v) = (u for u in Graphs.outneighbors(g.g, v))

Graphs.ne(g::AbstractWrappedGraph) = Graphs.ne(g.g)
Graphs.ne(g::AbstractWrappedDiGraph) = Graphs.ne(g.g)

Graphs.nv(g::AbstractWrappedGraph) = Graphs.nv(g.g)
Graphs.nv(g::AbstractWrappedDiGraph) = Graphs.nv(g.g)

Graphs.vertices(g::AbstractWrappedGraph) = (v for v in Graphs.vertices(g.g))
Graphs.vertices(g::AbstractWrappedDiGraph) = (v for v in Graphs.vertices(g.g))

end # module
