function closeness_centrality(
    g::AbstractGraph,
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    parallel=:distributed,
)
    return if parallel == :distributed
        distr_closeness_centrality(g, distmx; normalize=normalize)
    else
        threaded_closeness_centrality(g, distmx; normalize=normalize)
    end
end

function distr_closeness_centrality(
    g::AbstractGraph, distmx::AbstractMatrix=weights(g); normalize=true
)::Vector{Float64}
    n_v = Int(nv(g))
    closeness = SharedVector{Float64}(n_v)
    fill!(closeness, 0.0)

    @sync @distributed for u in vertices(g)
        if degree(g, u) == 0     # no need to do Dijkstra here
            closeness[u] = 0.0
        else
            d = Graphs.dijkstra_shortest_paths(g, u, distmx).dists
            δ = filter(x -> x != typemax(x), d)
            σ = sum(δ)
            l = length(δ) - 1
            if σ > 0
                closeness[u] = l / σ
                if normalize
                    n = l * 1.0 / (n_v - 1)
                    closeness[u] *= n
                end
            else
                closeness[u] = 0.0
            end
        end
    end
    return sdata(closeness)
end

function threaded_closeness_centrality(
    g::AbstractGraph, distmx::AbstractMatrix=weights(g); normalize=true
)::Vector{Float64}
    n_v = Int(nv(g))
    closeness = zeros(Float64, n_v)

    Base.Threads.@threads for u in vertices(g)
        if degree(g, u) == 0     # no need to do Dijkstra here
            closeness[u] = 0.0
        else
            d = Graphs.dijkstra_shortest_paths(g, u, distmx).dists
            δ = filter(x -> x != typemax(x), d)
            σ = sum(δ)
            l = length(δ) - 1
            if σ > 0
                closeness[u] = l / σ
                if normalize
                    n = l * 1.0 / (n_v - 1)
                    closeness[u] *= n
                end
            else
                closeness[u] = 0.0
            end
        end
    end
    return closeness
end
