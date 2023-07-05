"""
    edge_betweenness_centrality(g, k)

Compute the [edge betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality) of an edge `e`.
It is defined as the sum of the fraction of all-pairs shortest paths that pass through `e`
``
bc(e) =  \\sum_{s, t \\in V}
\\frac{\\sigma_{st}(e)}{\\sigma_{st}}
``.

where `V`, is the set of nodes, \\frac{\\sigma_{st}} is the number of shortest-paths, and \\frac{\\sigma_{st}(e)} is the number of those paths passing through edge.

### Optional Arguments
- `normalize=true`: If true, normalize the betweenness values by the
total number of possible distinct paths between all pairs in the graphs.
For an undirected graph, this number is ``2/(|V|(|V|-1))``
and for a directed graph, ````1/(|V|(|V|-1))````.


### References
- Brandes 2001 & Brandes 2008

# Examples
```jldoctest
julia> using Graphs

julia> Matrix(edge_betweenness_centrality(star_graph(5)))
5×5 Matrix{Float64}:
 0.0  0.4  0.4  0.4  0.4
 0.4  0.0  0.0  0.0  0.0
 0.4  0.0  0.0  0.0  0.0
 0.4  0.0  0.0  0.0  0.0
 0.4  0.0  0.0  0.0  0.0

 julia> Matrix(edge_betweenness_centrality(path_digraph(6), normalize=false))
 6×6 Matrix{Float64}:
  0.0  5.0  0.0  0.0  0.0  0.0
  0.0  0.0  8.0  0.0  0.0  0.0
  0.0  0.0  0.0  9.0  0.0  0.0
  0.0  0.0  0.0  0.0  8.0  0.0
  0.0  0.0  0.0  0.0  0.0  5.0
  0.0  0.0  0.0  0.0  0.0  0.0
"""
function edge_betweenness_centrality(
    g::AbstractGraph,
    vs=vertices(g),
    distmx::AbstractMatrix=weights(g);
    normalize::Bool=true,
)
    k = length(vs)
    edge_betweenness = spzeros(nv(g), nv(g))
    for source in vs
        state = dijkstra_shortest_paths(
            g, source, distmx; allpaths=true, trackvertices=true
        )
        _accumulate_edges!(edge_betweenness, state)
    end
    _rescale_e!(edge_betweenness, nv(g), normalize, is_directed(g), k)

    return edge_betweenness
end

function edge_betweenness_centrality(
    g::AbstractGraph,
    k::Integer,
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    rng::Union{Nothing,AbstractRNG}=nothing,
    seed::Union{Nothing,Integer}=nothing,
)
    return edge_betweenness_centrality(
        g,
        sample(collect_if_not_vector(vertices(g)), k; rng=rng, seed=seed),
        distmx;
        normalize=normalize,
    )
end

function _accumulate_edges!(
    edge_betweenness::AbstractSparseMatrix, state::Graphs.AbstractPathState
)
    σ = state.pathcounts
    pred = state.predecessors
    seen = state.closest_vertices
    δ = Dict(seen .=> 0.0)

    while length(seen) > 0
        w = pop!(seen)

        coeff = (1.0 + δ[w]) / σ[w]
        for v in pred[w]
            c = σ[v] * coeff
            edge_betweenness[v, w] += c
            δ[v] += c
        end
    end
    return nothing
end

function _rescale_e!(
    edge_betweenness::AbstractSparseMatrix,
    n::Integer,
    normalize::Bool,
    directed::Bool,
    k::Integer,
)
    scale = n / k
    if normalize
        if n > 1
            scale *= 1 / (n * (n - 1))
        end
        if !directed
            scale *= 2
        end
    end
    edge_betweenness .*= scale
    return nothing
end
