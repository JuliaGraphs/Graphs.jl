"""
    edge_betweenness_centrality(g[, vertices, distmx]; [normalize]) 
    edge_betweenness_centrality(g, k[, distmx]; [normalize, rng])

Compute the [edge betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality)
of every edge `e` in a graph `g`. Or use a random subset of `k<|V|` vertices
to get an estimate of the edge betweenness centrality. Including more nodes yields better more accurate estimates.
Return a Sparse Matrix representing the centrality calculated for each edge in `g`.
It is defined as the sum of the fraction of all-pairs shortest paths that pass through `e`
``
bc(e) =  \\sum_{s, t \\in V}
\\frac{\\sigma_{st}(e)}{\\sigma_{st}}
``.

where `V`, is the set of nodes, \\frac{\\sigma_{st}} is the number of shortest-paths, and \\frac{\\sigma_{st}(e)} is the number of those paths passing through edge.

### Optional Arguments
`normalize=true` : If set to true, the edge betweenness values will be normalized by the total number of possible distinct paths between all pairs of nodes in the graph. 
For undirected graphs, the normalization factor is calculated as ``2 / (|V|(|V|-1))``, where |V| is the number of vertices. For directed graphs, the normalization factor 
is calculated as ``1 / (|V|(|V|-1))``.
`vs=vertices(g)`: A subset of nodes in the graph g for which the edge betweenness centrality is to be estimated. By including more nodes in this subset, 
you can achieve a better estimate of the edge betweenness centrality.
`distmx=weights(g)`: The weights of the edges in the graph g represented as a matrix. This argument allows you to specify custom weights for the edges. 
The weights can be used to influence the calculation of betweenness centrality, giving higher importance to certain edges over others.
`rng`: A random number generator used for selecting k vertices. This argument allows you to provide a custom random number generator that will be used for the vertex selection process. 


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

  julia> g = SimpleGraph(Edge.([(1, 2), (2, 3), (2, 5), (3, 4), (4, 5), (5, 6)]));
  julia> distmx = [
             0.0 2.0 0.0 0.0 0.0 0.0
             2.0 0.0 4.2 0.0 1.2 0.0
             0.0 4.2 0.0 5.5 0.0 0.0
             0.0 0.0 5.5 0.0 0.9 0.0
             0.0 1.2 0.0 0.9 0.0 0.6
             0.0 0.0 0.0 0.0 0.6 0.0
         ];
  
  julia> Matrix(edge_betweenness_centrality(g; distmx=distmx, normalize=true))
  6×6 Matrix{Float64}:
   0.0       0.333333  …  0.0       0.0
   0.333333  0.0          0.533333  0.0
   0.0       0.266667     0.0       0.0
   0.0       0.0          0.266667  0.0
   0.0       0.533333     0.0       0.333333
   0.0       0.0       …  0.333333  0.0
"""

function edge_betweenness_centrality(
    g::AbstractGraph;
    vs=vertices(g),
    distmx::AbstractMatrix=weights(g),
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
    k::Integer;
    distmx::AbstractMatrix=weights(g),
    normalize=true,
    rng::Union{Nothing,AbstractRNG}=nothing,
)
    return edge_betweenness_centrality(
        g;
        vs=sample(collect_if_not_vector(vertices(g)), k; rng=rng),
        distmx=distmx,
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
