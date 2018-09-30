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

mutable struct GenericAdjacencyList{V, VList, AdjList} <: AbstractGraph{V, Edge{V}}
    is_directed::Bool
    vertices::VList
    nedges::Int
    adjlist::AdjList
end

const SimpleAdjacencyList = GenericAdjacencyList{Int, UnitRange{Int}, Vector{Vector{Int}}}
const AdjacencyList{V} = GenericAdjacencyList{V, Vector{V}, Vector{Vector{V}}}

@graph_implements GenericAdjacencyList vertex_list vertex_map adjacency_list

## construction

simple_adjlist(nv::Int; is_directed::Bool=true) = SimpleAdjacencyList(is_directed, 1:nv, 0, multivecs(Int, nv))

adjlist(vs::Vector{V}; is_directed::Bool=true) where {V} = AdjacencyList{V}(is_directed, vs, 0, multivecs(V,length(vs)))
adjlist(::Type{V}; is_directed::Bool=true) where {V} = adjlist(V[]; is_directed=is_directed)

## required interfaces

is_directed(g::GenericAdjacencyList) = g.is_directed

num_vertices(g::GenericAdjacencyList) = length(g.vertices)
vertices(g::GenericAdjacencyList) = g.vertices

num_edges(g::GenericAdjacencyList) = g.nedges

out_degree(v::V, g::GenericAdjacencyList{V}) where {V} = length(g.adjlist[vertex_index(v,g)])
out_neighbors(v::V, g::GenericAdjacencyList{V}) where {V} = g.adjlist[vertex_index(v,g)]


## mutation

function add_vertex!(g::GenericAdjacencyList{V}, v::V) where {V}
    push!(g.vertices, v)
    push!(g.adjlist, Array{V}(undef, 0))
    v
end
add_vertex!(g::GenericAdjacencyList, x) = add_vertex!(g, make_vertex(g, x))

function add_edge!(g::GenericAdjacencyList{V}, u::V, v::V) where {V}
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

function simple_adjlist(A::AbstractMatrix{T}; is_directed::Bool=true) where {T<:Number}
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
