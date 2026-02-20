"""
    louvain(g, distmx=weights(g), γ=1; max_moves::Integer=1000, max_merges::Integer=1000, move_tol::Real=10e-10, merge_tol::Real=10e-10, rng=nothing, seed=nothing)

Community detection using the louvain algorithm. Finds a partition of the vertices that
attempts to maximize the modularity. Returns a vector of community ids.

### Optional Arguments
- `distmx=weights(g)`: distance matrix for weighted graphs
- `γ=1.0`: where `γ > 0` is a resolution parameter. Higher resolutions lead to more
    communities, while lower resolutions lead to fewer communities. Where `γ=1.0` it
    leads to the traditional definition of the modularity.
- `max_moves=1000`: maximum number of rounds moving vertices before merging.
- `max_merges=1000`: maximum number of merges.
- `move_tol=10e-10`: necessary increase of modularity to move a vertex.
- `merge_tol=10e-10`: necessary increase of modularity in the move stage to merge.
- `rng=nothing`: rng to use for reproducibility. May only pass one of rng or seed.
- `seed=nothing`: seed to use for reproducibility. May only pass one of rng or seed.

### References
- [Vincent D Blondel et al J. Stat. Mech. (2008) P10008][https://doi.org/10.1088/1742-5468/2008/10/P10008]
- [Nicolas Dugué, Anthony Perez. Directed Louvain : maximizing modularity in directed networks.][https://hal.science/hal-01231784/document]

# Examples 
```jldoctest
julia> using Graphs

julia> barbell = blockdiag(complete_graph(3), complete_graph(3));

julia> add_edge!(barbell, 1, 4);

julia> louvain(barbell)
6-element Vector{Int64}:
 1
 1
 1
 2
 2
 2

julia> louvain(barbell, γ=0.01)
6-element Vector{Int64}:
 1
 1
 1
 1
 1
 1
```
"""
function louvain(
    g::AbstractGraph{T};
    γ=1.0,
    distmx::AbstractArray{<:Number}=weights(g),
    max_moves::Integer=1000,
    max_merges::Integer=1000,
    move_tol::Real=10e-10,
    merge_tol::Real=10e-10,
    rng::Union{Nothing,AbstractRNG}=nothing,
    seed::Union{Nothing,Integer}=nothing,
) where {T}
    rng = rng_from_rng_or_seed(rng, seed)
    n = nv(g)
    if n == 0
        return T[]
    end

    @debug "Running louvain with parameters γ=$(γ), max_moves=$(max_move), "*
        "max_merges=$(max_merges), move_tol=$(move_tol), merge_tol=$(merge_tol)"

    actual_coms = collect(one(T):nv(g))
    current_coms = copy(actual_coms)
    # actual_coms is always of length nv(g) and holds the current com for each v in g
    # current_coms is for the current graph; after merges it will be smaller than nv(g)

    for iter in 0:max_merges
        current_modularity = modularity(g, current_coms; distmx=distmx, γ=γ)
        @debug "Merge iteration $(iter). Current modularity is $(current_modularity)"
        louvain_move!(g, γ, current_coms, rng, distmx, max_moves, move_tol)
        # remap communities to 1-nc
        com_map = Dict(old => new for (new, old) in enumerate(unique(current_coms)))
        for i in eachindex(actual_coms)
            actual_coms[i] = com_map[current_coms[actual_coms[i]]]
        end
        @debug "Communities after moving in iteration $(iter): $(acutal_coms)"
        for i in eachindex(current_coms)
            current_coms[i] = com_map[current_coms[i]]
        end

        # Stop if modularity gain is too small
        new_modularity = modularity(g, current_coms; distmx=distmx, γ=γ)
        @debug "New modularity is $(new_modularity) for a gain of $(new_modularity -
        current_modularity)"
        if new_modularity - current_modularity < merge_tol
            break
        end
        g, distmx = louvain_merge(g, current_coms, distmx)
        if nv(g) == 1 # nothing left to merge
            break
        end
        current_coms = collect(one(T):nv(g))
    end
    return actual_coms
end

"""
    louvain_move!(g, γ, c, rng, distmx=weights(g), max_moves=1000, move_tol=10e-10)

The move stage of the louvain algorithm.
"""
function louvain_move!(
    g, γ, c, rng, distmx=weights(g), max_moves::Integer=1000, move_tol::Real=10e-10
)
    vertex_order = shuffle!(rng, collect(vertices(g)))
    nc = maximum(c)

    # Compute graph and community volumes
    m = 0
    c_vols = zeros(eltype(distmx), ((is_directed(g) ? 2 : 1), nc))
    # if is_directed use row 1 for in and 2 for out
    for e in edges(g)
        m += distmx[src(e), dst(e)]
        c_vols[1, c[src(e)]] += distmx[src(e), dst(e)]
        if is_directed(g)
            c_vols[2, c[dst(e)]] += distmx[src(e), dst(e)]
        else
            c_vols[1, c[dst(e)]] += distmx[src(e), dst(e)]
        end
    end

    for _ in 1:max_moves
        last_change = nothing
        for v in vertex_order
            if v == last_change  # stop if we see each vertex and no movement
                return nothing
            end
            potential_coms = unique(c[u] for u in all_neighbors(g, v))
            filter!(!=(c[v]), potential_coms)
            @debug "Moving vertex $(v) from com $(c[v]) to potential_coms $(potential_coms)"
            if isempty(potential_coms)  # Continue if there are no other neighboring coms
                continue
            end
            shuffle!(rng, potential_coms)  # Break ties randomly by first com

            #Remove vertex degrees from current community
            out_degree = sum(
                u == v ? 2distmx[v, u] : distmx[v, u] for u in outneighbors(g, v)
            )
            c_vols[1, c[v]] -= out_degree
            if is_directed(g)
                in_degree = sum(
                    u == v ? 2distmx[v, u] : distmx[v, u] for u in inneighbors(g, v)
                )
                c_vols[2, c[v]] -= in_degree
            end

            # Compute loss in modularity by removing vertex
            loss = ΔQ(g, γ, distmx, c, v, m, c[v], c_vols)
            @debug "Q loss of removing vertex $(v) from its community: $(loss)"
            # Compute gain by moving to alternate neighboring community
            this_ΔQ = c_potential -> ΔQ(g, γ, distmx, c, v, m, c_potential, c_vols)
            best_ΔQ, best_com_id = findmax(this_ΔQ, potential_coms)
            best_com = potential_coms[best_com_id]
            @debug "Best move is to $(best_com) with Q gain of $(best_ΔQ)"
            if best_ΔQ - loss > move_tol
                c[v] = best_com
                c_vols[1, best_com] += out_degree
                if is_directed(g)
                    c_vols[2, best_com] += in_degree
                end
                last_change = v
                @debug "Moved vertex $(v) to community $(best_com)"
            else
                c_vols[1, c[v]] += out_degree
                if is_directed(g)
                    c_vols[2, c[v]] += out_degree
                end
                @debug "Insufficient Q gain, vertex $(v) stays in community $(c[v])"
            end
        end
        if isnothing(last_change) # No movement
            return nothing
        end
    end
end

"""
    ΔQ(g, γ, distmx, c, v, m, c_potential, c_vols)

Compute the change in modularity when adding vertex v a potential community.
"""
function ΔQ(g, γ, distmx, c, v, m, c_potential, c_vols)
    if is_directed(g)
        out_degree = 0
        com_out_degree = 0
        for u in outneighbors(g, v)
            out_degree += distmx[v, u]
            if c[u] == c_potential || u == v
                com_out_degree += distmx[v, u]
            end
        end

        in_degree = 0
        com_in_degree = 0
        for u in inneighbors(g, v)
            in_degree += distmx[u, v]
            if c[u] == c_potential || u == v
                com_in_degree += distmx[u, v]
            end
        end

        # Singleton special case
        if c_vols[1, c_potential] == 0 && c_vols[2, c_potential] == 0
            return (com_in_degree+com_out_degree)/m - γ*2(in_degree + out_degree)/m^2
        end
        return (com_in_degree+com_out_degree)/m -
               γ*(in_degree*c_vols[1, c_potential]+out_degree*c_vols[2, c_potential])/m^2
    else
        degree = 0
        com_degree = 0
        for u in neighbors(g, v)
            degree += u == v ? 2distmx[u, v] : distmx[u, v]
            if u == v
                com_degree += 2distmx[u, v]
            elseif c[u] == c_potential
                com_degree += distmx[u, v]
            end
        end
        # Singleton special case
        if c_vols[1, c_potential] == 0
            return com_degree/2m - γ*(degree/2m)^2
        end
        return com_degree/2m - γ*degree*c_vols[1, c_potential]/2m^2
    end
end

"""
    louvain_merge(g, c, distmx)

Merge stage of the louvain algorithm.
"""
function louvain_merge(g::AbstractGraph{T}, c, distmx) where {T}
    # c is assumed to be 1:nc
    nc = maximum(c)
    new_distmx = Dict{Tuple{T,T},eltype(distmx)}()
    new_graph = is_directed(g) ? SimpleDiGraph{T}(nc) : SimpleGraph{T}(nc)
    for e in edges(g)
        new_src = c[src(e)]
        new_dst = c[dst(e)]
        if haskey(new_distmx, (new_src, new_dst))
            new_distmx[(new_src, new_dst)] += distmx[src(e), dst(e)]
        else
            new_distmx[(new_src, new_dst)] = distmx[src(e), dst(e)]
        end
        add_edge!(new_graph, new_src, new_dst)
    end

    # Convert new_distmx Dict to SparseArray
    r = [k[1] for k in keys(new_distmx)]
    c = [k[2] for k in keys(new_distmx)]
    v = [v for v in values(new_distmx)]
    new_distmx = sparse(r, c, v, nc, nc)

    if !is_directed(new_graph)
        new_distmx = new_distmx + transpose(new_distmx)
        new_distmx[diagind(new_distmx)] ./= 2
    end

    return new_graph, new_distmx
end
