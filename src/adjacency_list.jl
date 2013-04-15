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
    nedges::Int
    adjlist::AList
end

typealias SimpleAdjacencyList AdjacencyList{Int, Range1{Int}, Vector{Vector{Int}}}

@graph_implements AdjacencyList vertex_list vertex_map adjacency_list

# constructing functions

function adjacency_list(is_directed::Bool, nv::Int)
    adjlist = Array(Vector{Int}, nv)
    for i = 1 : nv
        adjlist[i] = Int[]
    end
    SimpleAdjacencyList(is_directed, 1:nv, 0, adjlist)
end

directed_adjacency_list(nv::Int) = adjacency_list(true, nv)
undirected_adjacency_list(nv::Int) = adjacency_list(false, nv)

function adjacency_list(is_directed::Bool, nbs::Vector{Int}...)
    nv = length(nbs)
    adjlist = Array(Vector{Int}, nv)
    ne::Int = 0
    for i = 1 : nv
        adjlist[i] = nbs[i]
        ne += length(nbs[i])
    end
    SimpleAdjacencyList(is_directed, 1:nv, ne, adjlist)
end

directed_adjacency_list(nbs::Vector{Int}...) = adjacency_list(true, nbs...)
undirected_adjacency_list(nbs::Vector{Int}...) = adjacency_list(false, nbs...)

# required interfaces

is_directed(g::AdjacencyList) = g.is_directed

num_vertices(g::AdjacencyList) = length(g.vlist)
vertices(g::AdjacencyList) = g.vlist
vertex_index(v, g::AdjacencyList) = vertex_index(v)

num_edges(g::AdjacencyList) = g.nedges

out_degree(v, g::AdjacencyList) = length(g.adjlist[v])
out_neighbors(v, g::AdjacencyList) = g.adjlist[v]


# mutation

function add_edge!{V}(g::AdjacencyList{V}, u::V, v::V)
    nv::Int = num_vertices(g)
    if !(u >= 1 && u <= nv && v >= 1 && v <= nv)
        throw(ArgumentError("u or v is not a valid vertex."))
    end
    push!(g.adjlist[u], v)
    g.nedges += 1
    
    if !g.is_directed
        push!(g.adjlist[v], u)
    end
end


