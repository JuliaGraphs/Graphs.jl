function stress_centrality(g::AbstractGraph, vs=vertices(g); parallel=:distributed)
    return if parallel == :distributed
        distr_stress_centrality(g, vs)
    else
        threaded_stress_centrality(g, vs)
    end
end

function stress_centrality(
    g::AbstractGraph,
    k::Integer;
    parallel=:distributed,
    rng::Union{Nothing,AbstractRNG}=nothing,
    seed::Union{Nothing,Integer}=nothing,
)
    samples = sample(vertices(g), k; rng=rng, seed=seed)
    return if parallel == :distributed
        distr_stress_centrality(g, samples)
    else
        threaded_stress_centrality(g, samples)
    end
end

function distr_stress_centrality(g::AbstractGraph, vs=vertices(g))::Vector{Int64}
    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    # Parallel reduction
    stress = @distributed (+) for s in vs
        temp_stress = zeros(Int64, n_v)
        if degree(g, s) > 0  # this might be 1?
            state = Graphs.dijkstra_shortest_paths(g, s; allpaths=true, trackvertices=true)
            Graphs._stress_accumulate_basic!(temp_stress, state, g, s)
        end
        temp_stress
    end
    return stress
end

function threaded_stress_centrality(g::AbstractGraph, vs=vertices(g))::Vector{Int64}
    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    # Parallel reduction
    local_stress = [zeros(Int, n_v) for _ in 1:nthreads()]

    Base.Threads.@threads for s in vs
        if degree(g, s) > 0  # this might be 1?
            state = Graphs.dijkstra_shortest_paths(g, s; allpaths=true, trackvertices=true)
            Graphs._stress_accumulate_basic!(
                local_stress[Base.Threads.threadid()], state, g, s
            )
        end
    end
    return reduce(+, local_stress)
end
