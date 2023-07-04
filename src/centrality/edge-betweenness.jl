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
For an undirected graph, this number is ``\\frac{(|V|-1)(|V|-2)}{2}``
and for a directed graph, ``{(|V|-1)(|V|-2)}``.


### References
- Brandes 2001 & Brandes 2008

# Examples
```jldoctest
julia> using Graphs

julia> edge_betweenness_centrality(star_graph(5))
Dict{Graphs.SimpleGraphs.SimpleEdge{Int64}, Float64} with 4 entries:
  Edge 1 => 2 => 0.4
  Edge 1 => 3 => 0.4
  Edge 1 => 4 => 0.4
  Edge 1 => 5 => 0.4

julia> edge_betweenness_centrality(path_digraph(6))
Dict{Graphs.SimpleGraphs.SimpleEdge{Int64}, Float64} with 5 entries:
  Edge 4 => 5 => 0.266667
  Edge 1 => 2 => 0.166667
  Edge 3 => 4 => 0.3
  Edge 5 => 6 => 0.166667
  Edge 2 => 3 => 0.266667
```
"""

function edge_betweenness_centrality(
    g::AbstractGraph, vs=vertices(g), distmx::AbstractMatrix=weights(g); normalize=true
)
    edge_betweenness = Dict(edges(g) .=> 0.0)
    for o in vs
        state = dijkstra_shortest_paths(g, o, distmx; allpaths=true, trackvertices=true)
        _accumulate_edges!(edge_betweenness, state)
    end
    _rescale_e!(edge_betweenness, nv(g), normalize, is_directed(g))

    return edge_betweenness
end

function _accumulate_edges!(edge_betweenness::AbstractDict, state::Graphs.AbstractPathState)
    σ = state.pathcounts
    pred = state.predecessors
    seen = state.closest_vertices
    δ = Dict(seen .=> 0.0)

    while length(seen) > 0
        w = pop!(seen)

        coeff = (1.0 + δ[w]) / σ[w]
        for v in pred[w]
            c = σ[v] * coeff
            if Edge(v, w) ∉ edge_betweenness.keys
                edge_betweenness[Edge(w, v)] += c
            else
                edge_betweenness[Edge(v, w)] += c
                δ[v] += c
            end
        end
    end
    return nothing
end

function _rescale_e!(
    edge_betweenness::AbstractDict, n::Integer, normalize::Bool, directed::Bool=false
)
    if normalize
        if n <= 1
            scale = nothing  # no normalization b=0 for all nodes
        else
            scale = 1 / (n * (n - 1))
        end
    else  # rescale by 2 for undirected graphs
        if !directed
            scale = 0.5
        else
            scale = nothing
        end
    end
    if scale !== nothing
        for (k, v) in edge_betweenness
            edge_betweenness[k] *= scale
        end
    end
    return nothing
end
