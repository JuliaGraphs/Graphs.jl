using LinearAlgebra

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
    n == 0 && return T[]

    actual_coms = collect(one(T):nv(g))
    current_coms = copy(actual_coms)

    @debug "Initial coms: $(actual_coms)"
    for iter in 0:max_merges
        current_modularity = modularity(g, current_coms, distmx=distmx, γ=γ)
        @debug "Current modularity $(current_modularity)"
        @debug "Iter $(iter) moving nodes"
        louvain_move!(g, γ, current_coms, rng, distmx, max_moves, move_tol)
        # remap communities to 1-nc
        @debug "Done moving nodes. Coms are $(current_coms)"
        com_map = Dict(old => new for (new,old) in enumerate(unique(current_coms)))
        @debug "Com map $(com_map)"
        for i in eachindex(actual_coms)
            actual_coms[i] = com_map[current_coms[actual_coms[i]]]
        end
        @debug "Updated actual coms $(actual_coms)"
        for i in eachindex(current_coms)
            current_coms[i] = com_map[current_coms[i]]
        end
        @debug "Reindexed coms $(current_coms)"

        # Stop if modularity gain is too small
        new_modularity = modularity(g, current_coms, distmx=distmx, γ=γ)
        @debug "New modularity is $(new_modularity) for a gain of $(new_modularity - current_modularity). Stop = $(new_modularity - current_modularity < merge_tol)"
        if new_modularity - current_modularity < merge_tol
            break
        end
        g, distmx = louvain_merge(g, current_coms, distmx)
        current_coms = collect(one(T):nv(g))
    end
    return actual_coms
end

function louvain_move!(
    g,
    γ,
    c,
    rng,
    distmx=weights(g),
    max_moves::Integer=1000,
    move_tol::Real=10e-5,
)
    vertex_order = shuffle!(rng, collect(vertices(g)))

    #Precompute community volumes
    nc = maximum(c)
    c_vols = zeros(eltype(distmx), ((is_directed(g) ? 2 : 1), nc)) # if directed use row 1 for in and 2 for out
    m = 0
    for e in edges(g)
        m += distmx[src(e), dst(e)]
        c_vols[1, c[src(e)]] += distmx[src(e), dst(e)]
        if is_directed(g)
            c_vols[2, c[dst(e)]] += distmx[src(e), dst(e)]
        elseif src(e) != dst(e)
            c_vols[1, c[dst(e)]] += distmx[src(e), dst(e)]
        else
            m -= distmx[src(e), dst(e)]/2  # don't double count loop weights
        end
    end
    
    @debug "vols $(c_vols)"
    
    for _ in 1:max_moves
        any_changes = false
        for v in vertex_order
            potential_coms = unique(c[u] for u in all_neighbors(g, v))
            filter!(!=(c[v]), potential_coms)
            @debug "Moving vertex $(v) from com $(c[v]) to potential_coms $(potential_coms)"
            # Continue if there are no other neighboring coms
            if isempty(potential_coms)
                continue
            end
            # Break ties randomly by first com
            shuffle!(rng, potential_coms)

            #Remove vertex degrees from current communities
            @debug "Remove node $(v) from community $(c[v])"
            @debug "Before vols $(c_vols)"
            out_degree = sum(distmx[v,u] for u in outneighbors(g,v))
            c_vols[1, c[v]] -= out_degree
            if is_directed(g)
                in_degree = sum(distmx[u,v] for u in inneighbors(g,v))
                c_vols[2, c[v]] -= in_degree
            end
            @debug "After vols $(c_vols)"

            # Compute loss in modularity by removing node
            loss = ΔQ(g, γ, distmx, c, v, m, c[v], c_vols)
            @debug "Q loss from removing v: $(loss)"
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
                any_changes = true
                @debug "Moved! New coms are $(c)"
            else
                c_vols[1, c[v]] += out_degree
                if is_directed(g)
                    c_vols[2, c[v]] += out_degree
                end
                @debug "Didn't move. coms are $(c)"
            end
        end
        if !any_changes
            break
        end
    end
end

function ΔQ(g, γ, distmx, c, v, m, c_potential, c_vols)
    if is_directed(g)
        out_degree = 0
        out_com_degree = 0
        for u in outneighbors(g, v)
            out_degree += distmx[v,u]
            if c[u] == c_potential || u == v
                com_out_degree += distmx[v,u]
            end
        end

        in_degree = 0
        com_in_degree = 0
        for u in inneighbors(g, v)
            in_degree += distmx[u,v]
            if c[u] == c_potential || u == v
                com_in_degree += distmx[u,v]
            end
        end

        # Singleton special case
        if c_vols[1,c_potential] == 0 && c_vols[2,c_potential] == 0
            return 2com_in_degree/m - γ*2(in_degree + out_degree) / m^2
        end

        return (com_in_degree+out_com_degree)/m - γ*(in_degree*c_vols[1,c_potential]+out_degree*c_vols[2,c_potential])/m^2
    else
        degree = 0
        com_degree = 0
        for u in neighbors(g, v)
            degree += distmx[u,v]
            if c[u] == c_potential || u == v
                com_degree += distmx[u,v]
            end
        end

        # # Singleton special case
        if c_vols[1,c_potential] == 0
            return com_degree/2m - γ*(degree/2m)^2
        end
        # @debug m
        # @debug "Degree $(degree)"
        # @debug "Com Degree $(com_degree)"
        # @debug "Vols $(c_vols)"
        # @debug "DQ $(com_degree/2m - γ*degree*(c_vols[1,c_potential])/2m^2)"
        return com_degree/2m - γ*degree*(c_vols[1,c_potential])/2m^2
    end
end

function louvain_merge(
    g::AbstractGraph{T},
    c,
    distmx,
) where {T}
    # c is assumed to be 1:nc
    nc = maximum(c)
    new_distmx = Dict{Tuple{T,T}, eltype(distmx)}()
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

    @debug new_distmx

    # Convert new_distmx Dict to SparseArray
    r = [k[1] for k in keys(new_distmx)]
    c = [k[2] for k in keys(new_distmx)]
    v = [v for v in values(new_distmx)]
    new_distmx = sparse(r, c, v, nc, nc)

    if !is_directed(new_graph)
        new_distmx = new_distmx + transpose(new_distmx)
        # new_distmx[diagind(new_distmx)] ./= 2  # double counts with addition
    end
    @debug "NC: $(nc)"
    @debug new_distmx
    return new_graph, new_distmx
end