###########################################################
#
#   Generic matrix generation functions
#
###########################################################

function matrix_from_adjpairs!(a::AbstractMatrix, g::AbstractGraph, gen)
    @graph_requires g vertex_list vertex_map

    if implements_edge_list(graph)
        if is_directed(graph)
            for e in edges(graph)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                a[ui, vi] = get(gen, g, u, v)
            end
        else
            for e in edges(graph)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                val = get(gen, g, u, v)
                a[ui, vi] = val
                a[vi, ui] = val
            end
        end

    elseif implements_incidence_list(graph)
        if is_directed(graph)
            for u in vertices(g)
                ui = vertex_index(u, g)
                for e in out_edges(u, g)
                    v = target(e, g)
                    vi = vertex_index(v, g)
                    a[ui, vi] = get(gen, g, u, v)
                end
            end
        else
            for u in vertices(g)
                ui = vertex_index(u, g)
                for e in out_edges(u, g)
                    v = target(e, g)
                    vi = vertex_index(v, g)
                    val = get(gen, g, u, v)
                    a[ui, vi] = val
                    a[vi, ui] = val
                end
            end
        end

    elseif implements_adjacency_list(graph)
        if is_directed(graph)
            for u in vertices(g)
                ui = vertex_index(u, g)
                for v in out_neighbors(u, g)
                    vi = vertex_index(v, g)
                    a[ui, vi] = get(gen, g, u, v)
                end
            end
        else
            for u in vertices(g)
                ui = vertex_index(u, g)
                for v in out_neighbors(u, g)
                    vi = vertex_index(v, g)
                    val = get(gen, g, u, v)
                    a[ui, vi] = val
                    a[vi, ui] = val
                end                
            end
        end
    else
        error("graph does not implement required interface.")
    end

    return a
end

matrix_from_adjpairs(g::AbstractGraph, gen) = 
    (n = num_vertices(g); adjacency_matrix!(zeros(eltype(g), n, n), g, gen))


function sparse_matrix_from_adjpairs(g::AbstractGraph, gen)
    @graph_requires graph vertex_list vertex_map

    n = num_vertices(g)
    m = num_edges(g)
    ne = is_directed(g) ? m : 2m
    I = Array(Int, ne)
    J = Array(Int, ne)
    vals = Array(eltype(g), ne)
    idx = 0

    if implements_edge_list(graph)
        if is_directed(graph)
            for e in edges(graph)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                val = get(gen, g, u, v)

                idx += 1
                I[idx] = ui
                J[idx] = vi
                vals[idx] = val
            end
        else
            for e in edges(graph)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                val = get(gen, g, u, v)
                
                idx += 1
                I[idx] = ui
                J[idx] = vi
                vals[idx] = val

                idx += 1
                I[idx] = vi
                J[idx] = ui
                vals[idx] = val
            end
        end

    elseif implements_incidence_list(graph)
        if is_directed(graph)
            for u in vertices(g)
                ui = vertex_index(u, g)
                for e in out_edges(u, g)
                    v = target(e, g)
                    vi = vertex_index(v, g)
                    val = get(gen, g, u, v)
                    
                    idx += 1
                    I[idx] = ui
                    J[idx] = vi
                    vals[idx] = val
                end
            end
        else
            for u in vertices(g)
                ui = vertex_index(u, g)
                for e in out_edges(u, g)
                    v = target(e, g)
                    vi = vertex_index(v, g)
                    val = get(gen, g, u, v)
                    
                    idx += 1
                    I[idx] = ui
                    J[idx] = vi
                    vals[idx] = val

                    idx += 1
                    I[idx] = vi
                    J[idx] = ui
                    vals[idx] = val
                end
            end
        end

    elseif implements_adjacency_list(graph)
        if is_directed(graph)
            for u in vertices(g)
                ui = vertex_index(u, g)
                for v in out_neighbors(u, g)
                    vi = vertex_index(v, g)
                    val = get(gen, g, u, v)
                    
                    idx += 1
                    I[idx] = ui
                    J[idx] = vi
                    vals[idx] = val
                end
            end
        else
            for u in vertices(g)
                ui = vertex_index(u, g)
                for v in out_neighbors(u, g)
                    vi = vertex_index(v, g)
                    val = get(gen, g, u, v)

                    idx += 1
                    I[idx] = ui
                    J[idx] = vi
                    vals[idx] = val

                    idx += 1
                    I[idx] = vi
                    J[idx] = ui
                    vals[idx] = val
                end                
            end
        end
    end

    @assert(idx == ne)
    sparse(I, J, vals, n, n)
end


function matrix_from_edges!(a::AbstractMatrix, g::AbstractGraph, gen)
    @graph_requires g vertex_list vertex_map

    if implements_edge_list(graph)
        if is_directed(graph)
            for e in edges(graph)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                a[ui, vi] = get(gen, g, e)
            end
        else
            for e in edges(graph)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                val = get(gen, g, e)
                a[ui, vi] = val
                a[vi, ui] = val
            end
        end

    elseif implements_incidence_list(graph)
        if is_directed(graph)
            for u in vertices(g)
                ui = vertex_index(u, g)
                for e in out_edges(u, g)
                    v = target(e, g)
                    vi = vertex_index(v, g)
                    a[ui, vi] = get(gen, g, e)
                end
            end
        else
            for u in vertices(g)
                ui = vertex_index(u, g)
                for e in out_edges(u, g)
                    v = target(e, g)
                    vi = vertex_index(v, g)
                    val = get(gen, g, e)
                    a[ui, vi] = val
                    a[vi, ui] = val
                end
            end
        end
    else
        error("graph does not implement required interface.")
    end

    return a
end


function sparse_matrix_from_edges(g::AbstractGraph, gen)
    @graph_requires graph vertex_list vertex_map

    n = num_vertices(g)
    m = num_edges(g)
    ne = is_directed(g) ? m : 2m
    I = Array(Int, ne)
    J = Array(Int, ne)
    vals = Array(eltype(g), ne)
    idx = 0

    if implements_edge_list(graph)
        if is_directed(graph)
            for e in edges(graph)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                val = get(gen, g, u, v)

                idx += 1
                I[idx] = ui
                J[idx] = vi
                vals[idx] = val
            end
        else
            for e in edges(graph)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                val = get(gen, g, u, v)
                
                idx += 1
                I[idx] = ui
                J[idx] = vi
                vals[idx] = val

                idx += 1
                I[idx] = vi
                J[idx] = ui
                vals[idx] = val
            end
        end

    elseif implements_incidence_list(graph)
        if is_directed(graph)
            for u in vertices(g)
                ui = vertex_index(u, g)
                for e in out_edges(u, g)
                    v = target(e, g)
                    vi = vertex_index(v, g)
                    val = get(gen, g, e)
                    
                    idx += 1
                    I[idx] = ui
                    J[idx] = vi
                    vals[idx] = val
                end
            end
        else
            for u in vertices(g)
                ui = vertex_index(u, g)
                for e in out_edges(u, g)
                    v = target(e, g)
                    vi = vertex_index(v, g)
                    val = get(gen, g, e)
                    
                    idx += 1
                    I[idx] = ui
                    J[idx] = vi
                    vals[idx] = val

                    idx += 1
                    I[idx] = vi
                    J[idx] = ui
                    vals[idx] = val
                end
            end
        end
    end

    @assert(idx == ne)
    sparse(I, J, vals, n, n)
end



###########################################################
#
#   Specific matrices from graphs
#
###########################################################

### adjacency matrix

type _GenUnit{T} end

Base.get{T,V}(::_GenUnit{T}, g::AbstractGraph{V}, u::V, v::V) = one(T)
Base.eltype{T}(::_GenUnit{T}) = T

adjacency_matrix{T<:Number}(g::AbstractGraph, ::Type{T}) = matrix_from_adjpairs(g, _GenUnit{T}())
adjacency_matrix(g::AbstractGraph) = adjacency_matrix(g, Bool)

adjacency_matrix_sparse{T<:Number}(g::AbstractGraph, ::Type{T}) = sparse_matrix_from_adjpairs(g, _GenUnit{T}())
adjacency_matrix_sparse(g::AbstractGraph) = adjacency_matrix_sparse(g, Bool)

### weight matrix
    
type _GenEdgeWeight{Weights}
    weights::Weights
end

_GenEdgeWeight(weights::AbstractVector) = _GenEdgeWeight{typeof(weights)}(weights)

Base.get{V,E}(gen::_GenEdgeWeight, g::AbstractGraph{V,E}, e::E) = gen.weights[edge_index(e, g)]
Base.eltype(gen::_GenEdgeWeight) = eltype(gen.weights)

weight_matrix(g::AbstractGraph, weights::AbstractVector) = matrix_from_edges(g, _GenEdgeWeight(weights))
weight_matrix_sparse(g::AbstractGraph, weights::AbstractVector) = sparse_matrix_from_edges(g, _GenEdgeWeight(weights))

### distance matrix

distance_matrix(g::AbstractGraph, dists::AbstractVector, d0) = 
    (n = num_vertices(g); matrix_from_edges!(fill(d0, n, n), g, _GenEdgeWeight(dists)))

distance_matrix{T<:Real}(g::AbstractGraph, dists::AbstractVector{T}) = 
    distance_matrix(g, dists, typemax(T))

### laplacian matrix

type _GenLaplacian{T} end

Base.get{T,V}(::_GenLaplacian{T}, g::AbstractGraph{V}, u::V, v::V) = 
    convert(T, vertex_index(u) == vertex_index(v) ? out_degree(u, g) : -1)
Base.eltype{T}(::_GenLaplacian{T}) = T

laplacian_matrix{T<:Number}(g::AbstractGraph, ::Type{T}) = matrix_from_adjpairs(g, _GenLaplacian{T}())
laplacian_matrix(g::AbstractGraph) = laplacian_matrix(g, Float64)

laplacian_matrix_sparse{T<:Number}(g::AbstractGraph, ::Type{T}) = sparse_matrix_from_adjpairs(g, _GenLaplacian{T}())
laplacian_matrix_sparse(g::AbstractGraph) = laplacian_matrix_sparse(g, Float64)

## TODO: weighted laplacian matrix 


###########################################################
#
#   adjacency list from matrix
#
###########################################################

function sparse2adjacencylist{Tv,Ti<:Integer}(A::SparseMatrixCSC{Tv,Ti})
    colptr = A.colptr
    rowval = A.rowval
    n = size(A, 1)
    adjlist = Array(Array{Ti,1}, n)
    s = 0
    for j in 1:n
        adjj = Ti[]
        sizehint(adjj, colptr[j+1] - colptr[j] - 1)
        for k in colptr[j]:(colptr[j+1] - 1)
            rvk = A.rowval[k]
            if rvk != j push!(adjj, rvk) end
        end
        s += length(adjj)
        adjlist[j] = adjj
    end
    GenericAdjacencyList{Ti, Range1{Ti}, Vector{Vector{Ti}}}(!ishermitian(A),
                                                             one(Ti):convert(Ti,n),
                                                             s, adjlist)
end
