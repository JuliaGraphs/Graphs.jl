function community_detection_greedy_modularity_fast(g::AbstractGraph; weights::AbstractMatrix=weights(g))
    if is_directed(g)
        throw(ArgumentError("The graph must not be directed"))
    end
    n = nv(g)
    c = Vector{Int}(1:n)
    dq_dict, dq_heap, dq_global_heap, a = compute_dq(g, c, weights)
    modularity_type = float(eltype(weights))
    for _ in 2:n
        try
            (u,v), dq = dequeue_pair!(dq_global_heap)
        catch err
            if isa(err, BoundsError)
                break
            end
            throw(error("unknown error at call to priority queue"))
        end
        dequeue!(dq_heap[u])
        if !isempty(dq_heap[u])
            enqueue!(dq_global_heap, first(dq_heap[u]))
        end
        if first(dq_heap[v])[1] == (v,u)
            dequeue!(dq_heap[v])
            delete!(dq_global_heap, (v,u))
            if !isempty(dq_heap[v])
                enqueue!(dq_global_heap, first(dq_heap[v]))
            end
        else
            delete!(dq_heap[v], (v,u))
        end 

        c[c .== u] .= v

        neighbors_u = keys(dq_dict[u])
        neighbors_v = keys(dq_dict[v])
        neighbors_all = union(neighbors_u, neighbors_v)
        neighbors_common = intersect(neighbors_u, neighbors_v)
        
        for w in neighbors_all
            if w in neighbors_common
                dq_w = dq_dict[v][w] + dq_dict[u][w]
            elseif w in neighbors_v
                dq_w = dq_dict[v][w] - 2 * a[u] * a[w]
            else
                dq_w = dq_dict[v][w] - 2 * a[v] * a[w]
            end
            for (row, column) in ((v, w), (w, v))
                dq_heap_row = dq_heap[row]
                dq_dict[row][column] = dq_w
                if !isempty(dq_heap_row)
                    oldmax = first(dq_heap_row)
                else
                    oldmax = nothing
                end
                dq_heap_row[(row,column)] = dq_w # update or insert
                if isnothing(oldmax)
                    dq_global_heap[(row, column)] = dq_w
                else
                    newmax = first(dq_heap_row)
                    if newmax != oldmax
                        delete!(dq_global_heap, oldmax[1]) ## is it still there?
                        enqueue!(dq_global_heap, newmax)
                    end
                end
            end
        end

        for (w, _) in dq_dict[u]
            delete!(dq_dict[w], u)
            if w != v
                for (row, column) in ((w,u), (u,w))
                    dq_heap_row = dq_heap[row]
                    if first(dq_heap_row)[1] == (row, column)
                        dequeue!(dq_heap_row)
                        delete!(dq_global_heap, (row, column))
                        if !isempty(dq_heap_row)
                            enqueue!(dq_global_heap, first(dq_heap_row))
                        end
                    else
                        delete!(dq_heap_row, (row, column))
                    end
                end
            end
        end
        delete!(dq_dict, u)
        dq_heap[u] = PriorityQueue{Tuple{Int, Int}, modularity_type}(Base.Order.Reverse) # placeholder, lasts empty forever
        a[v] += a[u]
        a[u] = 0
    end
    return rewrite_class_ids(c)
end

function compute_dq(
    g::AbstractGraph, c::AbstractVector{<:Integer}, w::AbstractArray
)
    modularity_type = float(eltype(w))
    Q_zero = zero(modularity_type)
    m = sum(w[src(e), dst(e)] for e in edges(g); init=Q_zero) * 2
    n_groups = maximum(c)
    a = zeros(modularity_type, n_groups)
    # m == 0 && return 0.0, spzeros(modularity_type, n_groups, n_groups), a
    dq_dict = DefaultDict{Int, DefaultDict}(() -> DefaultDict{Int,modularity_type}(Q_zero))

    for u in vertices(g)
        for v in neighbors(g, u)
            dq_dict[u][v] += w[u,v]
            a[c[u]] += w[u, v]
        end
    end

    for (u, dct) in dq_dict
        for (v, w) in dct
            dq_dict[u][v] = w / m - a[c[u]] * a[c[v]] / m^2
        end
    end

    dq_heap = Dict(u=>PriorityQueue{Tuple{Int, Int}, modularity_type}(Base.Order.Reverse, (u,v)=> dq for (v, dq) in dq_dict[u]) for u in vertices(g))
    v_connected = filter(v -> !isempty(dq_heap[v]), vertices(g))
    global_heap = PriorityQueue{Tuple{Int, Int}, modularity_type}(Base.Order.Reverse, first(dq_heap[v]) for v in v_connected)
    return dq_dict, dq_heap, global_heap, a
end

# g = SimpleGraph(4)
# add_edge!(g,1,2)
# add_edge!(g,3,4)
# w = weights(g)
# c = 1:4
# compute_dq(g,c,w)