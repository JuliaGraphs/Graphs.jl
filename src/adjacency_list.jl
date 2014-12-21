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

## construction

simple_adjlist(nv::Int; is_directed::Bool=true) = SimpleAdjacencyList(is_directed, 1:nv, 0, multivecs(Int, nv))

adjlist{V}(vs::Vector{V}; is_directed::Bool=true) = AdjacencyList{V}(is_directed, vs, 0, Vector{V}[])
adjlist{V}(::Type{V}; is_directed::Bool=true) = adjlist(V[]; is_directed=is_directed)

## required interfaces

is_directed(g::GenericAdjacencyList) = g.is_directed

num_vertices(g::GenericAdjacencyList) = length(g.vertices)
vertices(g::GenericAdjacencyList) = g.vertices

num_edges(g::GenericAdjacencyList) = g.nedges

out_degree{V}(v::V, g::GenericAdjacencyList{V}) = length(g.adjlist[vertex_index(v,g)])
out_neighbors{V}(v::V, g::GenericAdjacencyList{V}) = g.adjlist[vertex_index(v,g)]


## mutation

function add_vertex!{V}(g::GenericAdjacencyList{V}, v::V)
    push!(g.vertices, v)
    push!(g.adjlist, Array(V,0))
    v
end
add_vertex!(g::GenericAdjacencyList, x) = add_vertex!(g, make_vertex(g, x))

function add_edge!{V}(g::GenericAdjacencyList{V}, u::V, v::V)
    nv::Int = num_vertices(g)
    iu = vertex_index(u, g)::Int
    push!(g.adjlist[iu], v)
    g.nedges += 1
    if !g.is_directed
        iv = vertex_index(v, g)::Int
        push!(g.adjlist[iv], u)
    end
end


## constructing from matrices

function simple_adjlist{T<:Number}(A::AbstractMatrix{T}; is_directed::Bool=true)
    n = size(A, 1)
    size(A, 2) == n || error("A must be square")
    alist = multivecs(Int, n)
    m = 0

    @inbounds if is_directed
        for i = 1:n
            nbs = alist[i]::Vector{Int}
            for j = 1:n
                if isnz(A[i,j])
                    push!(nbs, j)
                    m += 1
                end
            end
        end
    else
        for i = 1:n
            nbs = alist[i]::Vector{Int}
            if isnz(A[i,i])
                push!(nbs, i)
                m += 1
            end
            for j = i+1:n
                if isnz(A[i,j])
                    push!(nbs, j)
                    push!(alist[j], i)
                    m += 1
                end
            end
        end
    end
    return SimpleAdjacencyList(is_directed, 1:n, m, alist)
end
