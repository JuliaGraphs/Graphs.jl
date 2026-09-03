# kadabra.jl

"""
    estimate_diameter(g::AbstractGraph)

Computes an upper bound on the diameter of the graph using the AllCCUpperBound technique
(Borassi et al. 2015). Highly efficient for both directed and undirected graphs.
"""
function estimate_diameter(g::AbstractGraph)
    n = nv(g)
    n == 0 && return 0.0
    n == 1 && return 0.0

    # 1. Compute strongly/connected components
    sccs = is_directed(g) ? strongly_connected_components(g) : connected_components(g)
    n_components = length(sccs)

    # Map each vertex to its component index
    cc = zeros(Int, n)
    for (i, component) in enumerate(sccs)
        for v in component
            cc[v] = i
        end
    end

    # 2. Compute pivots for each component
    # The pivot vertex is the vertex maximizing the sum of the out-degree and the in-degree.
    pivots = zeros(Int, n_components)
    for i in 1:n_components
        component = sccs[i]
        best_v = component[1]
        best_deg = outdegree(g, best_v) + indegree(g, best_v)
        for v in component
            deg = outdegree(g, v) + indegree(g, v)
            if deg > best_deg
                best_v = v
                best_deg = deg
            end
        end
        pivots[i] = best_v
    end

    # 3. Compute SCC adjacency graph (DAG of components)
    cc_adj = [Set{Int}() for _ in 1:n_components]
    for u in 1:n
        for v in outneighbors(g, u)
            if cc[u] != cc[v]
                push!(cc_adj[cc[u]], cc[v])
            end
        end
    end

    # 4. Helper BFS to compute eccentricity of pivot in its SCC.
    ecc_dist = fill(-1, n)

    function compute_ecc_in_scc(start::Int, backward::Bool)
        fill!(ecc_dist, -1)
        q = Int[]
        push!(q, start)
        ecc_dist[start] = 0

        head = 1
        while head <= length(q)
            u = q[head]
            head += 1

            neighbors = backward ? inneighbors(g, u) : outneighbors(g, u)
            for v in neighbors
                if ecc_dist[v] == -1 && cc[v] == cc[u]
                    ecc_dist[v] = ecc_dist[u] + 1
                    push!(q, v)
                end
            end
        end

        return isempty(q) ? 0 : ecc_dist[q[end]]
    end

    # 5. Compute forward and backward eccentricities of pivots in their SCCs
    ecc_f_pivots_scc = zeros(Float64, n_components)
    ecc_b_pivots_scc = zeros(Float64, n_components)
    for i in 1:n_components
        ecc_f_pivots_scc[i] = compute_ecc_in_scc(pivots[i], false)
        ecc_b_pivots_scc[i] = compute_ecc_in_scc(pivots[i], true)
    end

    # 6. DP to compute bounds across components (memoized DFS).
    ecc_f_pivots = fill(-1.0, n_components)

    function get_ecc_f_pivot(i::Int)
        ecc_f_pivots[i] != -1.0 && return ecc_f_pivots[i]

        val = ecc_f_pivots_scc[i]
        for cc_dest in cc_adj[i]
            val = max(
                val,
                ecc_f_pivots_scc[i] +
                1 +
                ecc_b_pivots_scc[cc_dest] +
                get_ecc_f_pivot(cc_dest),
            )
        end
        ecc_f_pivots[i] = val
        return val
    end

    diam = 0.0
    for i in 1:n_components
        diam = max(diam, get_ecc_f_pivot(i) + ecc_b_pivots_scc[i])
    end

    return max(diam, 1.0)
end

"""
    kadabra_centrality(g::AbstractGraph, k::Int, err::Float64, delta::Float64; kwargs...)

Estimates the betweenness centrality of vertices in graph `g` using the KADABRA algorithm
(Borassi & Natale, 2019). KADABRA is an adaptive sampling algorithm that guarantees the
estimated betweenness is within an additive error bound with high probability.

Weighted graphs are not supported; passing a `distmx` argument throws an `ArgumentError`.

# Arguments
- `g::AbstractGraph`: The input graph (directed or undirected).
- `k::Int`: If `k = 0`, guarantees absolute error `err` for all vertices. If `k > 0`,
  guarantees the relative ranking of the top `k` vertices is correct within the error bound.
- `err::Float64`: The maximum additive error tolerance (e.g., 0.01). Must be positive.
- `delta::Float64`: The confidence parameter. Results are guaranteed with probability `1 - delta`. Must lie in `(0, 1)`.

# Keyword arguments
- `start_factor::Int`: Scales the initial burn-in phase duration, which draws `omega / start_factor` samples (default: 100).
- `endpoints::Bool`: If true, include the endpoints of the sampled shortest paths in the centrality counts (default: false).
- `normalize::Symbol`: How to normalize the output. `:graphs` matches Graphs.jl, `:kadabra` matches the raw KADABRA paper output, `:none` returns unnormalized counts (default: `:graphs`).
- `parallel::Bool`: If true, sample with `Threads.nthreads()` tasks; if false, use a single sampling stream (default: true).
- `rng::Union{AbstractRNG,Nothing}`: Seed source for reproducible runs (default: `nothing`, i.e. the global RNG). With `parallel=false` the output is bit-identical across runs with the same seed. With `parallel=true` each worker's sampling stream is seeded deterministically, but how many samples each worker contributes before the shared stopping condition fires depends on thread scheduling, so estimates vary slightly between runs (within the `err` guarantee). Use `parallel=false` when exact reproducibility is required.

# Returns
A `NamedTuple` with fields:
- `centralities::Vector{Float64}`: the betweenness estimate per vertex.
- `lower_bounds::Vector{Float64}`, `upper_bounds::Vector{Float64}`: per-vertex confidence-interval endpoints, scaled by the same `normalize` convention.
- `n_samples::Int`: total shortest-path pairs sampled, including the burn-in phase.
- `omega::Float64`: the worst-case sample budget implied by `err`, `delta`, and the estimated diameter.
- `tau::Int`: the burn-in sample count.

# Examples
```julia
res = kadabra_centrality(g, 0, 0.01, 0.1)            # absolute error 0.01 for every vertex
res = kadabra_centrality(g, 10, 0.01, 0.1)           # rank the top 10 vertices
res = kadabra_centrality(g, 0, 0.01, 0.1; rng=Xoshiro(42), parallel=false)  # reproducible
res.centralities, res.lower_bounds, res.n_samples
```
"""
function kadabra_centrality(
    g::AbstractGraph{T},
    k::Int,
    err::Float64,
    delta::Float64;
    start_factor::Int=100,
    endpoints::Bool=false,
    normalize::Symbol=:graphs,
    parallel::Bool=true,
    rng::Union{AbstractRNG,Nothing}=nothing,
) where {T}
    nv(g) >= 2 || throw(ArgumentError("Graph must have at least 2 vertices (got $(nv(g)))"))
    err > 0 || throw(ArgumentError("err must be positive (got $err)"))
    0 < delta < 1 || throw(ArgumentError("delta must be in (0, 1) (got $delta)"))

    n = Int(nv(g))
    absolute = (k == 0)
    original_k = k
    k = Int(k == 0 ? n : min(k, n))

    diam_est = max(estimate_diameter(g), 2.0)

    omega = 0.5 / (err^2) * (log2(diam_est - 1.0) + 1.0 + log(0.5 / delta))
    tau = max(round(Int, omega / start_factor), 1)

    # Matches the C++ reference's union_sample sizing (Probabilistic.cpp:326-328):
    # a small "hardest vertices" tracking set, not all n vertices.
    nthreads_for_sizing = Threads.nthreads()
    union_target = max(2.0 * sqrt(ne(g)) / nthreads_for_sizing, Float64(original_k) + 20.0)
    union_sample = min(n, Int(floor(union_target)))

    global_approx = zeros(Int, n)

    # Filled in by compute_delta_guess! after the Phase 1 burn-in; uninitialized until then.
    delta_l_guess = zeros(Float64, n)
    delta_u_guess = zeros(Float64, n)

    bet_buf = zeros(Float64, union_sample)
    err_l_buf = zeros(Float64, union_sample)
    err_u_buf = zeros(Float64, union_sample)
    top_k_nodes = collect(1:n)

    base_rng = rng === nothing ? default_rng() : rng
    final_n_pairs = 0

    if parallel
        nthreads = Threads.nthreads()

        approx_local = [zeros(Int, n) for _ in 1:nthreads]
        tau_per_thread = cld(tau, nthreads)
        actual_tau = tau_per_thread * nthreads

        # Generate seeds beforehand to avoid base_rng thread-safety issues
        thread_seeds = [rand(base_rng, UInt64) for _ in 1:nthreads]

        # --- PHASE 1: burn-in. No stopping check, samples are discarded after calibration. ---
        phase1_tasks = Vector{Task}(undef, nthreads)
        for i in 1:nthreads
            phase1_tasks[i] = let tid = i, seed = thread_seeds[i]
                Threads.@spawn begin
                    local ws = KadabraWorkspace(g)
                    local counts = approx_local[tid]
                    local t_rng = Xoshiro(seed)

                    for _ in 1:tau_per_thread
                        s = rand(t_rng, 1:n)
                        t = rand(t_rng, 1:n)
                        while s == t
                            t = rand(t_rng, 1:n)
                        end
                        sample_shortest_path!(
                            counts, ws, g, t_rng, T(s), T(t); endpoints=endpoints
                        )
                    end
                end
            end
        end
        wait.(phase1_tasks)

        fill!(global_approx, 0)
        for t_approx in approx_local
            global_approx .+= t_approx
        end

        # --- CALIBRATION: derive per-vertex delta_l_guess/delta_u_guess from Phase 1 estimates ---
        copyto!(top_k_nodes, 1:n)
        partialsort!(top_k_nodes, 1:union_sample; by=x -> global_approx[x], rev=true)
        compute_delta_guess!(
            delta_l_guess,
            delta_u_guess,
            view(top_k_nodes, 1:union_sample),
            global_approx,
            actual_tau,
            n,
            k,
            absolute,
            err,
            delta,
            start_factor,
        )

        # --- RESET: Phase 1 samples are thrown away; Phase 2 starts from scratch ---
        fill!(global_approx, 0)
        for t_approx in approx_local
            fill!(t_approx, 0)
        end

        n_pairs2 = Threads.Atomic{Int}(0)
        stop_flag = Threads.Atomic{Bool}(false)
        check_lock = Threads.SpinLock()
        check_interval = max(1000, tau ÷ 10)

        # --- PHASE 2: fresh sampling round, checked against the calibrated deltas ---
        phase2_tasks = Vector{Task}(undef, nthreads)
        for i in 1:nthreads
            phase2_tasks[i] = let tid = i, seed = thread_seeds[i]
                Threads.@spawn begin
                    local ws = KadabraWorkspace(g)
                    local counts = approx_local[tid]
                    local t_rng = Xoshiro(seed)

                    local_pairs = 0
                    while !stop_flag[] && n_pairs2[] < omega
                        for _ in 1:check_interval
                            s = rand(t_rng, 1:n)
                            t = rand(t_rng, 1:n)
                            while s == t
                                t = rand(t_rng, 1:n)
                            end
                            sample_shortest_path!(
                                counts, ws, g, t_rng, T(s), T(t); endpoints=endpoints
                            )
                            local_pairs += 1
                        end

                        Threads.atomic_add!(n_pairs2, local_pairs)
                        local_pairs = 0

                        if trylock(check_lock)
                            try
                                if stop_flag[]
                                    continue
                                end

                                fill!(global_approx, 0)
                                for t_approx in approx_local
                                    for v in 1:n
                                        global_approx[v] += t_approx[v]
                                    end
                                end

                                copyto!(top_k_nodes, 1:n)
                                partialsort!(
                                    top_k_nodes,
                                    1:union_sample;
                                    by=x -> global_approx[x],
                                    rev=true,
                                )

                                if check_finished(
                                    global_approx,
                                    view(top_k_nodes, 1:union_sample),
                                    n_pairs2[],
                                    k,
                                    err,
                                    delta_l_guess,
                                    delta_u_guess,
                                    omega,
                                    absolute,
                                    bet_buf,
                                    err_l_buf,
                                    err_u_buf,
                                )
                                    Threads.atomic_xchg!(stop_flag, true)
                                end
                            finally
                                unlock(check_lock)
                            end
                        end
                    end
                end
            end
        end

        # Wait for all worker tasks to finish safely
        wait.(phase2_tasks)

        # Final accurate aggregation of all counts
        fill!(global_approx, 0)
        for t_approx in approx_local
            global_approx .+= t_approx
        end
        final_n_pairs = n_pairs2[] + tau
    else
        ws = KadabraWorkspace(g)
        s_rng = rng === nothing ? default_rng() : rng
        counts = global_approx

        # --- PHASE 1: burn-in. No stopping check, samples are discarded after calibration. ---
        for _ in 1:tau
            s = rand(s_rng, 1:n)
            t = rand(s_rng, 1:n)
            while s == t
                t = rand(s_rng, 1:n)
            end
            sample_shortest_path!(counts, ws, g, s_rng, T(s), T(t); endpoints=endpoints)
        end

        # --- CALIBRATION: derive per-vertex delta_l_guess/delta_u_guess from Phase 1 estimates ---
        copyto!(top_k_nodes, 1:n)
        partialsort!(top_k_nodes, 1:union_sample; by=x -> counts[x], rev=true)
        compute_delta_guess!(
            delta_l_guess,
            delta_u_guess,
            view(top_k_nodes, 1:union_sample),
            counts,
            tau,
            n,
            k,
            absolute,
            err,
            delta,
            start_factor,
        )

        # --- RESET: Phase 1 samples are thrown away; Phase 2 starts from scratch ---
        fill!(counts, 0)

        phase2_pairs = 0
        stop_flag_seq = false
        check_interval = max(1000, tau ÷ 10)

        # --- PHASE 2: fresh sampling round, checked against the calibrated deltas ---
        while !stop_flag_seq && phase2_pairs < omega
            for _ in 1:check_interval
                s = rand(s_rng, 1:n)
                t = rand(s_rng, 1:n)
                while s == t
                    t = rand(s_rng, 1:n)
                end
                sample_shortest_path!(counts, ws, g, s_rng, T(s), T(t); endpoints=endpoints)
                phase2_pairs += 1
            end

            copyto!(top_k_nodes, 1:n)
            partialsort!(top_k_nodes, 1:union_sample; by=x -> counts[x], rev=true)

            if check_finished(
                counts,
                view(top_k_nodes, 1:union_sample),
                phase2_pairs,
                k,
                err,
                delta_l_guess,
                delta_u_guess,
                omega,
                absolute,
                bet_buf,
                err_l_buf,
                err_u_buf,
            )
                stop_flag_seq = true
            end
        end
        final_n_pairs = phase2_pairs + tau
    end

    res = [global_approx[v] / final_n_pairs for v in 1:n]
    lower_bounds = Float64[
        max(0.0, res[v] - compute_f(res[v], final_n_pairs, delta_l_guess[v], omega)) for
        v in 1:n
    ]
    upper_bounds = Float64[
        min(1.0, res[v] + compute_g(res[v], final_n_pairs, delta_u_guess[v], omega)) for
        v in 1:n
    ]

    scale = 1.0
    if normalize == :graphs
        scale = n > 2 ? (n * (n - 1.0)) / ((n - 1.0) * (n - 2.0)) : 0.0
    elseif normalize == :none
        scale = is_directed(g) ? (n * (n - 1.0)) : (n * (n - 1.0)) / 2.0
    elseif normalize == :kadabra
        scale = 1.0
    else
        throw(
            ArgumentError(
                "Unknown normalize option: $normalize. Use :graphs, :kadabra, or :none."
            ),
        )
    end

    if scale != 1.0
        res .*= scale
        lower_bounds .*= scale
        upper_bounds .*= scale
    end

    return (
        centralities=res,
        lower_bounds=lower_bounds,
        upper_bounds=upper_bounds,
        n_samples=final_n_pairs,
    )
end

function kadabra_centrality(
    g::AbstractGraph{T},
    k::Int,
    err::Float64,
    delta::Float64,
    distmx::AbstractMatrix;
    kwargs...,
) where {T}
    return throw(
        ArgumentError(
            "KADABRA centrality does not support weighted graphs. Please do not provide a distmx argument.",
        ),
    )
end

"""
    kadabra_top_k(g::AbstractGraph, k::Int, err::Float64, delta::Float64; kwargs...)

Convenience wrapper that runs KADABRA and efficiently extracts the top `k` most central nodes.
Due to adaptive sampling, nodes with overlapping confidence intervals near the k-th rank cannot 
be strictly ordered. Therefore, this function returns a candidate set of size `k' >= k` that 
contains the true top-k nodes with high probability.
As in `kadabra_centrality`, `k` is clamped to `nv(g)`.
Returns a vector of `NamedTuple`s containing the `node` ID, its `centrality` score, 
`lower_bound`, and `upper_bound`, sorted in descending order of centrality.
"""
function kadabra_top_k(
    g::AbstractGraph{T}, k::Int, err::Float64, delta::Float64; kwargs...
) where {T}
    k > 0 || throw(ArgumentError("k must be greater than 0 to extract top k nodes"))
    # `kadabra_centrality` clamps `k` to `nv(g)`; do the same here so that the
    # `partialsort` below stays in bounds when more nodes are requested than exist.
    k = min(k, Int(nv(g)))

    # Run the standard Kadabra algorithm
    res = kadabra_centrality(g, k, err, delta; kwargs...)
    centralities = res.centralities
    lower_bounds = res.lower_bounds
    upper_bounds = res.upper_bounds

    # Find the candidate threshold by determining the k-th highest lower bound
    k_th_lower_bound = partialsort(lower_bounds, k; rev=true)

    # Filter candidate nodes where upper_bound >= k_th_lower_bound
    candidate_nodes = findall(u -> u >= k_th_lower_bound, upper_bounds)

    # Sort candidate nodes by centrality in descending order
    sort!(candidate_nodes; by=v -> centralities[v], rev=true)

    return [
        (
            node=v,
            centrality=centralities[v],
            lower_bound=lower_bounds[v],
            upper_bound=upper_bounds[v],
        ) for v in candidate_nodes
    ]
end

function kadabra_top_k(
    g::AbstractGraph{T},
    k::Int,
    err::Float64,
    delta::Float64,
    distmx::AbstractMatrix;
    kwargs...,
) where {T}
    return throw(
        ArgumentError(
            "KADABRA centrality does not support weighted graphs. Please do not provide a distmx argument.",
        ),
    )
end

"""
    compute_f(btilde, iter_num, delta_l, omega)

Computes the Chernoff bound error function `f` that bounds the betweenness of a vertex from below.
Evaluated dynamically during Phase 2 to determine if the lower bound of the confidence interval
satisfies the stopping condition.
"""
function compute_f(btilde::Float64, iter_num::Int, delta_l::Float64, omega::Float64)
    tmp = (omega / iter_num) - (1.0 / 3.0)
    err_chern =
        (log(1.0 / delta_l) / iter_num) *
        (-tmp + sqrt(tmp^2 + 2.0 * btilde * omega / log(1.0 / delta_l)))
    return min(err_chern, btilde)
end

"""
    compute_g(btilde, iter_num, delta_u, omega)

Computes the Chernoff bound error function `g` that bounds the betweenness of a vertex from above.
Evaluated dynamically during Phase 2 to determine if the upper bound of the confidence interval
satisfies the stopping condition.
"""
function compute_g(btilde::Float64, iter_num::Int, delta_u::Float64, omega::Float64)
    tmp = (omega / iter_num) + (1.0 / 3.0)
    err_chern =
        (log(1.0 / delta_u) / iter_num) *
        (tmp + sqrt(tmp^2 + 2.0 * btilde * omega / log(1.0 / delta_u)))
    return min(err_chern, 1.0 - btilde)
end

"""
    compute_bet_err!(bet, err_l, err_u, n_pairs, k_target, absolute, err, start_factor)

Port of the C++ reference's `compute_bet_err` (Probabilistic.cpp:216-257). Given the
current (Phase-1) betweenness estimates `bet` for the tracked top `union_sample` vertices
(sorted descending, already filled in by the caller), fills in `err_l`/`err_u`: the
per-vertex error budgets used to derive calibrated confidence-interval widths in
[`compute_delta_guess!`](@ref). In absolute-error mode every vertex gets the same
budget `err`; in top-k mode the budget depends on how close each vertex's estimate is
to its rank-neighbors.
"""
function compute_bet_err!(
    bet::Vector{Float64},
    err_l::Vector{Float64},
    err_u::Vector{Float64},
    n_pairs::Int,
    k_target::Int,
    absolute::Bool,
    err::Float64,
    start_factor::Int,
)
    union_sample = length(bet)
    # The top-k budgets reference rank neighbours at positions up to `k_target + 1`, so they
    # are only defined when the tracking set extends past rank k. That holds for any graph
    # large enough to make top-k meaningful, but not for tiny ones (e.g. a JIT-warmup graph
    # with fewer vertices than k), where we fall back to the uniform budget. The C++
    # reference indexes past the end of its array here instead of guarding.
    if absolute || union_sample <= k_target
        fill!(err_l, err)
        fill!(err_u, err)
    else
        max_err = sqrt(start_factor) * err / 4
        # Borassi & Natale, Section 5.2. The stopping test (`check_finished`) separates
        # v_i from v_{i+1} by requiring b(v_i) - f(v_i) > b(v_{i+1}) + g(v_{i+1}), so a
        # vertex's *lower* budget is sized by the gap below it and its *upper* budget by
        # the gap above; v_1 has nothing above it, so its upper budget is unconstrained.
        # The authors' C++ reference pairs these the other way round, which leaves v_1's
        # lower budget --- the one its own test consults --- pinned at the minimum. We
        # follow the paper: it costs no accuracy and needs no more samples.
        err_l[1] = max(err, (bet[1] - bet[2]) / 2)
        err_u[1] = 10.0
        for i in 2:k_target
            err_l[i] = max(err, (bet[i] - bet[i + 1]) / 2)
            err_u[i] = max(err, (bet[i - 1] - bet[i]) / 2)
        end
        # A vertex outside the top k only needs an upper bound tight enough to fall below
        # v_k, whose own estimate may slip by lambda_L(v_k): hence the subtraction. (The
        # reference adds it, making the target looser than its exclusion test can use.)
        for i in (k_target + 1):union_sample
            err_l[i] = 10.0
            err_u[i] = max(
                err, bet[k_target] - (bet[k_target] - bet[k_target + 1]) / 2 - bet[i]
            )
        end
        for i in 1:(k_target - 1)
            if bet[i] - bet[i + 1] < max_err
                err_l[i] = err
                err_u[i] = err
                err_l[i + 1] = err
                err_u[i + 1] = err
            end
        end
        # Borassi & Natale collapse a pair's four budgets to `err` whenever the two
        # estimates are within `max_err`, since their order cannot be resolved. The loop
        # above covers the pairs inside the top k and the one below covers the vertices
        # beneath v_{k+1}, but neither covers (v_k, v_{k+1}) --- the single pair the
        # external-exclusion test is built around. Leaving it out deadlocks both vertices
        # once their gap falls under 2*err: exclusion then cannot succeed (it needs
        # f(v_k) + g(v_{k+1}) below that gap, and neither is ever budgeted under `err`),
        # while v_{k+1} cannot reach the `err` fallback either, its lower budget having
        # been written off just above. The paper places no restriction on which pairs the
        # rule applies to, so we apply it here as well.
        if k_target + 1 <= union_sample && bet[k_target] - bet[k_target + 1] < max_err
            err_l[k_target] = err
            err_u[k_target] = err
            err_l[k_target + 1] = err
            err_u[k_target + 1] = err
        end
        for i in (k_target + 2):union_sample
            if bet[k_target + 1] - bet[i] < max_err
                err_l[k_target + 1] = err
                err_u[k_target + 1] = err
                err_l[i] = err
                err_u[i] = err
            end
        end
    end
    return nothing
end

"""
    compute_delta_guess!(delta_l_guess, delta_u_guess, top_k_nodes, global_approx, n_pairs,
                          n, k_target, absolute, err, delta, start_factor)

Port of the C++ reference's `compute_delta_guess` (Probabilistic.cpp:261-309): the
adaptive calibration step run once between the burn-in (Phase 1) and the main sampling
round (Phase 2). Uses Phase 1's observed betweenness estimates for the `union_sample`
currently-highest-ranked vertices (`top_k_nodes`, already sorted descending by
`global_approx`) to bisection-search a per-vertex confidence budget that is tighter than
the uniform `delta/(4n)` a naive allocation would give every vertex, while still
respecting the overall `delta` guarantee across all `n` vertices (via a union bound over
the untracked tail). Fills `delta_l_guess`/`delta_u_guess` (length `n`) in place.
"""
function compute_delta_guess!(
    delta_l_guess::Vector{Float64},
    delta_u_guess::Vector{Float64},
    top_k_nodes::AbstractVector{Int},
    global_approx::AbstractVector{<:Real},
    n_pairs::Int,
    n::Int,
    k_target::Int,
    absolute::Bool,
    err::Float64,
    delta::Float64,
    start_factor::Int,
)
    union_sample = length(top_k_nodes)
    balancing_factor = 0.001

    bet = Vector{Float64}(undef, union_sample)
    err_l = Vector{Float64}(undef, union_sample)
    err_u = Vector{Float64}(undef, union_sample)

    for i in 1:union_sample
        bet[i] = global_approx[top_k_nodes[i]] / n_pairs
    end
    compute_bet_err!(bet, err_l, err_u, n_pairs, k_target, absolute, err, start_factor)

    a = 0.0
    b = 1.0 / err^2 * log(n * 4.0 * (1.0 - balancing_factor) / delta)

    while b - a > err / 10
        c = (a + b) / 2
        s = 0.0
        for i in 1:union_sample
            s += exp(-c * err_l[i]^2 / bet[i])
            s += exp(-c * err_u[i]^2 / bet[i])
        end
        s += (n - union_sample) * exp(-c * err_l[union_sample]^2 / bet[union_sample])
        s += (n - union_sample) * exp(-c * err_u[union_sample]^2 / bet[union_sample])
        if s >= delta / 2 * (1.0 - balancing_factor)
            a = c
        else
            b = c
        end
    end

    delta_l_min =
        exp(-b * err_l[union_sample]^2 / bet[union_sample]) +
        delta * balancing_factor / 4.0 / n
    delta_u_min =
        exp(-b * err_u[union_sample]^2 / bet[union_sample]) +
        delta * balancing_factor / 4.0 / n

    fill!(delta_l_guess, delta_l_min)
    fill!(delta_u_guess, delta_u_min)

    for i in 1:union_sample
        v = top_k_nodes[i]
        delta_l_guess[v] =
            exp(-b * err_l[i]^2 / bet[i]) + delta * balancing_factor / 4.0 / n
        delta_u_guess[v] =
            exp(-b * err_u[i]^2 / bet[i]) + delta * balancing_factor / 4.0 / n
    end
    return nothing
end

"""
    check_finished(approx_counts, top_k_nodes, n_pairs, k, err, delta_l_guess, delta_u_guess, omega, absolute)

Evaluates whether the KADABRA algorithm has met the stopping criteria based on the current samples.
Supports both absolute error mode (all vertices have error < err) and relative mode (the gap between 
the top-k rankings is strictly larger than their overlapping error bounds).
"""
function check_finished(
    approx_counts::Vector{Int},
    top_k_nodes::AbstractVector{Int},
    n_pairs::Int,
    k::Int,
    err::Float64,
    delta_l_guess::Vector{Float64},
    delta_u_guess::Vector{Float64},
    omega::Float64,
    absolute::Bool,
    bet::Vector{Float64},
    err_l::Vector{Float64},
    err_u::Vector{Float64},
)
    n_tracked = length(top_k_nodes)

    for i in 1:n_tracked
        v = top_k_nodes[i]
        # clamp fängt asynchrone Auslesefehler ab und schützt vor DomainErrors
        bet[i] = clamp(approx_counts[v] / n_pairs, 0.0, 1.0)
    end

    for i in 1:n_tracked
        v = top_k_nodes[i]
        err_l[i] = compute_f(bet[i], n_pairs, delta_l_guess[v], omega)
        err_u[i] = compute_g(bet[i], n_pairs, delta_u_guess[v], omega)
    end

    all_finished = true

    if absolute
        for i in 1:n_tracked
            finished = (err_l[i] < err) && (err_u[i] < err)
            all_finished = all_finished && finished
        end
    else
        for i in 1:n_tracked
            if i == 1
                # `n_tracked` is `union_sample`, and `union_sample >= min(nv(g), 20)`
                # because `union_target >= k + 20`. `kadabra_centrality` rejects
                # `nv(g) < 2`, so `n_tracked >= 2` and `bet[2]` always exists.
                finished = (bet[1] - err_l[1]) > (bet[2] + err_u[2])
            elseif i < k
                finished =
                    ((bet[i - 1] - err_l[i - 1]) > (bet[i] + err_u[i])) &&
                    ((bet[i] - err_l[i]) > (bet[i + 1] + err_u[i + 1]))
            elseif i == k
                if k < n_tracked
                    finished =
                        ((bet[k - 1] - err_l[k - 1]) > (bet[k] + err_u[k])) &&
                        ((bet[k] - err_l[k]) > (bet[k + 1] + err_u[k + 1]))
                else
                    finished = (bet[k - 1] - err_l[k - 1]) > (bet[k] + err_u[k])
                end
            else
                # External exclusion, Algorithm 2 line 11: v_k's *lower* deviation f(v_k)
                # is what certifies v_i as ranking below it. (The reference substitutes
                # g(v_k) here.)
                finished = (bet[k] - err_l[k]) > (bet[i] + err_u[i])
            end

            finished = finished || ((err_l[i] < err) && (err_u[i] < err))
            all_finished = all_finished && finished
        end
    end

    return all_finished
end

# ---------------------------------------------------------------------------
# Sampling
# ---------------------------------------------------------------------------

struct KadabraWorkspace{T<:Integer}
    ball_indicator::Vector{UInt8}
    n_paths::Vector{Float64}
    dist::Vector{Int}

    preds_data::Vector{T}
    preds_count::Vector{Int}
    preds_offset::Vector{Int}

    cur_s::Vector{T}
    next_s::Vector{T}
    cur_t::Vector{T}
    next_t::Vector{T}

    sp_edges::Vector{Tuple{T,T}}
    visited_nodes::Vector{T}
end

function KadabraWorkspace(g::AbstractGraph{T}) where {T}
    n = nv(g)

    preds_offset = zeros(Int, n + 1)
    offset = 1
    for v in 1:n
        preds_offset[v] = offset
        # maximum predecessors a node can have in a shortest path BFS is bounded by its degree
        offset += max(indegree(g, v), outdegree(g, v))
    end
    preds_offset[n + 1] = offset

    preds_data = zeros(T, max(1, offset - 1))
    preds_count = zeros(Int, n)

    cur_s = zeros(T, n)
    next_s = zeros(T, n)
    cur_t = zeros(T, n)
    next_t = zeros(T, n)

    sp_edges = fill((zero(T), zero(T)), max(1, ne(g)))
    visited_nodes = zeros(T, n + 2)

    return KadabraWorkspace{T}(
        zeros(UInt8, n),
        zeros(Float64, n),
        fill(typemax(Int), n),
        preds_data,
        preds_count,
        preds_offset,
        cur_s,
        next_s,
        cur_t,
        next_t,
        sp_edges,
        visited_nodes,
    )
end

"""
    sample_shortest_path!(counts::Vector{Int}, ws::KadabraWorkspace{T}, g, s, t[; endpoints=false])

Sample a single shortest path uniformly at random using pre-allocated workspace memory,
and directly increment `counts` for every vertex on the path. No heap allocations occur.
"""
function sample_shortest_path!(
    counts::Vector{Int},
    ws::KadabraWorkspace{T},
    g::AbstractGraph{T},
    rng::AbstractRNG,
    s::T,
    t::T;
    endpoints::Bool=false,
) where {T}
    s == t && return nothing
    return _sample_shortest_path!(
        g, rng, s, t, counts, ws, outneighbors, inneighbors, endpoints
    )
end

"""
    _bb_bfs_sample!(counts, ws, g, s, t, neighborfn_s, neighborfn_t, endpoints)

Internal helper function that performs a Balanced Bidirectional BFS from source `s` and target `t`.
The search expands the frontier with the smallest sum of out-degrees to minimize edge traversals.
When the frontiers intersect, it selects a single bridge edge uniformly at random (weighted by 
the number of shortest paths crossing it) and backtracks to construct the sampled path.
The nodes on the resulting path are incremented directly in the `counts` array without allocating memory.
"""
@inline function _sample_shortest_path!(
    g::AbstractGraph{T},
    rng::AbstractRNG,
    s::T,
    t::T,
    counts::Vector{Int},
    ws::KadabraWorkspace{T},
    neighborfn_s::F1,
    neighborfn_t::F2,
    endpoints::Bool,
) where {T<:Integer,F1,F2}
    ball_indicator = ws.ball_indicator
    n_paths = ws.n_paths
    dist = ws.dist
    preds_data = ws.preds_data
    preds_count = ws.preds_count
    preds_offset = ws.preds_offset
    cur_s = ws.cur_s
    next_s = ws.next_s
    cur_t = ws.cur_t
    next_t = ws.next_t
    sp_edges = ws.sp_edges
    visited_nodes = ws.visited_nodes

    ball_indicator[s] = 0x01
    n_paths[s] = 1.0
    dist[s] = 0
    cur_s_len = 1
    cur_s[1] = s
    visited_len = 1
    visited_nodes[1] = s
    sum_degs_s = length(neighborfn_s(g, s))

    ball_indicator[t] = 0x02
    n_paths[t] = 1.0
    dist[t] = 0
    cur_t_len = 1
    cur_t[1] = t
    visited_len += 1
    visited_nodes[visited_len] = t
    sum_degs_t = length(neighborfn_t(g, t))

    sp_edges_len = 0
    have_to_stop = false

    while !have_to_stop && (cur_s_len > 0 && cur_t_len > 0)
        if sum_degs_s <= sum_degs_t
            sum_degs_s = 0
            next_s_len = 0
            for i in 1:cur_s_len
                x = cur_s[i]
                for y in neighborfn_s(g, x)
                    @inbounds begin
                        if ball_indicator[y] == 0x00
                            ball_indicator[y] = 0x01
                            n_paths[y] = n_paths[x]
                            dist[y] = dist[x] + 1

                            count = preds_count[y]
                            idx = preds_offset[y] + count
                            preds_data[idx] = x
                            preds_count[y] = count + 1

                            next_s_len += 1
                            next_s[next_s_len] = y

                            visited_len += 1
                            visited_nodes[visited_len] = y
                            sum_degs_s += length(neighborfn_s(g, y))

                        elseif ball_indicator[y] == 0x02
                            have_to_stop = true
                            sp_edges_len += 1
                            sp_edges[sp_edges_len] = (x, y)

                        elseif dist[y] == dist[x] + 1 && ball_indicator[y] == 0x01
                            n_paths[y] += n_paths[x]
                            count = preds_count[y]
                            idx = preds_offset[y] + count
                            preds_data[idx] = x
                            preds_count[y] = count + 1
                        end
                    end
                end
            end
            cur_s_len = next_s_len
            cur_s, next_s = next_s, cur_s

        else
            sum_degs_t = 0
            next_t_len = 0
            for i in 1:cur_t_len
                x = cur_t[i]
                for y in neighborfn_t(g, x)
                    @inbounds begin
                        if ball_indicator[y] == 0x00
                            ball_indicator[y] = 0x02
                            n_paths[y] = n_paths[x]
                            dist[y] = dist[x] + 1

                            count = preds_count[y]
                            idx = preds_offset[y] + count
                            preds_data[idx] = x
                            preds_count[y] = count + 1

                            next_t_len += 1
                            next_t[next_t_len] = y

                            visited_len += 1
                            visited_nodes[visited_len] = y
                            sum_degs_t += length(neighborfn_t(g, y))

                        elseif ball_indicator[y] == 0x01
                            have_to_stop = true
                            sp_edges_len += 1
                            sp_edges[sp_edges_len] = (y, x)

                        elseif dist[y] == dist[x] + 1 && ball_indicator[y] == 0x02
                            n_paths[y] += n_paths[x]
                            count = preds_count[y]
                            idx = preds_offset[y] + count
                            preds_data[idx] = x
                            preds_count[y] = count + 1
                        end
                    end
                end
            end
            cur_t_len = next_t_len
            cur_t, next_t = next_t, cur_t
        end
    end

    if sp_edges_len > 0
        tot_weight = 0.0
        for i in 1:sp_edges_len
            (u_bridge, v_bridge) = sp_edges[i]
            tot_weight += n_paths[u_bridge] * n_paths[v_bridge]
        end

        rand_val = rand(rng) * tot_weight
        cur_weight = 0.0
        selected_edge = sp_edges[sp_edges_len] # FALLBACK ensures an edge is always selected

        for i in 1:sp_edges_len
            (u_bridge, v_bridge) = sp_edges[i]
            cur_weight += n_paths[u_bridge] * n_paths[v_bridge]
            if cur_weight >= rand_val
                selected_edge = (u_bridge, v_bridge)
                break
            end
        end

        _backtrack!(
            counts,
            selected_edge[1],
            s,
            preds_data,
            preds_count,
            preds_offset,
            n_paths,
            rng,
            endpoints,
        )
        _backtrack!(
            counts,
            selected_edge[2],
            t,
            preds_data,
            preds_count,
            preds_offset,
            n_paths,
            rng,
            endpoints,
        )
    end

    for i in 1:visited_len
        v = visited_nodes[i]
        ball_indicator[v] = 0x00
        n_paths[v] = 0.0
        dist[v] = typemax(Int)
        preds_count[v] = 0
    end

    return nothing
end

"""
    _backtrack!(counts, curr, target, preds, n_paths, endpoints)

Internal helper that reconstructs a single shortest path by backtracking from the `curr` node 
towards the `target` node using the predecessor map `preds` generated during the BFS.
If multiple optimal predecessors exist, one is selected randomly weighted by the number of 
shortest paths `n_paths` arriving through that predecessor.
The thread-local `counts` buffer is incremented in-place for every node visited.
"""
@inline function _backtrack!(
    counts::Vector{Int},
    curr::T,
    target::T,
    preds_data::Vector{T},
    preds_count::Vector{Int},
    preds_offset::Vector{Int},
    n_paths::Vector{Float64},
    rng::AbstractRNG,
    endpoints::Bool,
) where {T}
    max_steps = length(counts) # nv(g)
    iter_count = 0
    while curr != target
        iter_count += 1
        # A shortest path visits each vertex at most once, so the walk terminates within
        # `nv(g)` steps unless the predecessor structure contains a cycle.
        iter_count <= max_steps || error("_backtrack!: predecessor map contains a cycle")
        GC.safepoint()
        counts[curr] += 1

        count = preds_count[curr]
        offset = preds_offset[curr]

        # Every vertex the BFS reached other than its own root has a predecessor, and the
        # walk stops at `target`, so `curr` is never a root here.
        count > 0 || error("_backtrack!: vertex $curr has no BFS predecessor")
        if count == 1
            curr = preds_data[offset]
        else
            tot = 0.0
            for i in 1:count
                p = preds_data[offset + i - 1]
                tot += n_paths[p]
            end

            r = rand(rng) * tot
            c = 0.0

            curr = preds_data[offset + count - 1] # FALLBACK: default to the last predecessor

            for i in 1:count
                p = preds_data[offset + i - 1]
                c += n_paths[p]
                if c >= r
                    curr = p
                    break
                end
            end
        end
    end
    if endpoints
        counts[target] += 1
    end
end
