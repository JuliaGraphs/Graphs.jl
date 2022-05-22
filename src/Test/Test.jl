
"""
    Graphs.Test

A module that provides utilities for testing functions that should work with any `Graphs.AbstractGraph`.
"""
module Test

using Graphs

export GenericEdge, GenericGraph, GenericDiGraph

"""
    GenericEdge <: Graphs.AbstractEdge

An edge type that can  be used to tests functions that relay on the Graphs.jl interface.

"""
struct GenericEdge{T} <: Graphs.AbstractEdge{T}
    e::Graphs.SimpleEdge{T}
end

Graphs.src(e::GenericEdge) = Graphs.src(e.e)

Graphs.dst(e::GenericEdge) = Graphs.dst(e.e)

Base.reverse(e::GenericEdge) = GenericEdge(reverse(e.e))

"""
    GenericGraph{T} <: Graphs.AbstractGraph{T}

An undirected graph type that can  be used to tests functions that relay on the Graphs.jl interface.

"""
struct GenericGraph{T} <: Graphs.AbstractGraph{T}
    g::SimpleGraph{T}
end

"""
    GenericDiGraph{T} <: Graphs.AbstractGraph{T}

A directed graph type that can  be used to tests functions that relay on the Graphs.jl interface.

"""
struct GenericDiGraph{T} <: Graphs.AbstractGraph{T}
    g::SimpleDiGraph{T}
end

Graphs.is_directed(::Type{<:GenericGraph}) = false
Graphs.is_directed(::Type{<:GenericDiGraph}) = true

Base.eltype(g::GenericGraph) = eltype(g.g)
Base.eltype(g::GenericDiGraph) = eltype(g.g)

Graphs.edges(g::GenericGraph) = (GenericEdge(e) for e in Graphs.edges(g.g))
Graphs.edges(g::GenericDiGraph) = (GenericEdge(e) for e in Graphs.edges(g.g))

Graphs.edgetype(g::GenericGraph) = GenericEdge{eltype(g)}
Graphs.edgetype(g::GenericDiGraph) = GenericEdge{eltype(g)}

Graphs.has_edge(g::GenericGraph, s, d) = Graphs.has_edge(g.g, s, d)
Graphs.has_edge(g::GenericDiGraph, s, d) = Graphs.has_edge(g.g, s, d)

Graphs.has_vertex(g::GenericGraph, v) = Graphs.has_vertex(g.g, v)
Graphs.has_vertex(g::GenericDiGraph, v) = Graphs.has_vertex(g.g, v)

Graphs.inneighbors(g::GenericGraph, v) = (u for u in Graphs.inneighbors(g.g, v))
Graphs.inneighbors(g::GenericDiGraph, v) = (u for u in Graphs.inneighbors(g.g, v))

Graphs.outneighbors(g::GenericGraph, v) = (u for u in Graphs.outneighbors(g.g, v))
Graphs.outneighbors(g::GenericDiGraph, v) = (u for u in Graphs.outneighbors(g.g, v))

Graphs.ne(g::GenericGraph) = Graphs.ne(g.g)
Graphs.ne(g::GenericDiGraph) = Graphs.ne(g.g)

Graphs.nv(g::GenericGraph) = Graphs.nv(g.g)
Graphs.nv(g::GenericDiGraph) = Graphs.nv(g.g)

Graphs.vertices(g::GenericGraph) = (v for v in Graphs.vertices(g.g))
Graphs.vertices(g::GenericDiGraph) = (v for v in Graphs.vertices(g.g))

end # module
