
"""
    struct JohnsonState{T, U}

An [`AbstractPathState`](@ref) designed for Johnson shortest-paths calculations.

# Fields

- `dists::Matrix{T}`: `dists[u, v]` is the length of the shortest path from `u` to `v` 
- `parents::Matrix{U}`: `parents[u, v]` is the predecessor of vertex `v` on the shortest path from `u` to `v`
"""
struct JohnsonState{T<:Real,U<:Integer} <: AbstractPathState
    dists::Matrix{T}
    parents::Matrix{U}
end

"""
    johnson_shortest_paths(g, distmx=weights(g))

Use the [Johnson algorithm](https://en.wikipedia.org/wiki/Johnson%27s_algorithm)
to compute the shortest paths between all pairs of vertices in graph `g` using an
optional distance matrix `distmx`.

Return a [`Graphs.JohnsonState`](@ref) with relevant
traversal information (try querying `state.parents` or `state.dists`).

### Performance
Complexity: `O(|V|*|E|)`
"""
function johnson_shortest_paths(
    g::AbstractGraph{U}, distmx::AbstractMatrix{T}=weights(g)
) where {T<:Real} where {U<:Integer}
    nvg = nv(g)
    type_distmx = typeof(distmx)
    # Change when parallel implementation of Bellman Ford available
    wt_transform =
        bellman_ford_shortest_paths(g, collect_if_not_vector(vertices(g)), distmx).dists

    @compat if !ismutable(distmx) && type_distmx != Graphs.DefaultDistance
        distmx = sparse(distmx) # Change reference, not value
    end

    # Weight transform not needed if all weights are positive.
    if type_distmx != Graphs.DefaultDistance
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[src(e)] - wt_transform[dst(e)]
        end
    end

    dists = Matrix{T}(undef, nvg, nvg)
    parents = Matrix{U}(undef, nvg, nvg)
    for v in vertices(g)
        dijk_state = dijkstra_shortest_paths(g, v, distmx)
        dists[v, :] = dijk_state.dists
        parents[v, :] = dijk_state.parents
    end

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

function enumerate_paths(
    s::JohnsonState{T,U}, v::Integer
) where {T<:Real} where {U<:Integer}
    pathinfo = s.parents[v, :]
    paths = Vector{Vector{U}}()
    for i in 1:length(pathinfo)
        if (i == v) || (s.dists[v, i] == typemax(T))
            push!(paths, Vector{U}())
        else
            path = Vector{U}()
            currpathindex = U(i)
            while currpathindex != 0
                push!(path, currpathindex)
                currpathindex = pathinfo[currpathindex]
            end
            push!(paths, reverse(path))
        end
    end
    return paths
end

enumerate_paths(s::JohnsonState) = [enumerate_paths(s, v) for v in 1:size(s.parents, 1)]
enumerate_paths(st::JohnsonState, s::Integer, d::Integer) = enumerate_paths(st, s)[d]
