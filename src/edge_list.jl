# graph represented by a light-weight edge list

type GenericEdgeList{V,E,VList,EList} <: AbstractGraph{V,E}
    is_directed::Bool
    vertices::VList
    edges::EList
end

@graph_implements GenericEdgeList vertex_list edge_list vertex_map edge_map

typealias SimpleEdgeList{E} GenericEdgeList{Int,E,Range1{Int},Vector{E}}
typealias EdgeList{V,E} GenericEdgeList{V,E,Vector{V},Vector{E}}

# construction

simple_edgelist{E}(nv::Integer, edges::Vector{E}; is_directed::Bool=true) =
    SimpleEdgeList{E}(is_directed, 1:int(nv), edges)

edgelist{V,E}(vertices::Vector{V}, edges::Vector{E}; is_directed::Bool=true) =
    EdgeList{V,E}(is_directed, vertices, edges)


# required interface

is_directed(g::GenericEdgeList) = g.is_directed

num_vertices(g::GenericEdgeList) = length(g.vertices)
vertices(g::GenericEdgeList) = g.vertices
vertex_index{V<:ProvidedVertexType}(v::V, g::GenericEdgeList{V}) = vertex_index(v)

num_edges(g::GenericEdgeList) = length(g.edges)
edges(g::GenericEdgeList) = g.edges
edge_index(e, g::GenericEdgeList) = edge_index(e)

# mutation

add_vertex!{V}(g::GenericEdgeList{V}, v::V) = (push!(g.vertices, v); v)
add_vertex!{V}(g::GenericEdgeList{V}, x) = add_vertex!(g, make_vertex(g, x))

add_edge!{V,E}(g::GenericEdgeList{V,E}, e::E) = (push!(g.edges, e); e)
add_edge!{V,E}(g::GenericEdgeList{V,E}, u::V, v::V) = add_edge!(g, make_edge(g, u, v))
