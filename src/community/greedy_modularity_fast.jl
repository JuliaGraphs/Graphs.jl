function community_detection_greedy_modularity_fast(g::AbstractGraph; weights::AbstractMatrix=weights(g))
    if is_directed(g)
        throw(ArgumentError("The graph must not be directed"))
    end
    n = nv(g)
    c = Vector{Int}(1:n)
    dq_dict, dq_heap, dq_global_heap, a, m = compute_dq(g, c, weights)
    modularity_type = float(eltype(weights))
    empty_row_heap = PriorityQueue{Tuple{Int, Int}, Tuple{modularity_type, Tuple{Int, Int}}}(Base.Order.Reverse) # placeholder, lasts empty forever
    while length(dq_global_heap) > 1
        (u,v), (dq, _) = dequeue_pair!(dq_global_heap)
        if dq <= zero(modularity_type)
            return rewrite_class_ids(c)
        end
        dequeue!(dq_heap[u])
        if !isempty(dq_heap[u])
            enqueue!(dq_global_heap, peek(dq_heap[u]))
        end
        if peek(dq_heap[v])[1] == (v,u)
            dequeue!(dq_heap[v])
            delete!(dq_global_heap, (v,u))
            if !isempty(dq_heap[v])
                enqueue!(dq_global_heap, peek(dq_heap[v]))
            end
        else
            delete!(dq_heap[v], (v,u))
        end 

        c[c .== u] .= v

        neighbors_u = setdiff(keys(dq_dict[u]), v)
        neighbors_v = setdiff(keys(dq_dict[v]), u)
        neighbors_all = union(neighbors_u, neighbors_v)
        neighbors_common = intersect(neighbors_u, neighbors_v)
        
        for w in neighbors_all
            if w in neighbors_common
                dq_w = dq_dict[v][w] + dq_dict[u][w]
            elseif w in neighbors_v
                dq_w = dq_dict[v][w] - a[u] * a[w] / m^2
            else
                dq_w = dq_dict[u][w] - a[v] * a[w] / m^2
            end
            for (row, column) in ((v, w), (w, v))
                dq_heap_row = dq_heap[row]
                dq_dict[row][column] = dq_w
                if !isempty(dq_heap_row)
                    oldmax = peek(dq_heap_row)
                else
                    oldmax = nothing
                end
                dq_heap_row[(row,column)] = (dq_w, (-row, -column)) # update or insert
                if isnothing(oldmax)
                    dq_global_heap[(row, column)] = (dq_w, (-row, -column))
                else
                    newmax = peek(dq_heap_row)
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
                    if peek(dq_heap_row)[1] == (row, column)
                        dequeue!(dq_heap_row)
                        delete!(dq_global_heap, (row, column))
                        if !isempty(dq_heap_row)
                            enqueue!(dq_global_heap, peek(dq_heap_row))
                        end
                    else
                        delete!(dq_heap_row, (row, column))
                    end
                end
            end
        end
        delete!(dq_dict, u)
        dq_heap[u] = empty_row_heap
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
    dq_dict = Dict(v => DefaultDict{Int, modularity_type}(Q_zero) for v in vertices(g))

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

    dq_heap = Dict(u=>PriorityQueue{Tuple{Int, Int}, Tuple{modularity_type, Tuple{Int, Int}}}(Base.Order.Reverse, (u,v)=> (dq, (-u,-v)) for (v, dq) in dq_dict[u]) for u in vertices(g))
    v_connected = filter(v -> !isempty(dq_heap[v]), vertices(g))
    global_heap = PriorityQueue{Tuple{Int, Int}, Tuple{modularity_type, Tuple{Int, Int}}}(Base.Order.Reverse, peek(dq_heap[v]) for v in v_connected)
    return dq_dict, dq_heap, global_heap, a, m
end