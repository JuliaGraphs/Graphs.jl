###########################################################
#
#   GenericIncidenceList{V, E, VList, IncList}
#
#   V :         vertex type
#   E :         edge type
#   VList :     the type of vertex list
#   IncList:    the incidence list
#
###########################################################

type GenericIncidenceList{V, E, VList, IncList} <: AbstractGraph{V, E}
    is_directed::Bool
    vertices::VList
    nedges::Int
    inclist::IncList
end

typealias SimpleIncidenceList GenericIncidenceList{Int, IEdge, Range1{Int}, Vector{Vector{IEdge}}}
typealias IncidenceList{V,E} GenericIncidenceList{V, E, Vector{V}, Vector{Vector{E}}}

@graph_implements GenericIncidenceList vertex_list vertex_map edge_map adjacency_list incidence_list

# construction

simple_inclist(nv::Integer; is_directed::Bool=true) =
    SimpleIncidenceList(is_directed, 1:int(nv), 0, multivecs(IEdge, nv))

inclist{V,E}(vs::Vector{V}, ::Type{E}; is_directed::Bool = true) =
    IncidenceList{V,E}(is_directed, vs, 0, multivecs(E, length(vs)))

inclist{V,E}(::Type{V}, ::Type{E}; is_directed::Bool = true) = inclist(V[], E; is_directed=is_directed)
inclist{V}(vs::Vector{V}; is_directed::Bool = true) = inclist(vs, Edge{V}; is_directed=is_directed)
inclist{V}(::Type{V}; is_directed::Bool = true) = inclist(V[], Edge{V}; is_directed=is_directed)

# required interfaces

is_directed(g::GenericIncidenceList) = g.is_directed

num_vertices(g::GenericIncidenceList) = length(g.vertices)
vertices(g::GenericIncidenceList) = g.vertices

num_edges(g::GenericIncidenceList) = g.nedges

vertex_index{V<:ProvidedVertexType}(v::V, g::GenericIncidenceList{V}) = vertex_index(v)
edge_index{V,E}(e::E, g::GenericIncidenceList{V,E}) = edge_index(e)

out_edges{V}(v::V, g::GenericIncidenceList{V}) = g.inclist[vertex_index(v, g)]
out_degree{V}(v::V, g::GenericIncidenceList{V}) = length(out_edges(v, g))
out_neighbors{V}(v::V, g::GenericIncidenceList{V}) = TargetIterator(g, g.inclist[vertex_index(v, g)])

# mutation

function add_vertex!{V,E}(g::GenericIncidenceList{V,E}, v::V)
    push!(g.vertices, v)
    push!(g.inclist, Array(E,0))
    v
end

add_vertex!(g::GenericIncidenceList, x) = add_vertex!(g, make_vertex(g, x))

function add_edge!{V,E}(g::GenericIncidenceList{V,E}, u::V, v::V, e::E)
    # add an edge between (u, v)
    ui::Int = vertex_index(u, g)
    push!(g.inclist[ui], e)
    g.nedges += 1

    if !g.is_directed
        vi::Int = vertex_index(v, g)
        push!(g.inclist[vi], revedge(e))
    end
end

add_edge!{V,E}(g::GenericIncidenceList{V,E}, e::E) = add_edge!(g, source(e, g), target(e, g), e)
add_edge!{V,E}(g::GenericIncidenceList{V, E}, u::V, v::V) = add_edge!(g, u, v, make_edge(g, u, v))
