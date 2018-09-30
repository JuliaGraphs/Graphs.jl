# The concept and trivial implementation of graph visitors

abstract type AbstractGraphVisitor end

# trivial implementation

# invoked when a vertex v is encountered for the first time
# this function returns whether to continue search
discover_vertex!(vis::AbstractGraphVisitor, v) = true

# invoked when the algorithm is about to examine v's neighbors
open_vertex!(vis::AbstractGraphVisitor, v) = nothing

# invoked when a neighbor is discovered & examined
examine_neighbor!(vis::AbstractGraphVisitor, u, v, color::Int, ecolor::Int) = nothing

# invoked when an edge is discovered & examined
examine_edge!(vis::AbstractGraphVisitor, e, color::Int) = nothing

# invoked when all of v's neighbors have been examined
close_vertex!(vis::AbstractGraphVisitor, v) = nothing


mutable struct TrivialGraphVisitor <: AbstractGraphVisitor
end


# This is the common base for BreadthFirst and DepthFirst
abstract type AbstractGraphVisitAlgorithm end


###########################################################
#
#   General algorithms based on graph traversal
#
###########################################################

# List vertices by the order of being discovered

mutable struct VertexListVisitor{V} <: AbstractGraphVisitor
    vertices::Vector{V}

    function VertexListVisitor{V}(n::Integer=0) where {V}
        vs = Array{V}(undef, 0)
        sizehint!(vs, n)
        new{V}(vs)
    end
end

function discover_vertex!(visitor::VertexListVisitor{V}, v::V) where {V}
    push!(visitor.vertices, v)
    true
end

function visited_vertices(
    graph::AbstractGraph{V,E},
    alg::AbstractGraphVisitAlgorithm,
    sources) where {V,E}

    visitor = VertexListVisitor{V}(num_vertices(graph))
    traverse_graph(graph, alg, sources, visitor)
    visitor.vertices::Vector{V}
end


# Print visit log

mutable struct LogGraphVisitor{S<:IO} <: AbstractGraphVisitor
    io::S
end

function discover_vertex!(vis::LogGraphVisitor, v)
    println(vis.io, "discover vertex: $v")
    true
end

open_vertex!(vis::LogGraphVisitor, v) = println(vis.io, "open vertex: $v")
close_vertex!(vis::LogGraphVisitor, v) = println(vis.io, "close vertex: $v")

function examine_neighbor!(vis::LogGraphVisitor, u, v, vcolor::Int, ecolor::Int)
    println(vis.io, "examine neighbor: $u -> $v (vertexcolor = $vcolor, edgecolor= $ecolor)")
end

function examine_edge!(vis::LogGraphVisitor, e, color::Int)
    println(vis.io, "examine edge: $e")
end

function traverse_graph_withlog(g::AbstractGraph, alg::AbstractGraphVisitAlgorithm, sources, io::IO)
    visitor = LogGraphVisitor(io)
    traverse_graph(g, alg, sources, visitor)
end

traverse_graph_withlog(g::AbstractGraph, alg::AbstractGraphVisitAlgorithm,
    sources) = traverse_graph_withlog(g, alg, sources, STDOUT)
