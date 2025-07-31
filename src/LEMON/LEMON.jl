module LEMON

using Graphs

export LEMONGraph, LEMONDiGraph

abstract type AbstractLEMONGraph <: AbstractGraph{Int} end

struct LEMONGraph <: AbstractLEMONGraph
    n::Int
    m::Int

    function LEMONGraph(n::Integer=0)
        n >= 0 || throw(DomainError(n, "Number of vertices must be non-negative"))
        return new(n, 0)
    end
end

struct LEMONDiGraph <: AbstractLEMONGraph
    n::Int
    m::Int

    function LEMONDiGraph(n::Integer=0)
        n >= 0 || throw(DomainError(n, "Number of vertices must be non-negative"))
        return new(n, 0)
    end
end

Graphs.is_directed(::Type{LEMONGraph}) = false
Graphs.is_directed(::Type{LEMONDiGraph}) = true

Graphs.nv(g::AbstractLEMONGraph) = g.n
Graphs.ne(g::AbstractLEMONGraph) = g.m

Graphs.vertices(g::AbstractLEMONGraph) = 1:nv(g)

function Base.show(io::IO, g::LEMONGraph)
    return print(io, "{$(nv(g)), $(ne(g))} undirected LEMON graph")
end

function Base.show(io::IO, g::LEMONDiGraph)
    return print(io, "{$(nv(g)), $(ne(g))} directed LEMON graph")
end

end