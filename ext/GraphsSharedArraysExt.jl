module GraphsSharedArraysExt

using Graphs
using SharedArrays: SharedArrays, SharedMatrix, SharedVector, sdata
using SharedArrays.Distributed: @distributed
using Random: shuffle

# betweenness
function Graphs.Parallel.distr_betweenness_centrality(
    g::AbstractGraph,
    vs=vertices(g),
    distmx::AbstractMatrix=weights(g);
    normalize=true,
    endpoints=false,
)::Vector{Float64}
    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    # Parallel reduction

    betweenness = @distributed (+) for s in vs
        temp_betweenness = zeros(n_v)
        if degree(g, s) > 0  # this might be 1?
            state = Graphs.dijkstra_shortest_paths(
                g, s, distmx; allpaths=true, trackvertices=true
            )
            if endpoints
                Graphs._accumulate_endpoints!(temp_betweenness, state, g, s)
            else
                Graphs._accumulate_basic!(temp_betweenness, state, g, s)
            end
        end
        temp_betweenness
    end

    Graphs._rescale!(betweenness, n_v, normalize, isdir, k)

    return betweenness
end

# closeness
function Graphs.Parallel.distr_closeness_centrality(
    g::AbstractGraph, distmx::AbstractMatrix=weights(g); normalize=true
)::Vector{Float64}
    n_v = Int(nv(g))
    closeness = SharedVector{Float64}(n_v)
    fill!(closeness, 0.0)

    @sync @distributed for u in vertices(g)
        if degree(g, u) == 0     # no need to do Dijkstra here
            closeness[u] = 0.0
        else
            d = Graphs.dijkstra_shortest_paths(g, u, distmx).dists
            δ = filter(x -> x != typemax(x), d)
            σ = sum(δ)
            l = length(δ) - 1
            if σ > 0
                closeness[u] = l / σ
                if normalize
                    n = l * 1.0 / (n_v - 1)
                    closeness[u] *= n
                end
            else
                closeness[u] = 0.0
            end
        end
    end
    return sdata(closeness)
end

# radiality
function Graphs.Parallel.distr_radiality_centrality(g::AbstractGraph)::Vector{Float64}
    n_v = nv(g)
    vs = vertices(g)
    n = ne(g)
    meandists = SharedVector{Float64}(Int(n_v))
    maxdists = SharedVector{Float64}(Int(n_v))

    @sync @distributed for i in 1:n_v
        d = Graphs.dijkstra_shortest_paths(g, vs[i])
        maxdists[i] = maximum(d.dists)
        meandists[i] = sum(d.dists) / (n_v - 1)
        nothing
    end
    dmtr = maximum(maxdists)
    radialities = collect(meandists)
    return ((dmtr + 1) .- radialities) ./ dmtr
end

# stress
function Graphs.Parallel.distr_stress_centrality(
    g::AbstractGraph, vs=vertices(g)
)::Vector{Int64}
    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    # Parallel reduction
    stress = @distributed (+) for s in vs
        temp_stress = zeros(Int64, n_v)
        if degree(g, s) > 0  # this might be 1?
            state = Graphs.dijkstra_shortest_paths(g, s; allpaths=true, trackvertices=true)
            Graphs._stress_accumulate_basic!(temp_stress, state, g, s)
        end
        temp_stress
    end
    return stress
end

# generate_reduce
function Graphs.Parallel.distr_generate_reduce(
    g::AbstractGraph{T}, gen_func::Function, comp::Comp, reps::Integer
) where {T<:Integer,Comp}
    # Type assert required for type stability
    min_set::Vector{T} = @distributed ((x, y) -> comp(x, y) ? x : y) for _ in 1:reps
        gen_func(g)
    end
    return min_set
end

# eccentricity
function Graphs.Parallel.distr_eccentricity(
    g::AbstractGraph, vs=vertices(g), distmx::AbstractMatrix{T}=weights(g)
) where {T<:Number}
    vlen = length(vs)
    eccs = SharedVector{T}(vlen)
    @sync @distributed for i in 1:vlen
        local d = Graphs.dijkstra_shortest_paths(g, vs[i], distmx)
        eccs[i] = maximum(d.dists)
    end
    d = sdata(eccs)
    maximum(d) == typemax(T) && @warn("Infinite path length detected")
    return d
end

# dijkstra shortest paths
function Graphs.Parallel.distr_dijkstra_shortest_paths(
    g::AbstractGraph{U}, sources=vertices(g), distmx::AbstractMatrix{T}=weights(g)
) where {T<:Number} where {U}
    n_v = nv(g)
    r_v = length(sources)

    # TODO: remove `Int` once julialang/#23029 / #23032 are resolved
    dists = SharedMatrix{T}(Int(r_v), Int(n_v))
    parents = SharedMatrix{U}(Int(r_v), Int(n_v))

    @sync @distributed for i in 1:r_v
        state = Graphs.dijkstra_shortest_paths(g, sources[i], distmx)
        dists[i, :] = state.dists
        parents[i, :] = state.parents
    end

    result = Graphs.Parallel.MultipleDijkstraState(sdata(dists), sdata(parents))
    return result
end

# random greedy color
function Graphs.Parallel.distr_random_greedy_color(
    g::AbstractGraph{T}, reps::Integer
) where {T<:Integer}
    best = @distributed (Graphs.best_color) for i in 1:reps
        seq = shuffle(vertices(g))
        Graphs.perm_greedy_color(g, seq)
    end

    return convert(Graphs.Coloring{T}, best)
end

end
