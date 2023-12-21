"""
    dag_longest_path(g; distmx=weights(g), topological_order=topological_sort_by_dfs(g))

Find a longest path in a directed acyclic graph `g`.

The parameter `distmx` defines the distance matrix, while the parameter `topological_order` defines a topological order of the `vertices(g)`.

# Examples
```jldoctest
julia> using Graphs

julia> g = random_orientation_dag(complete_graph(10));

julia> dag_longest_path(g)
10-element Vector{Int64}:
  9
  1
  5
  2
  4
  6
  3
 10
  8
  7
```
"""
function dag_longest_path end

@traitfn function dag_longest_path(
    g::::IsDirected,
    distmx::AbstractMatrix{T}=weights(g);
    topological_order=topological_sort_by_dfs(g),
) where {T<:Real}
    U = eltype(g)
    n = nv(g)
    path = U[]

    # edge case
    n == 0 && return path

    dist = zeros(T, n)
    pred = collect(vertices(g))

    # get distances
    for v in topological_order
        for u in inneighbors(g, v)
            newdist = dist[u] + distmx[u, v]
            if newdist > dist[v]
                dist[v] = newdist
                pred[v] = u
            end
        end
    end

    # retrieve path 
    v = argmax(dist)
    push!(path, v)
    while pred[v] != v
        v = pred[v]
        push!(path, v)
    end

    # return 
    return reverse(path)
end
