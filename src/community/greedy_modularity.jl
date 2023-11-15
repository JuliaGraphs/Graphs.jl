function greedy_modularity(g::AbstractGraph)
    n = length(vertices(g))
    c = Vector(1:n)
    cs = Vector()
    qs = fill(-1., n)
    Q, e, a = compute_modularity(g, c)
    push!(cs, c)
    qs[1] = Q
    for i=1:n-1
        Q = modularity_greedy_step!(g, Q, e, a, c)
        push!(cs, c)
        qs[i+1] = Q
    end
    imax = argmax(qs)
    return rewrite_class_ids(cs[imax])
end

function modularity_greedy_step!(g::AbstractGraph, Q::Float64, e::Matrix{<:AbstractFloat}, a::AbstractVector{<:AbstractFloat},  c::AbstractVector{<:Integer})
    m = 2 * length(edges(g))
    n = length(vertices(g))
    dq_max = -1
    tried = Set{Tuple{Int64, Int64}}()
    to_merge::Tuple{Integer, Integer} = (0,0)
    tried = Set()
    for edge in edges(g)
        u = min(src(edge), dst(edge))
        v = max(src(edge), dst(edge))
        if !((u, v) in tried)
            push!(tried, (u,v))
            dq = 2* (e[u,v] / m - a[u]*a[v] / m^2)
            if dq > dq_max
                dq_max = dq
                to_merge = (c[u], c[v])
            end
        end
    end
    c1, c2 = to_merge
    for i=1:n
        e[c1, i] += e[c2, i]
    end
    for i=1:n
        if i == c2
            continue
        end
        e[i, c1] += e[i, c2]
    end
    a[c1] = a[c1] + a[c2]
    for i=1:n
        if c[i] == c2
            c[i] = c1
        end
    end
    return Q
end


function compute_modularity(g::AbstractGraph, c::AbstractVector{<:Integer})
    Q = 0
    m = length(edges(g)) * 2
    n_groups = maximum(c)
    a = zeros(n_groups)
    e = zeros(n_groups, n_groups)
    for u in vertices(g)
        for v in neighbors(g, u)
            if c[u] == c[v]
                Q += 1
                e[c[i], c[j]] += 1
            end
            a[c[u]] += 1
        end
    end
    Q *= m
    for i=1:n_groups
        Q -= a[i]^2
    end
    Q /= m^2
    return Q, e, a
end

function rewrite_class_ids(v::AbstractVector{<:Integer})
    d = Dict()
    vn = zeros(Int64, length(v))
    for i=eachindex(v)
        if !(v[i] in keys(d))
            d[v[i]] = length(d) + 1
        end
        vn[i] = d[v[i]]
    end
    return vn
end