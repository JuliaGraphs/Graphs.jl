# graph represented by a light-weight edge list

mutable struct GenericEdgeList{V,E,VList,EList} <: AbstractGraph{V,E}
    is_directed::Bool
    vertices::VList
    edges::EList
end

@graph_implements GenericEdgeList vertex_list edge_list vertex_map edge_map

const SimpleEdgeList{E} = GenericEdgeList{Int,E,UnitRange{Int},Vector{E}}
const EdgeList{V,E} = GenericEdgeList{V,E,Vector{V},Vector{E}}

# construction

simple_edgelist(nv::Integer, edges::Vector{E}; is_directed::Bool=true) where {E} =
    SimpleEdgeList{E}(is_directed, intrange(nv), edges)

edgelist(vertices::Vector{V}, edges::Vector{E}; is_directed::Bool=true) where {V,E} =
    EdgeList{V,E}(is_directed, vertices, edges)


# required interface

is_directed(g::GenericEdgeList) = g.is_directed

num_vertices(g::GenericEdgeList) = length(g.vertices)
vertices(g::GenericEdgeList) = g.vertices

num_edges(g::GenericEdgeList) = length(g.edges)
edges(g::GenericEdgeList) = g.edges
edge_index(e, g::GenericEdgeList) = edge_index(e)

# mutation

add_vertex!(g::GenericEdgeList{V}, v::V) where {V} = (push!(g.vertices, v); v)
add_vertex!(g::GenericEdgeList{V}, x) where {V} = add_vertex!(g, make_vertex(g, x))

add_edge!(g::GenericEdgeList{V,E}, e::E) where {V,E} = (push!(g.edges, e); e)
add_edge!(g::GenericEdgeList{V,E}, u::V, v::V) where {V,E} = add_edge!(g, make_edge(g, u, v))
