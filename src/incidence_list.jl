
###########################################################
#
#  Directed Incidence List
#
#  vertices are implicitly considered as 1:nv
#
#  Each vertex also maintains a list of the indices of
#  incident edges 
#
###########################################################

type DirectedIncidenceList{E} <: AbstractGraph{Int, E}
    nv::Int
    inclist::Vector{Vector{E}}
    
    function DirectedIncidenceList(inclist::Vector{Vector{E}})
        new(length(inclist), inclist)
    end
end

function directed_incidence_list{E}(ty::Type{E}, nv::Int)
    inclist = Array(Vector{E}, nv)
    for i = 1 : nv
        inclist[i] = Array(E, 0)
    end
    DirectedIncidenceList{E}(inclist)
end

@graph_implements DirectedIncidenceList vertex_list adjacency_list incidence_list

# required interfaces

is_directed(g::DirectedIncidenceList) = true

num_vertices(g::DirectedIncidenceList) = g.nv
vertices(g::DirectedIncidenceList) = 1:g.nv

out_degree(v::Int, g::DirectedIncidenceList) = length(g.inclist[v])
out_edges(v::Int, g::DirectedIncidenceList) = g.inclist[v]

out_neighbors(v::Int, g::DirectedIncidenceList) = out_neighbors_proxy(g.inclist[v])

# mutation

function add_edge!{E}(g::DirectedIncidenceList{E}, e::E)
    u::Int = source(e)
    v::Int = target(e)
    nv::Int = g.nv
    if !(u >= 1 && u <= nv && v >= 1 && v <= nv)
        throw(ArgumentError("u or v is not a valid vertex."))
    end
    push!(g.inclist[u], e)
end

