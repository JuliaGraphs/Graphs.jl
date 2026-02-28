# used in shortest path calculations

"""
    DefaultDistance

An array-like structure that provides distance values of `1` for any `src, dst` combination.
"""
struct DefaultDistance <: AbstractMatrix{Int}
    nv::Int
    DefaultDistance(nv::Int=typemax(Int)) = new(nv)
end

DefaultDistance(nv::Integer) = DefaultDistance(Int(nv))

function show(io::IO, x::DefaultDistance)
    return print(io, "$(x.nv) × $(x.nv) default distance matrix (value = 1)")
end
show(io::IO, z::MIME"text/plain", x::DefaultDistance) = show(io, x)

getindex(::DefaultDistance, s::Integer, d::Integer) = 1
getindex(::DefaultDistance, s::UnitRange, d::UnitRange) = DefaultDistance(length(s))
size(d::DefaultDistance) = (d.nv, d.nv)
transpose(d::DefaultDistance) = d
adjoint(d::DefaultDistance) = d

"""
    eccentricity(g[, v][, distmx])
    eccentricity(g[, vs][, distmx])

Return the eccentricity[ies] of a vertex / vertex list `v` or a set of vertices
`vs` defaulting to the entire graph. An optional matrix of edge distances may
be supplied; if missing, edge distances default to `1`.

The eccentricity of a vertex is the maximum shortest-path distance between it
and all other vertices in the graph.

The output is either a single float (when a single vertex is provided) or a
vector of floats corresponding to the vertex vector. If no vertex vector is
provided, the vector returned corresponds to each vertex in the graph.

### Performance
Because this function must calculate shortest paths for all vertices supplied
in the argument list, it may take a long time.

### Implementation Notes
The eccentricity vector returned by `eccentricity()` may be used as input
for the rest of the distance measures below. If an eccentricity vector is
provided, it will be used. Otherwise, an eccentricity vector will be calculated
for each call to the function. It may therefore be more efficient to calculate,
store, and pass the eccentricities if multiple distance measures are desired.

An infinite path length is represented by the `typemax` of the distance matrix.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleGraph([0 1 0; 1 0 1; 0 1 0]);

julia> eccentricity(g, 1)
2

julia> eccentricity(g, [1; 2])
2-element Vector{Int64}:
 2
 1

julia> eccentricity(g, [1; 2], [0 2 0; 0.5 0 0.5; 0 2 0])
2-element Vector{Float64}:
 2.5
 0.5
```
"""
function eccentricity(
    g::AbstractGraph, v::Integer, distmx::AbstractMatrix{T}=weights(g)
) where {T<:Number}
    e = maximum(dijkstra_shortest_paths(g, v, distmx).dists)
    e == typemax(T) && @warn("Infinite path length detected for vertex $v")

    return e
end

function eccentricity(g::AbstractGraph, vs=vertices(g), distmx::AbstractMatrix=weights(g))
    return [eccentricity(g, v, distmx) for v in vs]
end

function eccentricity(g::AbstractGraph, distmx::AbstractMatrix)
    return eccentricity(g, vertices(g), distmx)
end

"""
    diameter(eccentricities)
    diameter(g, distmx=weights(g))

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the maximum eccentricity of the graph.

An optimizied BFS algorithm (iFUB) is used, both in [undirected](https://www.sciencedirect.com/science/article/pii/S0304397512008687) 
and [directed](https://link.springer.com/chapter/10.1007/978-3-642-30850-5_10) cases. For weighted graphs,
dijkstra is used to compute shortest path trees, and the algorithm iterates over sorted distinct distance values.

# Examples
```jldoctest
julia> using Graphs

julia> diameter(star_graph(5))
2

julia> diameter(path_graph(5))
4
```
"""
function diameter end

diameter(eccentricities::Vector) = maximum(eccentricities)

diameter(g::AbstractGraph) = diameter(g, weights(g))

function diameter(g::AbstractGraph, distmx::AbstractMatrix)
    if is_directed(g)
        return _diameter_weighted_directed(g, distmx)
    else
        return _diameter_weighted_undirected(g, distmx)
    end
end

function diameter(g::AbstractGraph, ::DefaultDistance)
    nv(g) == 0 && return 0

    connected = is_directed(g) ? is_strongly_connected(g) : is_connected(g)
    !connected && return typemax(Int)

    return _diameter_ifub(g)
end

function _diameter_ifub(g::AbstractGraph{T}) where {T<:Integer}
    nvg = nv(g)

    active = trues(nvg)
    visited = falses(nvg)
    queue = Vector{T}(undef, nvg)
    distbuf = fill(typemax(T), nvg)
    diam = 0

    # Sort vertices by total degree (descending) to maximize pruning potential
    vs = collect(vertices(g))
    sort!(vs; by=v -> -degree(g, v))

    for u in vs
        !active[u] && continue

        # Forward BFS
        e = _fwd_bfs_eccentricity!(g, u, visited, queue)
        diam = max(diam, e)

        # Backward BFS
        dmax = diam - e
        if dmax >= 0
            _bwd_bfs_prune!(g, u, active, distbuf, queue, dmax, e, diam)
        end

        !any(active) && break
    end

    return diam
end

# iFUB Helpers

function _fwd_bfs_eccentricity!(g, u, visited, queue)
    fill!(visited, false)
    visited[u] = true
    queue[1] = u
    front, back, level_end, e = 1, 2, 1, 0

    while front < back
        v = queue[front]
        front += 1

        @inbounds for w in outneighbors(g, v)
            if !visited[w]
                visited[w] = true
                queue[back] = w
                back += 1
            end
        end

        if front > level_end && front < back
            e += 1
            level_end = back - 1
        end
    end
    return e
end

function _bwd_bfs_prune!(g, u, active, distbuf, queue, dmax, e, diam)
    T = eltype(queue)
    fill!(distbuf, typemax(T))
    distbuf[u] = 0
    queue[1] = u
    front, back = 1, 2

    while front < back
        v = queue[front]
        front += 1

        distbuf[v] >= dmax && continue

        @inbounds for w in inneighbors(g, v)
            if distbuf[w] == typemax(T)
                distbuf[w] = distbuf[v] + 1
                queue[back] = w
                back += 1
            end
        end
    end

    # Prune vertices
    @inbounds for v in eachindex(active)
        if active[v] && distbuf[v] != typemax(T) && (distbuf[v] + e <= diam)
            active[v] = false
        end
    end
end

function _safe_reverse(g::T) where {T<:AbstractGraph}
    if hasmethod(reverse, Tuple{T})
        return reverse(g)
    else
        U = eltype(g)
        rg = SimpleDiGraph{U}(nv(g))
        @inbounds for v in vertices(g)
            for w in outneighbors(g, v)
                add_edge!(rg, w, v)
            end
        end
        return rg
    end
end

function _diameter_weighted_directed(
    g::AbstractGraph, distmx::AbstractMatrix{T}
) where {T<:Number}
    nv(g) == 0 && return zero(T)
    U = eltype(g)
    u = U(argmax(degree(g)))

    # Compute base trees
    g_rev = _safe_reverse(g)
    distmx_rev = permutedims(distmx)

    dists_fwd = dijkstra_shortest_paths(g, u, distmx).dists
    dists_bwd = dijkstra_shortest_paths(g_rev, u, distmx_rev).dists

    if maximum(dists_fwd) == typemax(T) || maximum(dists_bwd) == typemax(T)
        return typemax(T)
    end

    # Group fringes and initialize lower bound
    unique_dists = sort!(unique(vcat(dists_fwd, dists_bwd)))
    lb = max(maximum(dists_fwd), maximum(dists_bwd))

    fringe_fwd = Dict{T,Vector{Int}}()
    fringe_bwd = Dict{T,Vector{Int}}()

    @inbounds for v in vertices(g)
        push!(get!(fringe_fwd, dists_fwd[v], Int[]), v)
        push!(get!(fringe_bwd, dists_bwd[v], Int[]), v)
    end

    # Evaluate fringes backward
    for i in length(unique_dists):-1:2
        d_i = unique_dists[i]
        d_prev = unique_dists[i - 1]

        if haskey(fringe_fwd, d_i)
            for v in fringe_fwd[d_i]
                ds = dijkstra_shortest_paths(g_rev, U(v), distmx_rev)
                lb = max(lb, maximum(ds.dists))
            end
        end

        if haskey(fringe_bwd, d_i)
            for v in fringe_bwd[d_i]
                ds = dijkstra_shortest_paths(g, U(v), distmx)
                lb = max(lb, maximum(ds.dists))
            end
        end

        lb > 2 * d_prev && break
    end

    return lb
end

function _diameter_weighted_undirected(
    g::AbstractGraph, distmx::AbstractMatrix{T}
) where {T<:Number}
    nv(g) == 0 && return zero(T)
    U = eltype(g)
    u = U(argmax(degree(g)))

    # Compute base trees
    dists = dijkstra_shortest_paths(g, u, distmx).dists

    if maximum(dists) == typemax(T)
        return typemax(T)
    end

    # Group fringes and initialize lower bound
    unique_dists = sort!(unique(dists))
    lb = maximum(dists)

    fringe = Dict{T,Vector{Int}}()
    @inbounds for v in vertices(g)
        push!(get!(fringe, dists[v], Int[]), v)
    end

    for i in length(unique_dists):-1:2
        d_i = unique_dists[i]
        d_prev = unique_dists[i - 1]

        if haskey(fringe, d_i)
            for v in fringe[d_i]
                ds = dijkstra_shortest_paths(g, U(v), distmx)
                lb = max(lb, maximum(ds.dists))
            end
        end

        lb >= 2 * d_prev && break
    end

    return lb
end

"""
    periphery(eccentricities)
    periphery(g, distmx=weights(g))

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the set of all vertices whose eccentricity is
equal to the graph's diameter (that is, the set of vertices with the
largest eccentricity).

# Examples
```jldoctest
julia> using Graphs

julia> periphery(star_graph(5))
4-element Vector{Int64}:
 2
 3
 4
 5

julia> periphery(path_graph(5))
2-element Vector{Int64}:
 1
 5
```
"""
function periphery(eccentricities::Vector)
    diam = maximum(eccentricities)
    return filter(x -> eccentricities[x] == diam, 1:length(eccentricities))
end

function periphery(g::AbstractGraph, distmx::AbstractMatrix=weights(g))
    return periphery(eccentricity(g, distmx))
end

"""
    radius(eccentricities)
    radius(g, distmx=weights(g))

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the minimum eccentricity of the graph.

# Examples
```jldoctest
julia> using Graphs

julia> radius(star_graph(5))
1

julia> radius(path_graph(5))
2
```
"""
radius(eccentricities::Vector) = minimum(eccentricities)
function radius(g::AbstractGraph, distmx::AbstractMatrix=weights(g))
    return minimum(eccentricity(g, distmx))
end

"""
    center(eccentricities)
    center(g, distmx=weights(g))

Given a graph and optional distance matrix, or a vector of precomputed
eccentricities, return the set of all vertices whose eccentricity is equal
to the graph's radius (that is, the set of vertices with the smallest eccentricity).

# Examples
```jldoctest
julia> using Graphs

julia> center(star_graph(5))
1-element Vector{Int64}:
 1

julia> center(path_graph(5))
1-element Vector{Int64}:
 3
```
"""
function center(eccentricities::Vector)
    rad = radius(eccentricities)
    return filter(x -> eccentricities[x] == rad, 1:length(eccentricities))
end

function center(g::AbstractGraph, distmx::AbstractMatrix=weights(g))
    return center(eccentricity(g, distmx))
end
