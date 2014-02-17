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
typealias VectorIncidenceList{V, E} GenericIncidenceList{V, E, Vector{V}, Vector{Vector{E}}}
typealias IncidenceList{V} VectorIncidenceList{V, Edge{V}}

@graph_implements GenericIncidenceList vertex_list vertex_map edge_map adjacency_list incidence_list

# required interfaces

is_directed(g::GenericIncidenceList) = g.is_directed

num_vertices(g::GenericIncidenceList) = length(g.vertices)
vertices(g::GenericIncidenceList) = g.vertices

num_edges(g::GenericIncidenceList) = g.nedges

vertex_index(v, g::GenericIncidenceList) = vertex_index(v)
edge_index(e, g::GenericIncidenceList) = edge_index(e)

out_degree(v, g::GenericIncidenceList) = length(g.inclist[vertex_index(v)])
out_edges(v, g::GenericIncidenceList) = g.inclist[vertex_index(v)]

out_neighbors(v, g::GenericIncidenceList) = out_neighbors_proxy(g.inclist[vertex_index(v)])

# mutation

function add_vertex!{V,E}(g::GenericIncidenceList{V,E}, v::V)
    iv::Int = vertex_index(v)
    if iv != num_vertices(g) + 1
        throw(ArgumentError("Invalid vertex index."))
    end        
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


# mutation

function simple_inclist(nv::Int; is_directed::Bool = true)
    inclist = Array(Vector{Edge{Int}}, nv)    
    for i = 1 : nv
        inclist[i] = Array(Edge{Int}, 0)
    end
    SimpleIncidenceList(is_directed, 1:nv, 0, inclist)
end

inclist{V}(vty::Type{V}; is_directed::Bool = true) =
                                inclist(V, Edge{V}, is_directed=is_directed)

function inclist{V, E}(vty::Type{V}, ety::Type{E}; is_directed::Bool = true)
    _inclist = Array(Vector{E},0)
    VectorIncidenceList{V, E}(is_directed, Array(V, 0), 0, _inclist)
end
