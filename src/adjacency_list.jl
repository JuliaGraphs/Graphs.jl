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

type SimpleAdjacencyList <: AbstractAdjacencyGraph
    nv::Int
    is_directed::Bool
    adjlist::Vector{Vector{Int}}
    
    function SimpleAdjacencyList(adjlist::Vector{Vector{Int}}, is_directed::Bool)
        new(length(adjlist), is_directed, adjlist)
    end
    
    function SimpleAdjacencyList(nv::Integer, is_directed::Bool)
        adjlist = Array(Vector{Int}, nv)
        for i = 1 : nv
            adjlist[i] = Int[]
        end
        new(int(nv), is_directed, adjlist)
    end
    
    SimpleAdjacencyList(adjlist::Vector{Vector{Int}}) = SimpleAdjacencyList(adjlist, true)
    SimpleAdjacencyList(nv::Integer) = SimpleAdjacencyList(nv, true)
end

# required interfaces

vertex_type(g::SimpleAdjacencyList) = Int
edge_type(g::SimpleAdjacencyList) = (Int, Int)

is_directed(g::SimpleAdjacencyList) = g.is_directed

num_vertices(g::SimpleAdjacencyList) = g.nv
vertices(g::SimpleAdjacencyList) = 1 : g.nv

out_degree(v::Int, g::SimpleAdjacencyList) = length(g.adjlist[v])
out_neighbors(v::Int, g::SimpleAdjacencyList) = g.adjlist[v]

# additional construction routine

simple_adjlist(adjs::Vector{Int}...) = SimpleSimpleAdjacencyList([adjs...])

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





