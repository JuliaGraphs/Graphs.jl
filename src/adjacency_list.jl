# adjacency list

#################################################
#
#  AdjacencyList{V, VList, AList}
#
#   V:          vertex type
#   VList:      the type of vertex list
#   AList:      the type of adjacency list
#
#   Let a be an instance of AList, and v be an
#   instance of v,
#
#   Then a[v] should be an iterable container
#   of V.
#
#################################################

type AdjacencyList{V, VList, AList} <: AbstractGraph{V, Edge{V}}
    is_directed::Bool
    vlist::VList
    adjlist::AList
end

typealias SimpleAdjacencyList AdjacencyList{Int, Range1{Int}, Vector{Vector{Int}}}

@graph_implements AdjacencyList vertex_list adjacency_list

# constructing functions

function adjacency_list(is_directed::Bool, nv::Int)
    adjlist = Array(Vector{Int}, nv)
    for i = 1 : nv
        adjlist[i] = Int[]
    end
    SimpleAdjacencyList(is_directed, 1:nv, adjlist)
end

directed_adjacency_list(nv::Int) = adjacency_list(true, nv)
undirected_adjacency_list(nv::Int) = adjacency_list(false, nv)

function adjacency_list(is_directed::Bool, nbs::Vector{Int}...)
    nv = length(nbs)
    adjlist = Array(Vector{Int}, nv)
    for i = 1 : nv
        adjlist[i] = nbs[i]
    end
    SimpleAdjacencyList(is_directed, 1:nv, adjlist)
end

directed_adjacency_list(nbs::Vector{Int}...) = adjacency_list(true, nbs...)
undirected_adjacency_list(nbs::Vector{Int}...) = adjacency_list(false, nbs...)

# required interfaces

is_directed(g::AdjacencyList) = g.is_directed

num_vertices(g::AdjacencyList) = length(g.vlist)
vertices(g::AdjacencyList) = g.vlist

out_degree(v::Int, g::AdjacencyList) = length(g.adjlist[v])
out_neighbors(v::Int, g::AdjacencyList) = g.adjlist[v]

# mutation

function add_edge!(g::AdjacencyList, u::Int, v::Int)
    nv::Int = num_vertices(g)
    if !(u >= 1 && u <= nv && v >= 1 && v <= nv)
        throw(ArgumentError("u or v is not a valid vertex."))
    end
    push!(g.adjlist[u], v)
    
    if !g.is_directed
        push!(g.adjlist[v], u)
    end
end

add_edge!(g::AdjacencyList, e::Edge{Int}) = add_edge!(g, e.source, e.target)

