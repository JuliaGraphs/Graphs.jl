# adjacency list

#################################################
#
#  Simple Adjacency List
#
#  vertices are implicitly considered as 1:nv
#
#  adjacent vertices are stored as a vector of
#  vectors. 
#
#################################################

type SimpleAdjacencyList <: AbstractGraph{Int, (Int, Int)}
    is_directed::Bool
    nv::Int
    adjlist::Vector{Vector{Int}}
    
    function SimpleAdjacencyList(is_directed::Bool, adjlist::Vector{Vector{Int}})
        new(is_directed, length(adjlist), adjlist)
    end
    
    function SimpleAdjacencyList(is_directed::Bool, nv::Integer)
        adjlist = Array(Vector{Int}, nv)
        for i = 1 : nv
            adjlist[i] = Int[]
        end
        new(is_directed, int(nv), adjlist)
    end
    
    function SimpleAdjacencyList(is_directed::Bool, adjs::Vector{Int}...)
        nv = length(adjs)
        adjlist = Array(Vector{Int}, nv)
        for i = 1 : nv
            adjlist[i] = adjs[i]
        end
        new(is_directed, nv, adjlist)
    end
    
    SimpleAdjacencyList(adjlist::Vector{Vector{Int}}) = SimpleAdjacencyList(true, adjlist)
    SimpleAdjacencyList(nv::Integer) = SimpleAdjacencyList(true, nv)
    SimpleAdjacencyList(adjs::Vector{Int}...) = SimpleAdjacencyList(true, adjs...)
end

@graph_implements SimpleAdjacencyList vertex_list adjacency_list

    
# required interfaces

is_directed(g::SimpleAdjacencyList) = g.is_directed

num_vertices(g::SimpleAdjacencyList) = g.nv
vertices(g::SimpleAdjacencyList) = 1 : g.nv

source(e::(Int, Int), g::SimpleAdjacencyList) = e[1]
target(e::(Int, Int), g::SimpleAdjacencyList) = e[2]

out_degree(v::Int, g::SimpleAdjacencyList) = length(g.adjlist[v])
out_neighbors(v::Int, g::SimpleAdjacencyList) = g.adjlist[v]


# mutation

function add_edge!(g::SimpleAdjacencyList, u::Int, v::Int)
    nv::Int = g.nv
    if !(u >= 1 && u <= nv && v >= 1 && v <= nv)
        throw(ArgumentError("u or v is not a valid vertex."))
    end
    push!(g.adjlist[u], v)
    
    if !g.is_directed
        push!(g.adjlist[v], u)
    end
end

add_edge!(g::SimpleAdjacencyList, e::(Int, Int)) = add_edge!(g, e[1], e[2])





