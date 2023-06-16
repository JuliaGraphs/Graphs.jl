# Betweenness centrality measures
# TODO - weighted, separate unweighted, edge betweenness

"""
    betweenness_centrality(g[, vs])
    betweenness_centrality(g, k)

Calculate the [betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality)
of a graph `g` across all vertices, a specified subset of vertices `vs`, or a random subset of `k`
vertices. Return a vector representing the centrality calculated for each node in `g`.

### Optional Arguments
- `normalize=true`: If true, normalize the betweenness values by the
total number of possible distinct paths between all pairs in the graphs.
For an undirected graph, this number is ``\\frac{(|V|-1)(|V|-2)}{2}``
and for a directed graph, ``{(|V|-1)(|V|-2)}``.
- `endpoints=false`: If true, include endpoints in the shortest path count.
Betweenness centrality is defined as:
``
bc(v) = \\frac{1}{\\mathcal{N}} \\sum_{s \\neq t \\neq v}
\\frac{\\sigma_{st}(v)}{\\sigma_{st}}
``.

### References
- Brandes 2001 & Brandes 2008

# Examples
```jldoctest
julia> using Graphs

julia> betweenness_centrality(star_graph(3))
3-element Vector{Float64}:
 1.0
 0.0
 0.0

julia> betweenness_centrality(path_graph(4))
4-element Vector{Float64}:
 0.0
 0.6666666666666666
 0.6666666666666666
 0.0
```
"""
function betweenness_centrality(
    g::AbstractGraph,
    vs=vertices(g),
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false,
)
    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    betweenness = zeros(n_v)
    for s in vs
        if degree(g, s) > 0  # this might be 1?
            state = dijkstra_shortest_paths(g, s, distmx; allpaths=true, trackvertices=true)
            if endpoints
                _accumulate_endpoints!(betweenness, state, g, s)
            else
                _accumulate_basic!(betweenness, state, g, s)
            end
        end
    end

    _rescale!(betweenness, n_v, normalize, isdir, k)

    return betweenness
end

function betweenness_centrality(
    g::AbstractGraph,
    k::Integer,
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false,
    rng::Union{Nothing,AbstractRNG}=nothing,
    seed::Union{Nothing,Integer}=nothing,
)
    return betweenness_centrality(
        g,
        sample(vertices(g), k; rng=rng, seed=seed),
        distmx;
        normalize=normalize,
        endpoints=endpoints,
    )
end

function _accumulate_basic!(
    betweenness::Vector{Float64}, state::DijkstraState, g::AbstractGraph, si::Integer
)
    n_v = length(state.parents) # this is the ttl number of vertices
    δ = zeros(n_v)
    σ = state.pathcounts
    P = state.predecessors

    # make sure the source index has no parents.
    P[si] = []
    # we need to order the source vertices by decreasing distance for this to work.
    S = reverse(state.closest_vertices) # Replaced sortperm with this
    for w in S
        coeff = (1.0 + δ[w]) / σ[w]
        for v in P[w]
            if v > 0
                δ[v] += (σ[v] * coeff)
            end
        end
        if w != si
            betweenness[w] += δ[w]
        end
    end
    return nothing
end

function _accumulate_endpoints!(
    betweenness::Vector{Float64}, state::DijkstraState, g::AbstractGraph, si::Integer
)
    n_v = nv(g) # this is the ttl number of vertices
    δ = zeros(n_v)
    σ = state.pathcounts
    P = state.predecessors
    v1 = collect(Base.OneTo(n_v))
    v2 = state.dists
    S = reverse(state.closest_vertices)
    s = vertices(g)[si]
    betweenness[s] += length(S) - 1    # 289

    for w in S
        coeff = (1.0 + δ[w]) / σ[w]
        for v in P[w]
            δ[v] += σ[v] * coeff
        end
        if w != si
            betweenness[w] += (δ[w] + 1)
        end
    end
    return nothing
end

function _rescale!(
    betweenness::Vector{Float64}, n::Integer, normalize::Bool, directed::Bool, k::Integer
)
    if normalize
        if n <= 2
            do_scale = false
        else
            do_scale = true
            scale = 1.0 / ((n - 1) * (n - 2))
        end
    else
        if !directed
            do_scale = true
            scale = 1.0 / 2.0
        else
            do_scale = false
        end
    end
    if do_scale
        if k > 0
            scale = scale * n / k
        end
        betweenness .*= scale
    end
    return nothing
end
