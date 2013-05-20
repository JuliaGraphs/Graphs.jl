# adjacency list

#################################################
#
#   GenericAdjacencyList{V, VList, AList}
#
#   V:          vertex type
#   VList:      the type of vertex list
#   AdjList:    adjacency list
#
#################################################

type GenericAdjacencyList{V, VList, AdjList} <: AbstractGraph{V, Edge{V}}
    is_directed::Bool
    vertices::VList
    nedges::Int
    adjlist::AdjList
end

typealias SimpleAdjacencyList GenericAdjacencyList{Int, Range1{Int}, Vector{Vector{Int}}}
typealias AdjacencyList{V} GenericAdjacencyList{V, Vector{V}, Vector{Vector{V}}}

@graph_implements GenericAdjacencyList vertex_list vertex_map adjacency_list


# required interfaces

is_directed(g::GenericAdjacencyList) = g.is_directed

num_vertices(g::GenericAdjacencyList) = length(g.vertices)
vertices(g::GenericAdjacencyList) = g.vertices
vertex_index(v, g::GenericAdjacencyList) = vertex_index(v)

num_edges(g::GenericAdjacencyList) = g.nedges

out_degree(v, g::GenericAdjacencyList) = length(g.adjlist[vertex_index(v)])
out_neighbors(v, g::GenericAdjacencyList) = g.adjlist[vertex_index(v)]

# mutation

function add_vertex!{V}(g::AdjacencyList{V}, v::V)
    nv::Int = num_vertices(g)
    iv::Int = vertex_index(v)
    if iv != nv + 1
        throw(ArgumentError("Invalid vertex index."))
    end        
    
    push!(g.vertices, v)
    push!(g.adjlist, Array(V,0))
    v
end

function add_vertex!{K}(g::AdjacencyList{KeyVertex{K}}, key::K)
    nv::Int = num_vertices(g)
    v = KeyVertex(nv+1, key)
    push!(g.vertices, v)
    push!(g.adjlist, Array(KeyVertex{K},0))
    v
end


function add_edge!{V}(g::GenericAdjacencyList{V}, u::V, v::V)
    nv::Int = num_vertices(g)
    iu::Int = vertex_index(u, g)
    iv::Int = vertex_index(v, g)
    
    if iu < 1 || iu > nv || iv < 1 || iv > nv
        throw(ArgumentError("The vertex u or v is invalid."))
    end
    
    push!(g.adjlist[iu], v)
    g.nedges += 1
    
    if !g.is_directed
        push!(g.adjlist[iv], u)
    end
end


# constructing functions

function simple_adjlist(nv::Int; is_directed::Bool=true)
    alist = Array(Vector{Int}, nv)
    for i = 1 : nv
        alist[i] = Int[]
    end
    SimpleAdjacencyList(is_directed, 1:nv, 0, alist)
end

function simple_adjlist(nbs::AbstractVector; is_directed::Bool=true)
    nv = length(nbs)
    alist = Array(Vector{Int}, nv)
    ne::Int = 0
    for i = 1 : nv
        alist[i] = nbs[i]
        ne += length(nbs[i])
    end
    SimpleAdjacencyList(is_directed, 1:nv, ne, alist)
end

function simple_adjlist(A::Union(BitArray{2}, Matrix{Bool}); is_directed::Bool=true)
    nv = size(A, 1)
    if size(A, 2) != nv
        error("A must be square")
    end
    nbrs = Array(Vector{Int}, nv)
    row = Array(Int, 0)
    sizehint(row, nv)
    for i = 1:nv
        for j = 1:nv
            if A[i,j]
                push!(row, j)
            end
        end
        nbrs[i] = copy(row)
        empty!(row)
    end
    simple_adjlist(nbrs, is_directed = is_directed)
end

function adjlist{V}(vty::Type{V}; is_directed::Bool=true)
    vlist = Array(V, 0)
    alist = Array(Vector{V}, 0)
    AdjacencyList{V}(is_directed, vlist, 0, alist)
end

