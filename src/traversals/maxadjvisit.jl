# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

#################################################
#
#  Minimum Cut
#
#################################################

"""
    mincut(g, distmx=weights(g))

Return a tuple `(parity, bestcut)`, where `parity` is a vector of integer
values that determines the partition in `g` (1 or 2) and `bestcut` is the
weight of the cut that makes this partition. An optional `distmx` matrix
of non-negative weights may be specified; if omitted, edge distances are
assumed to be 1.
"""
@traitfn function mincut(g::::(!IsDirected), distmx::AbstractMatrix{T}=weights(g)) where {T <: Real}

    nvg = nv(g)
    U = eltype(g)

    # make sure we have at least two vertices, otherwise, there's nothing to cut,
    # in which case we'll return immediately.
    (nvg > one(U)) || return (Vector{Int8}([1]), zero(T))

    is_merged = falses(nvg)
    merged_vertices = IntDisjointSets(U(nvg))
    graph_size = nvg
    # We need to mutate the weight matrix,
    # and we need it clean (0 for non edges)
    w = zeros(T, nvg, nvg)
    size(distmx) != (nvg, nvg) && throw(ArgumentError("Adjacency / distance matrix size should match the number of vertices"))
    @inbounds for e in edges(g)
        d = distmx[src(e), dst(e)]
        (d < 0) && throw(DomainError(w, "weigths should be non-negative"))
        w[src(e), dst(e)] = d
        (d != distmx[dst(e), src(e)]) && throw(ArgumentError("Adjacency / distance matrix must be symmetric"))
        w[dst(e), src(e)] = d
    end
    # we also need to mutate neighbors when merging vertices
    fadjlist = [collect(outneighbors(g, v)) for v in vertices(g)]
    parities = falses(nvg)
    bestweight = typemax(T)
    pq = PriorityQueue{U,T}(Base.Order.Reverse)
    u = last_vertex = one(U)

    is_processed = falses(nvg)
    @inbounds while graph_size > 1
        cutweight = zero(T)
        is_processed .= false
        is_processed[u] = true
        # initialize pq
        for v in vertices(g)
            is_merged[v] && continue
            v == u && continue
            pq[v] = zero(T)
        end
        for v in fadjlist[u]
            (is_merged[v] || v == u ) && continue
            pq[v] = w[u, v]
            cutweight += w[u, v]
        end
        # Minimum cut phase
        local adj_cost
        while true
            last_vertex = u
            u, adj_cost = first(pq)
            dequeue!(pq)
            isempty(pq) && break
            for v in fadjlist[u]
                (is_merged[v] || u == v) && continue
                # if the target of e is already marked then decrease cutweight
                # otherwise, increase it
                ew = w[u, v]
                if is_processed[v]
                    cutweight -= ew
                else
                    cutweight += ew
                    pq[v] += ew
                end
            end
            is_processed[u] = true
            # adj_cost is a lower bound on the cut separating the two last vertices
            # encountered, so if adj_cost >= bestweight, we can already merge these
            # vertices to save one phase.
            if adj_cost >= bestweight
                _merge_vertex!(merged_vertices, fadjlist, is_merged, w, u, last_vertex)
                graph_size -= 1
            end
        end

        cutweight = adj_cost

        # check if we improved the mincut
        if cutweight < bestweight
            bestweight = cutweight
            for v in vertices(g)
                parities[v] = (find_root!(merged_vertices, v) == u)
            end
        end

        # merge u and last_vertex
        root = _merge_vertex!(merged_vertices, fadjlist, is_merged, w, u, last_vertex)
        graph_size -= 1
        u = root # we are sure this vertex was not merged, so the next phase start from it
    end
    return (convert(Vector{Int8}, parities) .+ one(Int8), bestweight)
end

function _merge_vertex!(merged_vertices, fadjlist, is_merged, w, u, v)
    root = union!(merged_vertices, u, v)
    non_root = (root == u) ? v : u
    is_merged[non_root] = true
    # update weights
    for v2 in fadjlist[non_root]
        w[root, v2] += w[non_root, v2]
        w[v2, root] = w[root, v2]
    end
    # update neighbors
    fadjlist[root] = union(fadjlist[root], fadjlist[non_root])
    for v in fadjlist[non_root]
        if root ∉ fadjlist[v]
            push!(fadjlist[v], root)
        end
    end
    return root
end

"""
    maximum_adjacency_visit(g[, distmx][, log][, io][, s])
    maximum_adjacency_visit(g[, s])

Return the vertices in `g` traversed by maximum adjacency search, optionally
starting from vertex `s` (default `1`). An optional `distmx` matrix may be
specified; if omitted, edge distances are assumed to be 1. If `log` (default
`false`) is `true`, visitor events will be printed to `io`, which defaults to
`STDOUT`; otherwise, no event information will be displayed.
"""
function maximum_adjacency_visit(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T},
    log::Bool=false,
    io::IO=stdout,
    s::U=one(U),
) where {U,T<:Real}
    pq = PriorityQueue{U,T}(Base.Order.Reverse)
    vertices_order = Vector{U}()
    has_key = ones(Bool, nv(g))
    sizehint!(vertices_order, nv(g))
    # if the graph only has one vertex, we return the vertex by itself.
    nv(g) > one(U) || return collect(vertices(g))

    # Setting intial count to 0
    for v in vertices(g)
        pq[v] = zero(T)
    end

    # Give start vertex maximum priority
    pq[s] = one(T)

    # start traversing the graph
    while !isempty(pq)
        u = dequeue!(pq)
        has_key[u] = false
        push!(vertices_order, u)
        log && println(io, "discover vertex: $u")
        for v in outneighbors(g, u)
            log && println(io, " -- examine neighbor from $u to $v")
            if has_key[v] && (u != v)
                ed = distmx[u, v]
                pq[v] += ed
            end
        end
        log && println(io, "close vertex: $u")
    end
    return vertices_order
end

function maximum_adjacency_visit(g::AbstractGraph{U}, s::U=one(U)) where {U}
    return maximum_adjacency_visit(g, weights(g), false, stdout, s)
end
