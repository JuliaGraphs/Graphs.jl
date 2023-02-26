# This file provides reexported functions.

using ArnoldiMethod
using SparseArrays

"""
    adjacency_matrix(g[, T=Int; dir=:out])

Return a sparse adjacency matrix for a graph, indexed by `[u, v]`
vertices. Non-zero values indicate an edge from `u` to `v`. Users may
override the default data type (`Int`) and specify an optional direction.

### Optional Arguments
`dir=:out`: `:in`, `:out`, or `:both` are currently supported.

### Implementation Notes
This function is optimized for speed and directly manipulates CSC sparse matrix fields.
"""
function adjacency_matrix(g::AbstractGraph, T::DataType=Int; dir::Symbol=:out)
    nzmult = 1
    # see below - we iterate over columns. That's why we take the
    # "opposite" neighbor function. It's faster than taking the transpose
    # at the end.
    if (dir == :out)
        _adjacency_matrix(g, T, inneighbors, 1)
    elseif (dir == :in)
        _adjacency_matrix(g, T, outneighbors, 1)
    elseif (dir == :both)
        if is_directed(g)
            _adjacency_matrix(g, T, all_neighbors, 2)
        else
            _adjacency_matrix(g, T, outneighbors, 1)
        end
    else
        error("Not implemented")
    end
end

@generated function _find_correct_type(g::AbstractGraph{T}) where {T}
    TT = widen(T)
    if typemax(TT) >= typemax(Int64)
        TT = Int64
    end
    return :($TT)
end

function _adjacency_matrix(
    g::AbstractGraph, T::DataType, neighborfn::Function, nzmult::Int=1
)
    n_v = nv(g)
    nz = ne(g) * (is_directed(g) ? 1 : 2) * nzmult
    TT = _find_correct_type(g)
    colpt = ones(TT, n_v + 1)

    rowval = sizehint!(Vector{TT}(), nz)
    selfloops = Vector{TT}()
    for j in 1:n_v  # this is by column, not by row.
        if has_edge(g, j, j)
            push!(selfloops, j)
            if !(T <: Bool) && !is_directed(g)
                nz -= 1
            end
        end
        dsts = sort(collect(neighborfn(g, j))) # TODO for most graphs it might not be necessary to sort
        colpt[j + 1] = colpt[j] + length(dsts)
        append!(rowval, dsts)
    end
    spmx = SparseMatrixCSC(n_v, n_v, colpt, rowval, ones(T, nz))

    # this is inefficient. There should be a better way of doing this.
    # the issue is that adjacency matrix entries for self-loops are 2,
    # not one(T).
    if !(T <: Bool) && !is_directed(g)
        for i in selfloops
            spmx[i, i] += one(T)
        end
    end
    return spmx
end

"""
    laplacian_matrix(g[, T=Int; dir=:unspec])

Return a sparse [Laplacian matrix](https://en.wikipedia.org/wiki/Laplacian_matrix)
for a graph `g`, indexed by `[u, v]` vertices. `T` defaults to `Int` for both graph types.

### Optional Arguments
`dir=:unspec`: `:unspec`, `:both`, `:in`, and `:out` are currently supported.
For undirected graphs, `dir` defaults to `:out`; for directed graphs,
`dir` defaults to `:both`.
"""
function laplacian_matrix(
    g::AbstractGraph{U}, T::DataType=Int; dir::Symbol=:unspec
) where {U}
    if dir == :unspec
        dir = is_directed(g) ? :both : :out
    end
    A = adjacency_matrix(g, T; dir=dir)
    s = sum(A; dims=2)
    D = convert(SparseMatrixCSC{T,U}, spdiagm(0 => s[:]))
    return D - A
end

"""
    laplacian_spectrum(g[, T=Int; dir=:unspec])

Return the eigenvalues of the Laplacian matrix for a graph `g`, indexed
by vertex. Default values for `T` are the same as those in
[`laplacian_matrix`](@ref).

### Optional Arguments
`dir=:unspec`: Options for `dir` are the same as those in [`laplacian_matrix`](@ref).

### Performance
Converts the matrix to dense with ``nv^2`` memory usage.

### Implementation Notes
Use `eigvals(Matrix(laplacian_matrix(g, args...)))` to compute some of the
eigenvalues/eigenvectors.
"""
function laplacian_spectrum(g::AbstractGraph, T::DataType=Int; dir::Symbol=:unspec)
    return eigvals(Matrix(laplacian_matrix(g, T; dir=dir)))
end

"""
    adjacency_spectrum(g[, T=Int; dir=:unspec])

Return the eigenvalues of the adjacency matrix for a graph `g`, indexed
by vertex. Default values for `T` are the same as those in
[`adjacency_matrix`](@ref).

### Optional Arguments
`dir=:unspec`: Options for `dir` are the same as those in [`laplacian_matrix`](@ref).

### Performance
Converts the matrix to dense with ``nv^2`` memory usage.

### Implementation Notes
Use `eigvals(Matrix(adjacency_matrix(g, args...)))` to compute some of the
eigenvalues/eigenvectors.
"""
function adjacency_spectrum(g::AbstractGraph, T::DataType=Int; dir::Symbol=:unspec)
    if dir == :unspec
        dir = is_directed(g) ? :both : :out
    end
    return eigvals(Matrix(adjacency_matrix(g, T; dir=dir)))
end

"""
    incidence_matrix(g[, T=Int; oriented=false])

Return a sparse node-arc incidence matrix for a graph, indexed by
`[v, i]`, where `i` is in `1:ne(g)`, indexing an edge `e`. For
directed graphs, a value of `-1` indicates that `src(e) == v`, while a
value of `1` indicates that `dst(e) == v`. Otherwise, the value is
`0`. For undirected graphs, both entries are `1` by default (this behavior
can be overridden by the `oriented` optional argument).

If `oriented` (default false) is true, for an undirected graph `g`, the
matrix will contain arbitrary non-zero values representing connectivity
between `v` and `i`.
"""
function incidence_matrix(g::AbstractGraph, T::DataType=Int; oriented=false)
    isdir = is_directed(g)
    n_e = ne(g)
    I = vcat(src.(edges(g)), dst.(edges(g)))
    J = vcat(1:n_e, 1:n_e)
    V = vcat(
        (isdir || oriented) ? -fill(one(T), n_e) : fill(one(T), n_e), fill(one(T), n_e)
    )
    return sparse(I, J, V, nv(g), ne(g))
end

"""
    spectral_distance(G₁, G₂ [, k])

Compute the spectral distance between undirected n-vertex
graphs `G₁` and `G₂` using the top `k` greatest eigenvalues.
If `k` is omitted, uses full spectrum.

### References
- JOVANOVIC, I.; STANIC, Z., 2014. Spectral Distances of Graphs Based on their Different Matrix Representations
"""
function spectral_distance end

# can't use Traitor syntax here (https://github.com/mauro3/SimpleTraits.jl/issues/36)
@traitfn function spectral_distance(
    G₁::G, G₂::G, k::Integer
) where {G <: AbstractGraph; !IsDirected{G}}
    A₁ = adjacency_matrix(G₁)
    A₂ = adjacency_matrix(G₂)

    λ₁ = if k < nv(G₁) - 1
        eigs(A₁; nev=k, which=LR())[1]
    else
        eigvals(Matrix(A₁))[end:-1:(end - (k - 1))]
    end
    λ₂ = if k < nv(G₂) - 1
        eigs(A₂; nev=k, which=LR())[1]
    else
        eigvals(Matrix(A₂))[end:-1:(end - (k - 1))]
    end

    return sum(abs, (λ₁ - λ₂))
end

# can't use Traitor syntax here (https://github.com/mauro3/SimpleTraits.jl/issues/36)
@traitfn function spectral_distance(G₁::G, G₂::G) where {G <: AbstractGraph; !IsDirected{G}}
    nv(G₁) == nv(G₂) ||
        throw(ArgumentError("Spectral distance not defined for |G₁| != |G₂|"))
    return spectral_distance(G₁, G₂, nv(G₁))
end
