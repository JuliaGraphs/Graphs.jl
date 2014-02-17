# graph represented by a light-weight edge list

type GenericEdgeList{V,E,VList,EList} <: AbstractGraph{V,E}
	is_directed::Bool
	vertices::VList
	edges::EList
end

@graph_implements GenericEdgeList vertex_list edge_list vertex_map edge_map

typealias EdgeList{E} GenericEdgeList{Int,E,Range1{Int},Vector{E}}

# required interface

is_directed(g::GenericEdgeList) = g.is_directed

num_vertices(g::GenericEdgeList) = length(g.vertices)
vertices(g::GenericEdgeList) = g.vertices
vertex_index(v, g::GenericEdgeList) = vertex_index(v)

num_edges(g::GenericEdgeList) = length(g.edges)
edges(g::GenericEdgeList) = g.edges
edge_index(e, g::GenericEdgeList) = edge_index(e)

# mutation

function add_edge!{V,E}(g::GenericEdgeList{V,E}, e::E)
end

