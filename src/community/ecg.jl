"""
    ecg(g; γ=1, ensemble_size::Integer=16, min_edge_weight=0.05, distmx::AbstractArray{<:Number}=weights(g), max_moves::Integer=1000, max_merges::Integer=1000, move_tol::Real=10e-10, merge_tol::Real=10e-10, rng=nothing, seed=nothing)

Community detection using ensemble clustering for graphs (ECG). Weights the edges based on the
proportion of time the endpoints are in the same cluster of a Louvain without merges before running
a final Louvain to detect communities.

### Optional Arguments
- `distmx=weights(g)`: distance matrix for weighted graphs
- `ensemble_size=16`: the number of no merge Louvains in the ensemble
- `min_edge_weight`: the minimum edge weight passed to the final Louvain (to retain the original topology).
- `γ=1.0`: where `γ > 0` is a resolution parameter. Higher resolutions lead to more
    communities, while lower resolutions lead to fewer communities. Where `γ=1.0` it
    leads to the traditional definition of the modularity.
- `max_moves=1000`: maximum number of rounds moving vertices before merging for each Louvain.
- `max_merges=1000`: maximum number of merges in the final Louvain.
- `move_tol=10e-10`: necessary increase of modularity to move a vertex in each Louvain.
- `merge_tol=10e-10`: necessary increase of modularity in the move stage to merge in the final Louvain.
- `rng=nothing`: rng to use for reproducibility. May only pass one of rng or seed.
- `seed=nothing`: seed to use for reproducibility. May only pass one of rng or seed.

### References
- [Valérie Poulin and François Théberge. Ensemble Clustering for Graphs: Comparisons and Applications. Applied Network Science, 4:4 (2019)][https://doi.org/10.1007/s41109-019-0162-z]


# Examples 
```jldoctest
julia> using Graphs

julia> barbell = blockdiag(complete_graph(3), complete_graph(3));

julia> add_edge!(barbell, 1, 4);

julia> ecg(barbell)
6-element Vector{Int64}:
 1
 1
 1
 2
 2
 2

julia> ecg(barbell, γ=0.01)
6-element Vector{Int64}:
 1
 1
 1
 1
 1
 1
```
"""
function ecg(
    g::AbstractGraph{T};
    γ=1.0,
    ensemble_size::Integer=16,
    min_edge_weight::Real=0.05,
    distmx::AbstractArray{<:Number}=weights(g),
    max_moves::Integer=1000,
    max_merges::Integer=1000,
    move_tol::Real=10e-10,
    merge_tol::Real=10e-10,
    rng::Union{Nothing,AbstractRNG}=nothing,
    seed::Union{Nothing,Integer}=nothing,
) where {T}
    rng = rng_from_rng_or_seed(rng, seed)
    if nv(g) == 0
        return T[]
    end
    ensemble_weights = ecg_weights(
        g;
        γ=γ,
        ensemble_size=ensemble_size,
        distmx=distmx,
        max_moves=max_moves,
        move_tol=move_tol,
        rng=rng,
    )
    weights =
        (1-min_edge_weight)*ensemble_weights +
        min_edge_weight * adjacency_matrix(g, Float64)
    return louvain(
        g;
        γ=γ,
        distmx=weights,
        max_moves=max_moves,
        max_merges=max_merges,
        move_tol=move_tol,
        merge_tol=merge_tol,
        rng=rng,
    )
end

"""
    ensemble_weights(g; c, distmx, max_moves, move_tol, rng, seed)

Compute edge weights via an ensemble of no merge Louvains. The weight of each edge is
the proportion of time the endpoints are in the same community. 
"""
function ecg_weights(
    g::AbstractGraph{T};
    γ=1.0,
    ensemble_size::Integer=16,
    distmx::AbstractArray{<:Number}=weights(g),
    max_moves::Integer=1000,
    move_tol::Real=10e-10,
    rng::Union{Nothing,AbstractRNG}=nothing,
    seed::Union{Nothing,Integer}=nothing,
) where {T}
    rng = rng_from_rng_or_seed(rng, seed)
    # Create sparse adjacency matrix full of explicit zeros
    ensemble_weights = adjacency_matrix(g, Float64)
    ensemble_weights.nzval .= 0

    for _ in 1:ensemble_size
        ensemble_communities = louvain(
            g;
            γ=γ,
            distmx=distmx,
            max_moves=max_moves,
            max_merges=0,
            move_tol=move_tol,
            rng=rng,
        )
        for e in edges(g)
            if ensemble_communities[src(e)] == ensemble_communities[dst(e)]
                ensemble_weights[src(e), dst(e)] += 1 / ensemble_size
                if !is_directed(g)
                    ensemble_weights[dst(e), src(e)] += 1 / ensemble_size
                end
            end
        end
    end

    return ensemble_weights
end
