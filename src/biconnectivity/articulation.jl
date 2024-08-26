"""
    articulation(g)

Compute the [articulation points](https://en.wikipedia.org/wiki/Biconnected_component) (also
known as cut or seperating vertices) of an undirected graph `g` and return an array
containing all the vertices of `g` that are articulation points.

# Examples
```jldoctest
julia> using Graphs

julia> articulation(star_graph(5))
1-element Vector{Int64}:
 1

julia> articulation(path_graph(5))
3-element Vector{Int64}:
 2
 3
 4
```
"""
function articulation end
@traitfn function articulation(g::AG::(!IsDirected)) where {T,AG<:AbstractGraph{T}}
    s = Vector{Tuple{T,T,T}}()
    low = zeros(T, nv(g))
    pre = zeros(T, nv(g))

    is_articulation_pt = falses(nv(g))
    @inbounds for u in vertices(g)
        articulation_dfs!(is_articulation_pt, g, u, s, low, pre)
    end

    articulation_points = T[v for (v, b) in enumerate(is_articulation_pt) if b]

    return articulation_points
end

"""
    is_articulation(g, v)

Determine whether `v` is an
[articulation point](https://en.wikipedia.org/wiki/Biconnected_component) of an undirected
graph `g`, returning `true` if so and `false` otherwise.

See also [`articulation`].

# Examples
```jldoctest
julia> using Graphs

julia> g = path_graph(5)
{5, 4} undirected simple Int64 graph

julia> articulation(g)
3-element Vector{Int64}:
 2
 3
 4

julia> is_articulation(g, 2)
true

julia> is_articulation(g, 1)
false
```
"""
function is_articulation end
@traitfn function is_articulation(g::AG::(!IsDirected), v::T) where {T,AG<:AbstractGraph{T}}
    s = Vector{Tuple{T,T,T}}()
    low = zeros(T, nv(g))
    pre = zeros(T, nv(g))

    return articulation_dfs!(nothing, g, v, s, low, pre)
end

@traitfn function articulation_dfs!(
    is_articulation_pt::Union{Nothing,BitVector},
    g::AG::(!IsDirected),
    u::T,
    s::Vector{Tuple{T,T,T}},
    low::Vector{T},
    pre::Vector{T},
) where {T,AG<:AbstractGraph{T}}
    if !isnothing(is_articulation_pt)
        if pre[u] != 0
            return is_articulation_pt
        end
    end

    v = u
    children = 0
    wi::T = zero(T)
    w::T = zero(T)
    cnt::T = one(T)
    first_time = true

    # TODO the algorithm currently relies on the assumption that
    # outneighbors(g, v) is indexable. This assumption might not be true
    # in general, so in case that outneighbors does not produce a vector
    # we collect these vertices. This might lead to a large number of
    # allocations, so we should find a way to handle that case differently,
    # or require inneighbors, outneighbors and neighbors to always
    # return indexable collections.

    while !isempty(s) || first_time
        first_time = false
        if wi < 1
            pre[v] = cnt
            cnt += 1
            low[v] = pre[v]
            v_neighbors = collect_if_not_vector(outneighbors(g, v))
            wi = 1
        else
            wi, u, v = pop!(s)
            v_neighbors = collect_if_not_vector(outneighbors(g, v))
            w = v_neighbors[wi]
            low[v] = min(low[v], low[w])
            if low[w] >= pre[v] && u != v
                if isnothing(is_articulation_pt)
                    if v == u
                        return true
                    end
                else
                    is_articulation_pt[v] = true
                end
            end
            wi += 1
        end
        while wi <= length(v_neighbors)
            w = v_neighbors[wi]
            if pre[w] == 0
                if u == v
                    children += 1
                end
                push!(s, (wi, u, v))
                wi = 0
                u = v
                v = w
                break
            elseif w != u
                low[v] = min(low[v], pre[w])
            end
            wi += 1
        end
        wi < 1 && continue
    end

    if children > 1
        if isnothing(is_articulation_pt)
            return u == v
        else
            is_articulation_pt[u] = true
        end
    end

    return isnothing(is_articulation_pt) ? false : is_articulation_pt
end
