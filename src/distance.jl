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

An optimizied BFS algorithm (iFUB) is used for unweighted graphs, both in [undirected](https://www.sciencedirect.com/science/article/pii/S0304397512008687) 
and [directed](https://link.springer.com/chapter/10.1007/978-3-642-30850-5_10) cases.

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


function diameter(g::AbstractGraph, ::DefaultDistance)
    if nv(g) == 0
        return 0
    end

    connected = is_directed(g) ? is_strongly_connected(g) : is_connected(g)

    if !connected
        return typemax(Int)
    end

    return _diameter_ifub(g)
end

function diameter(g::AbstractGraph, distmx::AbstractMatrix)
    # If the graph is unweighted (DefaultDistance), use the existing BFS-based iFUB
    if distmx isa DefaultDistance
        return diameter(g, DefaultDistance(nv(g))) # Redirects to existing _diameter_ifub logic
    end

    # For weighted directed graphs, strictly implementing DiFUB requires efficient 
    # backward Dijkstra traversals 
    # For simplicity, we fall back to the naive method for directed weighted graphs
    # and use the optimized iFUB for undirected weighted graphs
    if is_directed(g)
        return maximum(eccentricity(g, vertices(g), distmx))
    end

    return _diameter_weighted(g, distmx)
end

#=
function diameter(g::AbstractGraph, distmx::AbstractMatrix)
    return maximum(eccentricity(g, distmx))
end
=#

function _diameter_ifub(g::AbstractGraph{T}) where {T<:Integer}
    nvg = nv(g)
    out_list = [outneighbors(g, v) for v in vertices(g)]

    if is_directed(g)
        in_list = [inneighbors(g, v) for v in vertices(g)]
    else
        in_list = out_list
    end

    active = trues(nvg)
    visited = falses(nvg)
    queue = Vector{T}(undef, nvg)
    distbuf = fill(typemax(T), nvg)
    diam = 0

    # Sort vertices by total degree (descending) to maximize pruning potential
    vs = collect(vertices(g))
    sort!(vs; by=v -> -(length(out_list[v]) + length(in_list[v])))

    for u in vs
        if !active[u]
            continue
        end

        # Forward BFS from u
        fill!(visited, false)
        visited[u] = true
        queue[1] = u
        front = 1
        back = 2
        level_end = 1
        e = 0

        while front < back
            v = queue[front]
            front += 1

            @inbounds for w in out_list[v]
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
        diam = max(diam, e)

        # Backward BFS (Pruning)
        dmax = diam - e

        # Only prune if we have a chance to exceed the current diameter
        if dmax >= 0
            fill!(distbuf, typemax(T))
            distbuf[u] = 0
            queue[1] = u
            front = 1
            back = 2

            while front < back
                v = queue[front]
                front += 1

                if distbuf[v] >= dmax
                    continue
                end

                @inbounds for w in in_list[v]
                    if distbuf[w] == typemax(T)
                        distbuf[w] = distbuf[v] + 1
                        queue[back] = w
                        back += 1
                    end
                end
            end

            # Prune vertices that cannot lead to a longer diameter
            @inbounds for v in vertices(g)
                if active[v] && distbuf[v] != typemax(T) && (distbuf[v] + e <= diam)
                    active[v] = false
                end
            end
        end

        if !any(active)
            break
        end
    end

    return diam
end

function _diameter_weighted(g::AbstractGraph, distmx::AbstractMatrix{T}) where T <: Number
    # Handle empty graph
    nv(g) == 0 && return zero(T)

    # 1. Heuristic: Start from a node 'u' with high degree
    u = argmax(degree(g))

    # 2. Compute Shortest Path Tree from u
    ds = dijkstra_shortest_paths(g, u, distmx)
    dists = ds.dists

    # Handle disconnected components
    # If u cannot reach all nodes, the graph is disconnected -> infinite diameter
    valid_nodes = findall(d -> d < typemax(T), dists)
    if length(valid_nodes) < nv(g)
        return typemax(T)
    end

    # 3. Identify distinct sorted distances
    unique_dists = unique(dists[valid_nodes])
    sort!(unique_dists)

    # Initialize Lower Bound (lb) with eccentricity of u
    lb = unique_dists[end]

    # Group nodes by distance
    nodes_by_dist = Dict{T, Vector{Int}}()
    for v in valid_nodes
        d = dists[v]
        if !haskey(nodes_by_dist, d)
            nodes_by_dist[d] = Int[]
        end
        push!(nodes_by_dist[d], v)
    end

    # 4. Iterate backward
    num_levels = length(unique_dists)
    
    for i in num_levels:-1:2
        d_i = unique_dists[i]
        d_prev = unique_dists[i-1]

        # Process the "Fringe" at distance d_i FIRST
        fringe = nodes_by_dist[d_i]
        for v in fringe
            ecc_v = maximum(dijkstra_shortest_paths(g, v, distmx).dists)
            if ecc_v > lb
                lb = ecc_v
            end
        end

        # Pruning Condition: Check AFTER processing the current level
        # If the found lower bound is greater than 2 * (distance of previous level),
        # we can stop. Nodes in previous levels cannot form a path longer than 2*d_prev.
        if lb > 2 * d_prev
            return lb
        end
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
