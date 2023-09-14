function betweenness_centrality(
    g::AbstractGraph,
    vs=vertices(g),
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false,
    parallel=:distributed,
)
    return if parallel == :distributed
        distr_betweenness_centrality(
            g, vs, distmx; normalize=normalize, endpoints=endpoints
        )
    else
        threaded_betweenness_centrality(
            g, vs, distmx; normalize=normalize, endpoints=endpoints
        )
    end
end

function betweenness_centrality(
    g::AbstractGraph,
    k::Integer,
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false,
    parallel=:distributed,
    rng::Union{Nothing,AbstractRNG}=nothing,
    seed::Union{Nothing,Integer}=nothing,
)
    samples = sample(vertices(g), k; rng=rng, seed=seed)
    return if parallel == :distributed
        distr_betweenness_centrality(
            g, samples, distmx; normalize=normalize, endpoints=endpoints
        )
    else
        threaded_betweenness_centrality(
            g, samples, distmx; normalize=normalize, endpoints=endpoints
        )
    end
end

function distr_betweenness_centrality(
    g::AbstractGraph,
    vs=vertices(g),
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false,
)::Vector{Float64}
    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    # Parallel reduction

    betweenness = @distributed (+) for s in vs
        temp_betweenness = zeros(n_v)
        if degree(g, s) > 0  # this might be 1?
            state = Graphs.dijkstra_shortest_paths(
                g, s, distmx; allpaths=true, trackvertices=true
            )
            if endpoints
                Graphs._accumulate_endpoints!(temp_betweenness, state, g, s)
            else
                Graphs._accumulate_basic!(temp_betweenness, state, g, s)
            end
        end
        temp_betweenness
    end

    Graphs._rescale!(betweenness, n_v, normalize, isdir, k)

    return betweenness
end

function distr_betweenness_centrality(
    g::AbstractGraph,
    k::Integer,
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false,
    rng::Union{Nothing,AbstractRNG}=nothing,
    seed::Union{Nothing,Integer}=nothing,
)
    samples = sample(vertices(g), k; rng=rng, seed=seed)
    return distr_betweenness_centrality(
        g, samples, distmx; normalize=normalize, endpoints=endpoints
    )
end

function threaded_betweenness_centrality(
    g::AbstractGraph,
    vs=vertices(g),
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false,
)::Vector{Float64}
    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    vs_active = findall((x) -> degree(g, x) > 0, vs) # 0 might be 1?
    k_active = length(vs_active)
    d, r = divrem(k_active, Threads.nthreads())
    ntasks = d == 0 ? r : Threads.nthreads()
    local_betweenness = [zeros(n_v) for _ in 1:ntasks]
    task_size = cld(k_active, ntasks)

    @sync for (t, task_range) in enumerate(Iterators.partition(1:k_active, task_size))
        Threads.@spawn for s in @view(vs_active[task_range])
            state = Graphs.dijkstra_shortest_paths(
                g, s, distmx; allpaths=true, trackvertices=true
            )
            if endpoints
                Graphs._accumulate_endpoints!(local_betweenness[t], state, g, s)
            else
                Graphs._accumulate_basic!(local_betweenness[t], state, g, s)
            end
        end
    end
    betweenness = reduce(+, local_betweenness)
    Graphs._rescale!(betweenness, n_v, normalize, isdir, k)

    return betweenness
end

function threaded_betweenness_centrality(
    g::AbstractGraph,
    k::Integer,
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false,
    rng::Union{Nothing,AbstractRNG}=nothing,
    seed::Union{Nothing,Integer}=nothing,
)
    samples = sample(vertices(g), k; rng=rng, seed=seed)
    return threaded_betweenness_centrality(
        g, samples, distmx; normalize=normalize, endpoints=endpoints
    )
end
