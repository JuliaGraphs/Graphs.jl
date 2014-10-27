###########################################################
#
#   Generic matrix generation functions
#
###########################################################

function matrix_from_adjpairs!(a::AbstractMatrix, g::AbstractGraph, gen)
    @graph_requires g vertex_list vertex_map

    if implements_edge_list(g)
        if is_directed(g)
            for e in edges(g)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                a[ui, vi] = get(gen, g, u, v)
            end
        else
            for e in edges(g)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                val = get(gen, g, u, v)
                a[ui, vi] = val
                a[vi, ui] = val
            end
        end

    elseif implements_adjacency_list(g)
        for u in vertices(g)
            ui = vertex_index(u, g)
            for v in out_neighbors(u, g)
                vi = vertex_index(v, g)
                val = get(gen, g, u, v)
                a[ui, vi] = val
            end
        end
    else
        error("g does not implement required interface.")
    end

    return a
end

matrix_from_adjpairs(g::AbstractGraph, gen) =
    (n = num_vertices(g); matrix_from_adjpairs!(zeros(eltype(gen), n, n), g, gen))


function sparse_matrix_from_adjpairs(g::AbstractGraph, gen)
    @graph_requires g vertex_list vertex_map

    n = num_vertices(g)
    m = num_edges(g)
    ne = is_directed(g) ? m : 2m
    I = Array(Int, ne)
    J = Array(Int, ne)
    vals = Array(eltype(gen), ne)
    idx = 0

    if implements_edge_list(g)
        if is_directed(g)
            for e in edges(g)
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
            for e in edges(g)
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

    elseif implements_adjacency_list(g)
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
    end

    @assert(idx == ne)
    sparse(I, J, vals, n, n)
end


function matrix_from_edges!(a::AbstractMatrix, g::AbstractGraph, gen)
    @graph_requires g vertex_list vertex_map

    if implements_edge_list(g)
        if is_directed(g)
            for e in edges(g)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                val = get(gen, g, e)
                a[ui, vi] = val
            end
        else
            for e in edges(g)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                val = get(gen, g, e)
                a[ui, vi] = val
                a[vi, ui] = val
            end
        end

    elseif implements_incidence_list(g)
        for u in vertices(g)
            ui = vertex_index(u, g)
            for e in out_edges(u, g)
                v = target(e, g)
                vi = vertex_index(v, g)
                val = get(gen, g, e)
                a[ui, vi] = val
            end
        end
    else
        error("g does not implement required interface.")
    end

    return a
end

matrix_from_edges(g::AbstractGraph, gen) =
    (n = num_vertices(g); matrix_from_edges!(zeros(eltype(gen), n, n), g, gen))

function sparse_matrix_from_edges(g::AbstractGraph, gen)
    @graph_requires g vertex_list vertex_map

    n = num_vertices(g)
    m = num_edges(g)
    ne = is_directed(g) ? m : 2m
    I = Array(Int, ne)
    J = Array(Int, ne)
    vals = Array(eltype(gen), ne)
    idx = 0

    if implements_edge_list(g)
        if is_directed(g)
            for e in edges(g)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
                vi = vertex_index(v, g)
                val = get(gen, g, e)

                idx += 1
                I[idx] = ui
                J[idx] = vi
                vals[idx] = val
            end
        else
            for e in edges(g)
                u = source(e, g)
                v = target(e, g)
                ui = vertex_index(u, g)
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

    elseif implements_incidence_list(g)
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

function init_distancemat{T<:Number}(n::Int, dinf::T)
    a = fill(dinf, n, n)
    @inbounds for i = 1:n
        a[i,i] = zero(T)
    end
    return a
end

distance_matrix(g::AbstractGraph, dists::AbstractVector, dinf) =
    (n = num_vertices(g); matrix_from_edges!(init_distancemat(n, dinf), g, _GenEdgeWeight(dists)))

distance_matrix{T<:Real}(g::AbstractGraph, dists::AbstractVector{T}) =
    distance_matrix(g, dists, typemax(T))


###########################################################
#
#   Laplacian matrix
#
###########################################################

laplacian_matrix(g::AbstractGraph) = laplacian_matrix(g, Float64)

function laplacian_matrix{T<:Number}(g::AbstractGraph, ::Type{T})
    @graph_requires g vertex_list vertex_map
    !is_directed(g) || error("g must be undirected.")

    n = num_vertices(g)
    a = zeros(T, n, n)

    if implements_edge_list(g)
        for e in edges(g)
            u = source(e, g)
            v = target(e, g)
            ui = vertex_index(u, g)
            vi = vertex_index(v, g)
            if ui != vi
                a[ui, vi] -= 1
                a[vi, ui] -= 1
                a[ui, ui] += 1
                a[vi, vi] += 1
            end
        end
    elseif implements_adjacency_list(g)
        for u in vertices(g)
            ui = vertex_index(u, g)
            for v in out_neighbors(u, g)
                vi = vertex_index(v, g)
                if ui < vi
                    a[ui, vi] -= 1
                    a[vi, ui] -= 1
                    a[ui, ui] += 1
                    a[vi, vi] += 1
                end
            end
        end
    else
        error("g does not implement proper interface.")
    end
    return a
end

function laplacian_matrix{T<:Number}(g::AbstractGraph, eweights::AbstractVector{T})
    @graph_requires g vertex_list vertex_map edge_map
    !is_directed(g) || error("g must be undirected.")

    n = num_vertices(g)
    a = zeros(T, n, n)

    if implements_edge_list(g)
        for e in edges(g)
            u = source(e, g)
            v = target(e, g)
            ui = vertex_index(u, g)
            vi = vertex_index(v, g)
            if ui != vi
                wi = eweights[edge_index(e, g)]
                a[ui, vi] -= wi
                a[vi, ui] -= wi
                a[ui, ui] += wi
                a[vi, vi] += wi
            end
        end
    else
        for u in vertices(g)
            ui = vertex_index(u, g)
            for e in out_edges(u, g)
                v = target(e, g)
                vi = vertex_index(v, g)
                if ui < vi
                    wi = eweights[edge_index(e, g)]
                    a[ui, vi] -= wi
                    a[vi, ui] -= wi
                    a[ui, ui] += wi
                    a[vi, vi] += wi
                end
            end
        end
    end
    return a
end


laplacian_matrix_sparse(g::AbstractGraph) = laplacian_matrix_sparse(g, Float64)

function laplacian_matrix_sparse{T<:Number}(g::AbstractGraph, ::Type{T})
    @graph_requires g vertex_list vertex_map
    !is_directed(g) || error("g must be undirected.")

    n = num_vertices(g)
    a = zeros(T, n, n)

    nnz = num_edges(g) * 2 + n
    I = Array(Int, nnz)
    J = Array(Int, nnz)
    vals = Array(T, nnz)
    idx = 0

    degs = zeros(T, n)

    if implements_edge_list(g)
        for e in edges(g)
            u = source(e, g)
            v = target(e, g)
            ui = vertex_index(u, g)
            vi = vertex_index(v, g)
            if ui != vi
                idx += 1
                I[idx] = ui
                J[idx] = vi
                vals[idx] = -1

                idx += 1
                I[idx] = vi
                J[idx] = ui
                vals[idx] = -1

                degs[ui] += 1
                degs[vi] += 1
            end
        end
    elseif implements_adjacency_list(g)
        for u in vertices(g)
            ui = vertex_index(u, g)
            for v in out_neighbors(u, g)
                vi = vertex_index(v, g)
                if ui < vi
                    idx += 1
                    I[idx] = ui
                    J[idx] = vi
                    vals[idx] = -1

                    idx += 1
                    I[idx] = vi
                    J[idx] = ui
                    vals[idx] = -1

                    degs[ui] += 1
                    degs[vi] += 1
                end
            end
        end
    else
        error("g does not implement proper interface.")
    end

    for i = 1:n
        di = degs[i]
        if isnz(di)
            idx += 1
            I[idx] = i
            J[idx] = i
            vals[idx] = di
        end
    end

    if idx < nnz
        I = I[1:idx]
        J = J[1:idx]
        vals = vals[1:idx]
    end
    sparse(I, J, vals, n, n)
end


function laplacian_matrix_sparse{T<:Number}(g::AbstractGraph, eweights::AbstractVector{T})
    @graph_requires g vertex_list vertex_map edge_map
    !is_directed(g) || error("g must be undirected.")

    n = num_vertices(g)
    a = zeros(T, n, n)

    nnz = num_edges(g) * 2 + n
    I = Array(Int, nnz)
    J = Array(Int, nnz)
    vals = Array(T, nnz)
    idx = 0

    degs = zeros(T, n)

    if implements_edge_list(g)
        for e in edges(g)
            u = source(e, g)
            v = target(e, g)
            ui = vertex_index(u, g)
            vi = vertex_index(v, g)
            if ui != vi
                wi = eweights[edge_index(e, g)]
                idx += 1
                I[idx] = ui
                J[idx] = vi
                vals[idx] = -wi

                idx += 1
                I[idx] = vi
                J[idx] = ui
                vals[idx] = -wi

                degs[ui] += wi
                degs[vi] += wi
            end
        end
    elseif implements_adjacency_list(g)
        for u in vertices(g)
            ui = vertex_index(u, g)
            for e in out_edges(u, g)
                v = target(e, g)
                vi = vertex_index(v, g)
                if ui < vi
                    wi = eweights[edge_index(e, g)]
                    idx += 1
                    I[idx] = ui
                    J[idx] = vi
                    vals[idx] = -wi

                    idx += 1
                    I[idx] = vi
                    J[idx] = ui
                    vals[idx] = -wi

                    degs[ui] += wi
                    degs[vi] += wi
                end
            end
        end
    else
        error("g does not implement proper interface.")
    end

    for i = 1:n
        di = degs[i]
        if isnz(di)
            idx += 1
            I[idx] = i
            J[idx] = i
            vals[idx] = di
        end
    end

    if idx < nnz
        I = I[1:idx]
        J = J[1:idx]
        vals = vals[1:idx]
    end
    sparse(I, J, vals, n, n)
end


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
