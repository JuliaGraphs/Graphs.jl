# The concept and trivial implementation of graph visitors

abstract AbstractGraphVisitor

# trivial implementation

# invoked when a vertex v is encountered for the first time
# this function returns whether to continue search
discover_vertex!(vis::AbstractGraphVisitor, v) = true

# invoked when the algorithm is about to examine v's neighbors
open_vertex!(vis::AbstractGraphVisitor, v) = nothing

# invoked when a neighbor is discovered & examined
examine_neighbor!(vis::AbstractGraphVisitor, u, v, color::Int) = nothing

# invoked when an edge is discovered & examined
examine_edge!(vis::AbstractGraphVisitor, e, color::Int) = nothing

# invoked when all of v's neighbors have been examined
close_vertex!(vis::AbstractGraphVisitor, v) = nothing


# This is the common base for BreadthFirst and DepthFirst
abstract AbstractGraphVisitAlgorithm


###########################################################
#
#   General algorithms based on graph traversal
#
###########################################################

# List vertices by the order of being discovered

type VertexListVisitor{V} <: AbstractGraphVisitor
    vertices::Vector{V}
    
    function VertexListVisitor(n::Integer)
        vs = Array(V, 0)
        sizehint(vs, n)
        new(vs)        
    end
end

function discover_vertex!{V}(visitor::VertexListVisitor{V}, v::V)
    push!(visitor.vertices, v)
    true
end

function visited_vertices{V,E}(
    graph::AbstractGraph{V,E}, 
    alg::AbstractGraphVisitAlgorithm,
    sources)
    
    visitor = VertexListVisitor{V}(num_vertices(graph))
    traverse_graph(graph, alg, sources, visitor)
    visitor.vertices::Vector{V}
end
