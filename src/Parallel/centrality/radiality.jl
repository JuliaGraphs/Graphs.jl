function radiality_centrality(g::AbstractGraph; parallel=:threads)
    return if parallel == :distributed
        distr_radiality_centrality(g)
    else
        threaded_radiality_centrality(g)
    end
end

function distr_radiality_centrality(args...; kwargs...)
    return error(
        "`parallel = :distributed` requested, but SharedArrays or Distributed is not loaded"
    )
end

function threaded_radiality_centrality(g::AbstractGraph)::Vector{Float64}
    n_v = nv(g)
    vs = vertices(g)
    n = ne(g)
    meandists = Vector{Float64}(undef, n_v)
    maxdists = Vector{Float64}(undef, n_v)

    Base.Threads.@threads for i in vertices(g)
        d = Graphs.dijkstra_shortest_paths(g, vs[i])
        maxdists[i] = maximum(d.dists)
        meandists[i] = sum(d.dists) / (n_v - 1)
    end
    dmtr = maximum(maxdists)
    radialities = collect(meandists)
    return ((dmtr + 1) .- radialities) ./ dmtr
end
