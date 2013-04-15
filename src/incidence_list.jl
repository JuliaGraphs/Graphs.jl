
###########################################################
#
#   IncidenceList{V, E, VList, IncList}
#
#   V :         vertex type
#   VList :     the type of vertex list
#   IncList :   the type of incidence list
#               this maps each vertex to a list of 
#               edge indices
#
###########################################################

type IncidenceList{V, VList, IncList} <: AbstractGraph{V, Edge{V}}
    is_directed::Bool    
    vlist::VList
    nedges::Int
    inclist::IncList
end

typealias SimpleIncidenceList IncidenceList{Int, Range1{Int}, Vector{Vector{Edge{Int}}}}

function incidence_list(is_directed::Bool, nv::Int)
    inclist = Array(Vector{Edge{Int}}, nv)    
    for i = 1 : nv
        inclist[i] = Array(Edge{Int}, 0)
    end
    SimpleIncidenceList(is_directed, 1:nv, 0, inclist)
end

directed_incidence_list(nv::Int) = incidence_list(true, nv)
undirected_incidence_list(nv::Int) = incidence_list(false, nv)

@graph_implements IncidenceList vertex_list vertex_map edge_map adjacency_list incidence_list

# required interfaces

is_directed(g::IncidenceList) = g.is_directed

num_vertices(g::IncidenceList) = length(g.vlist)
vertices(g::IncidenceList) = g.vlist

num_edges(g::IncidenceList) = g.nedges

vertex_index(v, g::IncidenceList) = vertex_index(v)
edge_index(e, g::IncidenceList) = edge_index(e)

out_degree(v, g::IncidenceList) = length(g.inclist[v])
out_edges(v, g::IncidenceList) = g.inclist[v]

out_neighbors(v, g::IncidenceList) = out_neighbors_proxy(g.inclist[v])

# mutation

function add_edge!{V}(g::IncidenceList{V}, u::V, v::V)
    nv::Int = num_vertices(g)
    if !(u >= 1 && u <= nv && v >= 1 && v <= nv)
        throw(ArgumentError("u or v is not a valid vertex."))
    end
    ei::Int = (g.nedges += 1)
    push!(g.inclist[u], Edge(ei, u, v))
    
    if !g.is_directed
        push!(g.inclist[v], Edge(ei, v, u))
    end
end

