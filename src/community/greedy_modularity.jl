function community_detection_greedy_modularity(g::AbstractGraph)
    if is_directed(g)
        throw(ArgumentError("The graph must not be directed"))
    end
    n = nv(g)
    c = Vector{Int}(1:n)
    cs = Vector{Vector{Int}}(undef, n)
    w = weights(g)
    T = float(eltype(w))
    qs = Vector{T}(undef, n)
    Q, e, a = compute_modularity(g, c, w)
    cs[1] = copy(c)
    qs[1] = Q
    for i in 2:n
        Q = modularity_greedy_step!(g, Q, e, a, c)
        cs[i] = copy(c)
        qs[i] = Q
    end
    imax = argmax(qs)
    return rewrite_class_ids(cs[imax])
end

function modularity_greedy_step!(
    g::AbstractGraph,
    Q::T,
    e::AbstractMatrix{T},
    a::AbstractVector{T},
    c::AbstractVector{<:Integer},
) where {T}
    m = 2 * ne(g)
    n = nv(g)
    dq_max::typeof(Q) = typemin(Q)
    tried = Set{Tuple{Integer,Integer}}()
    to_merge::Tuple{Integer,Integer} = (0, 0)
    tried = Set{Tuple{Integer,Integer}}()
    for edge in edges(g)
        u = min(src(edge), dst(edge))
        v = max(src(edge), dst(edge))
        if c[u] != c[v] && !((c[u], c[v]) in tried)
            push!(tried, (c[u], c[v]))
            dq = (e[c[u], c[v]] / m - a[c[u]] * a[c[v]] / m^2)
            if dq > dq_max
                dq_max = dq
                to_merge = (c[u], c[v])
            end
        end
    end
    c1, c2 = to_merge
    for i in 1:n
        e[c1, i] += e[c2, i]
    end
    for i in 1:n
        if i == c2
            continue
        end
        e[i, c1] += e[i, c2]
    end
    a[c1] = a[c1] + a[c2]
    for i in 1:n
        if c[i] == c2
            c[i] = c1
        end
    end
    return Q + 2 * dq_max
end

function compute_modularity(g::AbstractGraph, c::AbstractVector{<:Integer}, w::AbstractArray)
    modularity_type = float(eltype(w))
    Q = zero(modularity_type)
    m = sum([w[src(e), dst(e)] for e in edges(g)]) * 2
    n_groups = maximum(c)
    a = zeros(modularity_type, n_groups)
    e = zeros(modularity_type, n_groups, n_groups)
    for u in vertices(g)
        for v in neighbors(g, u)
            if c[u] == c[v]
                Q += w[u, v]
            end
            e[c[u], c[v]] += w[u, v]
            a[c[u]] += w[u, v]
        end
    end
    Q *= m
    for i in 1:n_groups
        Q -= a[i]^2
    end
    Q /= m^2
    return Q, e, a
end

function rewrite_class_ids(v::AbstractVector{<:Integer})
    d = Dict{Integer, Integer}()
    vn = zeros(Int64, length(v))
    for i in eachindex(v)
        if !(v[i] in keys(d))
            d[v[i]] = length(d) + 1
        end
        vn[i] = d[v[i]]
    end
    return vn
end
