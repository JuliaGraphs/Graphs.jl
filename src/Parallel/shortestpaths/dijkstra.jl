"""
    struct Parallel.MultipleDijkstraState{T, U}

An [`AbstractPathState`](@ref) designed for Parallel.dijkstra_shortest_paths calculation.
"""
struct MultipleDijkstraState{T<:Number,U<:Integer} <: AbstractPathState
    dists::Matrix{T}
    parents::Matrix{U}
end

"""
    Parallel.dijkstra_shortest_paths(g, sources=vertices(g), distmx=weights(g), parallel=:distributed)

Compute the shortest paths between all pairs of vertices in graph `g` by running
[`dijkstra_shortest_paths`] for every vertex and using an optional list of source vertex `sources` and
an optional distance matrix `distmx`. Return a [`Parallel.MultipleDijkstraState`](@ref) with relevant
traversal information. The `parallel` argument can be set to `:threads` or `:distributed` for multi-
threaded or multi-process parallelism, respectively.
"""
function dijkstra_shortest_paths(
    g::AbstractGraph{U},
    sources=vertices(g),
    distmx::AbstractMatrix{T}=weights(g);
    parallel::Symbol=:distributed,
) where {T<:Number} where {U}
    return if parallel === :threads
        threaded_dijkstra_shortest_paths(g, sources, distmx)
    elseif parallel === :distributed
        distr_dijkstra_shortest_paths(g, sources, distmx)
    else
        throw(
            ArgumentError(
                "Unsupported parallel argument '$(repr(parallel))' (supported: ':threads' or ':distributed')",
            ),
        )
    end
end

function threaded_dijkstra_shortest_paths(
    g::AbstractGraph{U}, sources=vertices(g), distmx::AbstractMatrix{T}=weights(g)
) where {T<:Number} where {U}
    n_v = nv(g)
    r_v = length(sources)

    # TODO: remove `Int` once julialang/#23029 / #23032 are resolved
    dists = Matrix{T}(undef, Int(r_v), Int(n_v))
    parents = Matrix{U}(undef, Int(r_v), Int(n_v))

    Base.Threads.@threads for i in 1:r_v
        state = Graphs.dijkstra_shortest_paths(g, sources[i], distmx)
        dists[i, :] = state.dists
        parents[i, :] = state.parents
    end

    result = MultipleDijkstraState(dists, parents)
    return result
end

function distr_dijkstra_shortest_paths(
    g::AbstractGraph{U}, sources=vertices(g), distmx::AbstractMatrix{T}=weights(g)
) where {T<:Number} where {U}
    n_v = nv(g)
    r_v = length(sources)

    # TODO: remove `Int` once julialang/#23029 / #23032 are resolved
    dists = SharedMatrix{T}(Int(r_v), Int(n_v))
    parents = SharedMatrix{U}(Int(r_v), Int(n_v))

    @sync @distributed for i in 1:r_v
        state = Graphs.dijkstra_shortest_paths(g, sources[i], distmx)
        dists[i, :] = state.dists
        parents[i, :] = state.parents
    end

    result = MultipleDijkstraState(sdata(dists), sdata(parents))
    return result
end
