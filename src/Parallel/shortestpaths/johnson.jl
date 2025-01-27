
# Currently used to support the ismutable function that is not available in Julia < v1.7
using Compat

function johnson_shortest_paths(
    g::AbstractGraph{U}, distmx::AbstractMatrix{T}=weights(g)
) where {T<:Number} where {U<:Integer}
    nvg = nv(g)
    type_distmx = typeof(distmx)
    # Change when parallel implementation of Bellman Ford available
    wt_transform = bellman_ford_shortest_paths(g, vertices(g), distmx).dists

    @compat if !ismutable(distmx) && type_distmx != Graphs.DefaultDistance
        distmx = sparse(distmx) # Change reference, not value
    end

    # Weight transform not needed if all weights are positive.
    if type_distmx != Graphs.DefaultDistance
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[src(e)] - wt_transform[dst(e)]
        end
    end

    dijk_state = Parallel.dijkstra_shortest_paths(g, vertices(g), distmx)
    dists = dijk_state.dists
    parents = dijk_state.parents

    broadcast!(-, dists, dists, wt_transform)
    for v in vertices(g)
        dists[:, v] .+= wt_transform[v] # Vertical traversal preferred
    end

    @compat if ismutable(distmx)
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[dst(e)] - wt_transform[src(e)]
        end
    end

    return JohnsonState(dists, parents)
end
