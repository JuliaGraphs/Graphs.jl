
###########################################################
#
#  Directed Incidence List
#
#  vertices are implicitly considered as 1:nv
#
#  edges are stored as an array of vertex pairs
#
#  Each vertex also maintains a list of the indices of
#  incident edges 
#
###########################################################

type DirectedIncidenceList <: AbstractGraph{Int, (Int, Int)}
    nv::Int
    edges::Vector{(Int, Int)}
    inclist::Vector{Vector{Int}}
    
    function DirectedIncidenceList(edges::Vector{(Int, Int)}, inclist::Vector{Vector{Int}})
        new(length(inclist), edges, inclist)
    end
    
    function DirectedIncidenceList(nv::Int)
        inclist = Array(Vector{Int}, nv)
        for i = 1 : nv
            inclist[i] = Int[]
        end
        new(nv, Array((Int, Int), 0), inclist)
    end
end

@graph_implements DirectedIncidenceList vertex_list edge_list adjacency_list incidence_list

# required interfaces

is_directed(g::DirectedIncidenceList) = true

num_vertices(g::DirectedIncidenceList) = g.nv
num_edges(g::DirectedIncidenceList) = length(g.edges)
vertices(g::DirectedIncidenceList) = 1:g.nv
edges(g::DirectedIncidenceList) = g.edges

source(e::(Int, Int), g::DirectedIncidenceList) = e[1]
target(e::(Int, Int), g::DirectedIncidenceList) = e[2]

out_degree(v::Int, g::DirectedIncidenceList) = length(g.inclist[v])
out_edges(v::Int, g::DirectedIncidenceList) = vec_proxy(g.edges, g.inclist[v])

# out_neighbors proxy

type DIncOutNeighbors
    len::Int
    edges::Vector{(Int, Int)}
    inds::Vector{Int}
    
    function DIncOutNeighbors(v::Int, g::DirectedIncidenceList)
        inds::Vector{Int} = g.inclist[v]
        new(length(inds), g.edges, inds)
    end
end

length(proxy::DIncOutNeighbors) = proxy.len
isempty(proxy::DIncOutNeighbors) = proxy.len == 0
getindex(proxy::DIncOutNeighbors, i::Integer) = proxy.edges[proxy.inds[i]][2]

start(proxy::DIncOutNeighbors) = 1
next(proxy::DIncOutNeighbors, s::Int) = (proxy.edges[proxy.inds[s]][2], s+1)
done(proxy::DIncOutNeighbors, s::Int) =  s > proxy.len

out_neighbors(v::Int, g::DirectedIncidenceList) = DIncOutNeighbors(v, g)


# mutation

function add_edge!(g::DirectedIncidenceList, u::Int, v::Int)
    nv::Int = g.nv
    if !(u >= 1 && u <= nv && v >= 1 && v <= nv)
        throw(ArgumentError("u or v is not a valid vertex."))
    end
    push!(g.edges, (u, v))
    ei = length(g.edges) 
    push!(g.inclist[u], ei)
end

add_edge!(g::DirectedIncidenceList, e::(Int, Int)) = add_edge!(g, e[1], e[2])
