"""
    dag_longest_path(g, distmx=weights(g); topological_order=topological_sort_by_dfs(g))

DAG longest path algorithm.
Return a longest path of `g`.
The parameter `distmx` defines the distance matrix, while
the parameter `topological_order` defines a topological order of the `vertices(g)`.

# Examples
```jldoctest
julia> using Graphs

julia> g = random_orientation_dag(complete_graph(10); seed = 1)
{10, 45} directed simple Int64 graph

julia> dag_longest_path(g)
10-element Vector{Int64}:
 10
  6
  2
  9
  7
  8
  3
  4
  5
  1

julia> dag_longest_path(g, topological_order = topological_sort_by_dfs(g))
10-element Vector{Int64}:
 10
  6
  2
  9
  7
  8
  3
  4
  5
  1

julia> dag_longest_path(g, weights(g); topological_order = topological_sort_by_dfs(g))
10-element Vector{Int64}:
 10
  6
  2
  9
  7
  8
  3
  4
  5
  1

```
"""
function dag_longest_path end

@traitfn function dag_longest_path(
    g::::IsDirected,
    distmx::AbstractMatrix{T}=weights(g);
    topological_order=topological_sort_by_dfs(g),
   ) where {T<:Real}
    U = eltype(g)
    n::Int = nv(g)
    path::Vector{U} = Vector{U}()

    # edge case
    n == 0 && return path

    dist::Vector{U} = Vector{U}(zeros(n))
    pred::Vector{U} = Vector{U}(1:n)

    # get distances
    for v in topological_order
        for u in inneighbors(g, v)

            newdist::U = dist[u] + distmx[u, v]

            if newdist > dist[v]
                dist[v] = newdist
                pred[v] = u
            end

        end
    end

    # retrieve path 
    v = argmax(x -> dist[x], vertices(g))
    push!(path, v)

    while pred[v] != v
        v = pred[v]
        push!(path, v)
    end

    # return 
    return reverse(path)
end
