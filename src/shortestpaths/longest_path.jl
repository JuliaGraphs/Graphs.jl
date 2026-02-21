"""
    dag_longest_path(g, distmx=weights(g); topological_order=topological_sort_by_dfs(g))

Return a longest path within the directed acyclic graph `g`, with distance matrix `distmx` and using `topological_order` to iterate on vertices.
"""
function dag_longest_path end

@traitfn function dag_longest_path(
    g::::IsDirected,
    distmx::AbstractMatrix=weights(g);
    topological_order=topological_sort_by_dfs(g),
)
    U = eltype(g)
    T = eltype(distmx)

    dists = zeros(T, nv(g))
    parents = zeros(U, nv(g))

    for v in topological_order
        for u in inneighbors(g, v)
            newdist = dists[u] + distmx[u, v]
            if newdist > dists[v]
                dists[v] = newdist
                parents[v] = u
            end
        end
    end

    if isempty(dists)
        return U[]
    else
        v = argmax(dists)
        return path_from_parents(v, parents)
    end
end
