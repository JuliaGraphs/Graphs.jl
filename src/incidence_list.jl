
###########################################################
#
#   IncidenceList{V, E, VList, IncList}
#
#   V :         vertex type
#   E :         edge type
#   VList :     the type of vertex list
#   IncList :   the type of incidence list
#
###########################################################

type IncidenceList{V, E, VList, IncList} <: AbstractGraph{V, E}
    is_directed::Bool
    vlist::VList
    inclist::IncList
end

typealias SimpleIncidenceList{E} IncidenceList{Int, E, Range1{Int}, Vector{Vector{E}}}

function incidence_list{E}(ty::Type{E}, is_directed::Bool, nv::Int)
    inclist = Array(Vector{E}, nv)
    for i = 1 : nv
        inclist[i] = Array(E, 0)
    end
    SimpleIncidenceList{E}(is_directed, 1:nv, inclist)
end

directed_incidence_list{E}(ty::Type{E}, nv::Int) = incidence_list(ty, true, nv)

@graph_implements IncidenceList vertex_list adjacency_list incidence_list

# required interfaces

is_directed(g::IncidenceList) = g.is_directed

num_vertices(g::IncidenceList) = length(g.vlist)
vertices(g::IncidenceList) = g.vlist

out_degree(v::Int, g::IncidenceList) = length(g.inclist[v])
out_edges(v::Int, g::IncidenceList) = g.inclist[v]

out_neighbors(v::Int, g::IncidenceList) = out_neighbors_proxy(g.inclist[v])

# mutation

function add_edge!(g::IncidenceList, e)
    u::Int = source(e)
    v::Int = target(e)
    nv::Int = num_vertices(g)
    if !(u >= 1 && u <= nv && v >= 1 && v <= nv)
        throw(ArgumentError("u or v is not a valid vertex."))
    end
    push!(g.inclist[u], e)
end
