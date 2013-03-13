# adjacency list

#################################################
#
#  Adjacency List
#
#  vertices are implicitly considered as 1:nv
#
#  adjacent vertices are stored as a vector of
#  vectors. 
#
#################################################

type AdjacencyList <: AbstractGraph{Int, (Int, Int)}
    is_directed::Bool
    nv::Int
    adjlist::Vector{Vector{Int}}
    
    function AdjacencyList(is_directed::Bool, adjlist::Vector{Vector{Int}})
        new(is_directed, length(adjlist), adjlist)
    end
    
    function AdjacencyList(is_directed::Bool, nv::Integer)
        adjlist = Array(Vector{Int}, nv)
        for i = 1 : nv
            adjlist[i] = Int[]
        end
        new(is_directed, int(nv), adjlist)
    end
    
    function AdjacencyList(is_directed::Bool, adjs::Vector{Int}...)
        nv = length(adjs)
        adjlist = Array(Vector{Int}, nv)
        for i = 1 : nv
            adjlist[i] = adjs[i]
        end
        new(is_directed, nv, adjlist)
    end
    
    AdjacencyList(adjlist::Vector{Vector{Int}}) = AdjacencyList(true, adjlist)
    AdjacencyList(nv::Integer) = AdjacencyList(true, nv)
    AdjacencyList(adjs::Vector{Int}...) = AdjacencyList(true, adjs...)
end

@graph_implements AdjacencyList vertex_list adjacency_list

    
# required interfaces

is_directed(g::AdjacencyList) = g.is_directed

num_vertices(g::AdjacencyList) = g.nv
vertices(g::AdjacencyList) = 1 : g.nv

out_degree(v::Int, g::AdjacencyList) = length(g.adjlist[v])
out_neighbors(v::Int, g::AdjacencyList) = g.adjlist[v]

# mutation

function add_edge!(g::AdjacencyList, u::Int, v::Int)
    nv::Int = g.nv
    if !(u >= 1 && u <= nv && v >= 1 && v <= nv)
        throw(ArgumentError("u or v is not a valid vertex."))
    end
    push!(g.adjlist[u], v)
    
    if !g.is_directed
        push!(g.adjlist[v], u)
    end
end

add_edge!(g::AdjacencyList, e::Edge{Int}) = add_edge!(g, e.source, e.target)

