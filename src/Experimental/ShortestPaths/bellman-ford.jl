# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# The Bellman Ford algorithm for single-source shortest path

struct NegativeCycleError <: Exception end

"""
    struct BellmanFord <: ShortestPathAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm).
No fields are specified or required.

### Implementation Notes
`BellmanFord` supports the following shortest-path functionality:
- negative distance matrices / weights
- (optional) multiple sources
- all destinations
"""
struct BellmanFord <: ShortestPathAlgorithm end
struct BellmanFordResult{T,U<:Integer} <: ShortestPathResult
    parents::Vector{U}
    dists::Vector{T}
end

function shortest_paths(
    graph::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T},
    ::BellmanFord,
) where {T,U<:Integer}
    nvg = nv(graph)
    active = falses(nvg)
    active[sources] .= true
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    dists[sources] .= 0
    no_changes = false
    new_active = falses(nvg)

    @inbounds for i in vertices(graph)
        no_changes = true
        new_active .= false
        for u in vertices(graph)[active]
            for v in outneighbors(graph, u)
                relax_dist = distmx[u, v] + dists[u]
                if dists[v] > relax_dist
                    dists[v] = relax_dist
                    parents[v] = u
                    no_changes = false
                    new_active[v] = true
                end
            end
        end
        no_changes && break
        active, new_active = new_active, active
    end
    no_changes || throw(NegativeCycleError())
    return BellmanFordResult(parents, dists)
end

function shortest_paths(
    g::AbstractGraph, v::Integer, distmx::AbstractMatrix, alg::BellmanFord
)
    return shortest_paths(g, [v], distmx, alg)
end

has_negative_weight_cycle(g::AbstractGraph, ::BellmanFord) = false

function has_negative_weight_cycle(
    g::AbstractGraph, distmx::AbstractMatrix, alg::BellmanFord
)
    try
        shortest_paths(g, vertices(g), distmx, alg)
    catch e
        isa(e, ShortestPaths.NegativeCycleError) && return true
    end
    return false
end
