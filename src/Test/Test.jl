
"""
    Graphs.Test

A module that provides utilities for testing functions that should work with any `Graphs.AbstractGraph`.
"""
module Test

using Graphs

export GenericEdge, GenericGraph, GenericDiGraph, generic_graph

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
    GenericGraph{T} <: Graphs.AbstractWrappedGraph{T, SimpleGraph{T}}

An undirected graph type that can  be used to tests functions that relay on the Graphs.jl interface.

"""
struct GenericGraph{T} <: Graphs.AbstractWrappedGraph{T, SimpleGraph{T}}
    g::SimpleGraph{T}
end

"""
    GenericDiGraph{T} <: Graphs.AbstractWrappedGraph{T, SimpleDiGraph{T}}

A directed graph type that can  be used to tests functions that relay on the Graphs.jl interface.

"""
struct GenericDiGraph{T} <: Graphs.AbstractWrappedGraph{T, SimpleDiGraph{T}}
    g::SimpleDiGraph{T}
end

"""
    generic_graph(g::Union{SimpleGraph, SimpleDiGraph})

Return either a GenericGraph or GenericDiGraph that wraps a copy of g.
"""
function generic_graph(g::Union{SimpleGraph,SimpleDiGraph})
    g = copy(g)
    return is_directed(g) ? GenericDiGraph(g) : GenericGraph(g)
end

function GenericDiGraph(elist::Vector{Graphs.SimpleDiGraphEdge{T}}) where {T<:Integer}
    return GenericDiGraph{T}(SimpleDiGraph(elist))
end

Graphs.wrapped_graph(g::GenericGraph) = g.g
Graphs.wrapped_graph(g::GenericDiGraph) = g.g

Graphs.edges(g::GenericGraph) = (GenericEdge(e) for e in Graphs.edges(g.g))
Graphs.edges(g::GenericDiGraph) = (GenericEdge(e) for e in Graphs.edges(g.g))

Graphs.edgetype(g::GenericGraph) = GenericEdge{eltype(g)}
Graphs.edgetype(g::GenericDiGraph) = GenericEdge{eltype(g)}

Graphs.inneighbors(g::GenericGraph, v) = (u for u in Graphs.inneighbors(g.g, v))
Graphs.inneighbors(g::GenericDiGraph, v) = (u for u in Graphs.inneighbors(g.g, v))

Graphs.outneighbors(g::GenericGraph, v) = (u for u in Graphs.outneighbors(g.g, v))
Graphs.outneighbors(g::GenericDiGraph, v) = (u for u in Graphs.outneighbors(g.g, v))

Graphs.vertices(g::GenericGraph) = (v for v in Graphs.vertices(g.g))
Graphs.vertices(g::GenericDiGraph) = (v for v in Graphs.vertices(g.g))
end # module
