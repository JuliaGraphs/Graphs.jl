# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# The Bellman Ford algorithm for single-source shortest path

###################################################################
#
#   The type that encapsulates the state of Bellman Ford algorithm
#
###################################################################
using Base.Threads

struct NegativeCycleError <: Exception end

# AbstractPathState is defined in core
"""
    BellmanFordState{T, U}

An `AbstractPathState` designed for Bellman-Ford shortest-paths calculations.

# Fields

- `parents::Vector{U}`: `parents[v]` is the predecessor of vertex `v` on the shortest path from the source to `v`
- `dists::Vector{T}`: `dists[v]` is the length of the shortest path from the source to `v`
"""
struct BellmanFordState{T<:Real,U<:Integer} <: AbstractPathState
    parents::Vector{U}
    dists::Vector{T}
end

"""
    bellman_ford_shortest_paths(g, s, distmx=weights(g))
    bellman_ford_shortest_paths(g, ss, distmx=weights(g))

Compute shortest paths between a source `s` (or list of sources `ss`) and all
other nodes in graph `g` using the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm).

Return a [`Graphs.BellmanFordState`](@ref) with relevant traversal information (try querying `state.parents` or `state.dists`).
"""
function bellman_ford_shortest_paths(
    graph::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T}=weights(graph),
) where {T<:Real} where {U<:Integer}
    nvg = nv(graph)
    active = falses(nvg)
    active[sources] .= true
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    dists[sources] .= zero(T)
    no_changes = false
    new_active = falses(nvg)

    for i in vertices(graph)
        no_changes = true
        new_active .= false
        for u in vertices(graph)
            active[u] || continue
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
        if no_changes
            break
        end
        active, new_active = new_active, active
    end
    no_changes || throw(NegativeCycleError())
    return BellmanFordState(parents, dists)
end

function bellman_ford_shortest_paths(
    graph::AbstractGraph{U}, v::Integer, distmx::AbstractMatrix{T}=weights(graph);
) where {T<:Real} where {U<:Integer}
    return bellman_ford_shortest_paths(graph, [v], distmx)
end

has_negative_edge_cycle(g::AbstractGraph) = false

function has_negative_edge_cycle(
    g::AbstractGraph{U}, distmx::AbstractMatrix{T}
) where {T<:Real} where {U<:Integer}
    try
        bellman_ford_shortest_paths(g, collect_if_not_vector(vertices(g)), distmx)
    catch e
        isa(e, NegativeCycleError) && return true
        rethrow()
    end
    return false
end

"""
    enumerate_paths(state[, vs])

Given a path state `state` of type `AbstractPathState`, return a
vector (indexed by vertex) of the paths between the source vertex used to
compute the path state and a single destination vertex, a list of destination
vertices, or the entire graph. For multiple destination vertices, each
path is represented by a vector of vertices on the path between the source and
the destination. Nonexistent paths will be indicated by an empty vector. For
single destinations, the path is represented by a single vector of vertices,
and will be length 0 if the path does not exist.

### Implementation Notes
For Floyd-Warshall path states, please note that the output is a bit different,
since this algorithm calculates all shortest paths for all pairs of vertices:
`enumerate_paths(state)` will return a vector (indexed by source vertex) of
vectors (indexed by destination vertex) of paths. `enumerate_paths(state, v)`
will return a vector (indexed by destination vertex) of paths from source `v`
to all other vertices. In addition, `enumerate_paths(state, v, d)` will return
a vector representing the path from vertex `v` to vertex `d`.
"""
function enumerate_paths(state::AbstractPathState, vs::AbstractVector{<:Integer})
    parents = state.parents
    T = eltype(parents)

    num_vs = length(vs)
    all_paths = Vector{Vector{T}}(undef, num_vs)
    for i in 1:num_vs
        all_paths[i] = Vector{T}()
        index = T(vs[i])
        if parents[index] != 0 || parents[index] == index
            while parents[index] != 0
                push!(all_paths[i], index)
                index = parents[index]
            end
            push!(all_paths[i], index)
            reverse!(all_paths[i])
        end
    end
    return all_paths
end

enumerate_paths(state::AbstractPathState, v::Integer) = enumerate_paths(state, [v])[1]
function enumerate_paths(state::AbstractPathState)
    return enumerate_paths(state, [1:length(state.parents);])
end
