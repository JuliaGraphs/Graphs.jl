###########################################################
#
#   Adjacency matrix
#
###########################################################

function adjacency_matrix(is_directed::Bool, n::Int, edges)    
    ui::Int = 0
    vi::Int = 0
    
    a = falses(n, n)
    
    if is_directed    
        for e in edges
            ui = vertex_index(source(e))
            vi = vertex_index(target(e)) 
            a[ui, vi] = true
        end
    else
        for e in edges
            ui = vertex_index(source(e))
            vi = vertex_index(target(e)) 
            a[ui, vi] = true
            a[vi, ui] = true
        end        
    end
    return a
end

function adjacency_matrix_sparse(is_directed::Bool, n::Int, edges)
    ne = length(edges)

    if !is_directed
        ne *= 2
    end

    idx = 1
    ui = Array(Int, ne)
    vi = Array(Int, ne)
    if is_directed
        for e in edges
            ui[idx] = vertex_index(source(e))
            vi[idx] = vertex_index(target(e))
            idx += 1
        end
    else
        for e in edges
            src = source(e)
            tgt = target(e)
            ui[idx] = vertex_index(src)
            vi[idx] = vertex_index(tgt)
            idx += 1
            ui[idx] = vertex_index(tgt)
            vi[idx] = vertex_index(src)
            idx += 1
        end
    end
    sparse(ui, vi, ones(ne), n, n)
end

function adjacency_matrix_by_adjlist(g::AbstractGraph)
    n::Int = num_vertices(g)
    a = falses(n, n)    
    for u in vertices(g)
        ui = vertex_index(u, g)
        for v in out_neighbors(u, g)
            vi = vertex_index(v, g)
            a[ui, vi] = true
        end
    end
    return a     
end

function adjacency_matrix_by_adjlist_sparse(g::AbstractGraph)
    n = num_vertices(g)
    ne = num_edges(g)
    if !is_directed(g)
        ne *= 2
    end

    ui = Array(Int, ne)
    vi = Array(Int, ne)
    idx = 1
    for u in vertices(g)
        uu = vertex_index(u, g)
        for v in out_neighbors(u, g)
            vv = vertex_index(v, g)
            ui[idx] = uu
            vi[idx] = vv
            idx += 1
        end
    end
    sparse(ui, vi, ones(ne), n, n)
end

function adjacency_matrix_by_inclist(g::AbstractGraph)
    n::Int = num_vertices(g)
    a = falses(n, n)
    for u in vertices(g)
        ui = vertex_index(u, g)
        for e in out_edges(u, g)
            vi = vertex_index(target(e, g), g)
            a[ui, vi] = true
        end
    end    
    return a     
end

function adjacency_matrix_by_inclist_sparse(g::AbstractGraph)
    n = num_vertices(g)
    ne = num_edges(g)
    if !is_directed(g)
        ne *= 2
    end

    ui = Array(Int, ne)
    vi = Array(Int, ne)
    idx = 1
    for u in vertices(g)
        uu = vertex_index(u, g)
        for e in out_edges(u,g)
            vv = vertex_index(target(e, g), g)
            ui[idx] = uu
            vi[idx] = vv
            idx += 1
        end
    end
    sparse(ui, vi, ones(ne), n, n)
end

function adjacency_matrix(g::AbstractGraph)
    # convert a graph to an adjacency matrix
    
    @graph_requires g vertex_list vertex_map 
    
    n = num_vertices(g)
    ui::Int = 0
    vi::Int = 0
    
    if implements_edge_list(g)
        adjacency_matrix(is_directed(g), num_vertices(g), edges(g))
        
    elseif implements_adjacency_list(g)
        adjacency_matrix_by_adjlist(g)
        
    elseif implements_incidence_list(g)
        adjacency_matrix_by_inclist(g)

    else
        throw(ArgumentError("g must implement edge_list, adjacency_list, or incidence_list"))
    end
end

function adjacency_matrix_sparse(g::AbstractGraph)

    @graph_requires g vertex_list vertex_map

    n = num_vertices(g)
    ne = num_edges(g)

    if implements_edge_list(g)
        adjacency_matrix_sparse(is_directed(g), num_vertices(g), edges(g))
    elseif implements_adjacency_list(g)
        adjacency_matrix_by_adjlist_sparse(g)
    elseif implements_incidence_list(g)
        adjacency_matrix_by_inclist_sparse(g)
    else
        throw(ArgumentError("g must implement edge_list, adjacency_list, or incididence list"))
    end
end
    

###########################################################
#
#   Weight matrix
#
###########################################################
    
    
function weight_matrix{W}(is_directed::Bool, n::Int, edges, eweights::AbstractVector{W})
    wmap = zeros(W, (n, n))
    if is_directed
        for e in edges
            w = eweights[edge_index(e)]
            ui = vertex_index(source(e))
            vi = vertex_index(target(e))
            wmap[ui, vi] += w
        end
    else
        for e in edges
            w = eweights[edge_index(e)]
            ui = vertex_index(source(e))
            vi = vertex_index(target(e))
            wmap[ui, vi] += w
            wmap[vi, ui] += w
        end
    end
    wmap   
end    

function weight_matrix_sparse{W}(is_directed::Bool, n::Int, edges, eweights::AbstractVector{W})
    ne = length(edges)
    if !is_directed
        ne *= 2
    end

    idx = 1
    ui = Array(Int, ne)
    vi = Array(Int, ne)
    w = Array(W, ne)
    if is_directed
        for e in edges
            ui[idx] = vertex_index(source(e))
            vi[idx] = vertex_index(target(e))
            w[idx] = eweights[edge_index(e)]
            idx += 1
        end
    else
        for e in edges
            src = source(e)
            tgt = target(e)
            ww = eweights[edge_index(e)]
            ui[idx] = vertex_index(src)
            vi[idx] = vertex_index(tgt)
            w[idx] = ww
            idx += 1
            ui[idx] = vertex_index(tgt)
            vi[idx] = vertex_index(src)
            w[idx] = ww
            idx += 1
        end
    end
    sparse(ui, vi, w, n, n)
end

function weight_matrix{W}(g::AbstractGraph, eweights::AbstractVector{W})
    
    @graph_requires g vertex_list vertex_map edge_map
    
    n::Int = num_vertices(g)
    ui::Int = 0
    vi::Int = 0
        
    if implements_edge_list(g)
        weight_matrix(is_directed(g), n, edges(g), eweights)
    
    elseif implements_incidence_list(g)
        wmap = zeros(W, (n, n))
        for u in vertices(g)
            ui = vertex_index(u, g)
            for e in out_edges(u, g)
                w = eweights[edge_index(e, g)]
                vi = vertex_index(target(e, g), g)
                wmap[ui, vi] += w
            end
        end
        wmap       
    else
        throw(ArgumentError("g must implement either edge_list or incidence_list."))
    end        
end

function weight_matrix_sparse{W}(g::AbstractGraph, eweights::AbstractVector{W})

    @graph_requires g vertex_list vertex_map edge_map

    n = num_vertices(g)
    ne = num_edges(g)
    if !is_directed(g)
        ne *= 2
    end
    ui = Array(Int, ne)
    vi = Array(Int, ne)
    w = Array(W, ne)

    if implements_edge_list(g)
        weight_matrix_sparse(is_directed(g), n, edges(g), eweights)
    elseif implements_incidence_list(g)
        idx = 1
        for u in vertices(g)
            uu = vertex_index(u, g)
            for e in out_edges(u, g)
                ww = eweights[edge_index(e, g)]
                vv = vertex_index(target(e, g), g)
                ui[idx] = uu
                vi[idx] = vv
                w[idx] = ww
                idx += 1
            end
        end
        sparse(ui, vi, w, n, n)
    else
        throw(ArgumentError("g must implement either edge_list or incidence_list."))
    end

end


###########################################################
#
#   Laplacian matrix
#
###########################################################

function laplacian_matrix(n::Int, edges)    
    L = zeros(n, n)
    ui::Int = 0
    vi::Int = 0
    
    for e in edges
        ui = vertex_index(source(e))
        vi = vertex_index(target(e))
        
        L[ui,ui] += 1.
        L[vi,vi] += 1.        
        L[ui,vi] -= 1.
        L[vi,ui] -= 1.        
    end
    return L
end

function laplacian_matrix_sparse(n::Int, edges)

    ne = 4*length(edges)  # For every edge we have 4 entries
    ui = Array(Int, ne)
    vi = Array(Int, ne)
    w = Array(Int, ne)

    idx = 1
    for e in edges
        uu = vertex_index(source(e))
        vv = vertex_index(target(e))
        ui[idx] = uu
        vi[idx] = uu
        w[idx] = 1.
        idx += 1
        ui[idx] = vv
        vi[idx] = vv
        w[idx] = 1.
        idx += 1
        ui[idx] = uu
        vi[idx] = vv
        w[idx] = -1.
        idx += 1
        ui[idx] = vv
        vi[idx] = uu
        w[idx] = -1.
        idx += 1
    end
    sparse(ui, vi, w, n, n)
end

function laplacian_matrix_by_adjlist(g)
    n::Int = num_vertices(g)
    ui::Int = 0
    vi::Int = 0
    
    L = zeros(n, n)
    for u in vertices(g)
        ui = vertex_index(u, g)
        for v in out_neighbors(u, g)
            vi = vertex_index(v, g)
            
            L[ui, ui] += 1.
            L[ui, vi] -= 1.
        end
    end
    return L
end

function laplacian_matrix_by_adjlist_sparse(g)
    # Note: num_edges(g) only counts edges once, but they show up twice in the
    # loops below, and for each edge we will generate two entries =>
    # 4*num_edges.
    n = num_vertices(g)
    ne = 4*num_edges(g)

    ui = Array(Int, ne)
    vi = Array(Int, ne)
    w = Array(Float64, ne)

    idx = 1
    for u in vertices(g)
        uu = vertex_index(u, g)
        for v in out_neighbors(u, g)
            vv = vertex_index(v, g)

            ui[idx] = uu
            vi[idx] = uu
            w[idx] = 1.
            idx += 1

            ui[idx] = uu
            vi[idx] = vv
            w[idx] = -1.
            idx += 1
        end
    end
    sparse(ui, vi, w, n, n)
end

function laplacian_matrix_by_inclist(g)
    n::Int = num_vertices(g)
    ui::Int = 0
    vi::Int = 0
    
    L = zeros(n, n)
    for u in vertices(g)
        ui = vertex_index(u)
        for e in out_edges(u, g)
            vi = vertex_index(target(e, g))
            
            L[ui, ui] += 1.
            L[ui, vi] -= 1.
        end
    end
    return L
end

function laplacian_matrix_by_inclist_sparse(g)

    n = num_vertices(g)
    ne = 4*num_edges(g)

    ui = Array(Int, ne)
    vi = Array(Int, ne)
    w = Array(Float64, ne)
    idx = 1
    for u in vertices(g)
        uu = vertex_index(u)
        for e in out_edges(u, g)
            vv = vertex_index(target(e, g))
            ui[idx] = uu
            vi[idx] = uu
            w[idx] = 1
            idx += 1
            ui[idx] = uu
            vi[idx] = vv
            w[idx] = -1
            idx += 1
        end
    end
    sparse(ui, vi, w, n, n)
end

function laplacian_matrix(g::AbstractGraph)

    @graph_requires g vertex_list vertex_map 
    
    if is_directed(g)
        throw(Argument("g must be an undirected graph."))
    end   
    
    if implements_edge_list(g)
        laplacian_matrix(n, edges(g))
        
    elseif implements_adjacency_list(g)
        laplacian_matrix_by_adjlist(g)
            
    elseif implements_incidence_list(g)
        laplacian_matrix_by_inclist(g)

    else
        throw(ArgumentError("g must implement edge_list, adjacency_list, or incidence_list."))
    end  
end

function laplacian_matrix_sparse(g::AbstractGraph)
    
    @graph_requires g vertex_list vertex_map

    if is_directed(g)
        throw(Argument("g must be an undirected graph."))
    end

    if implements_edge_list(g)
        laplacian_matrix_sparse(n, edges(g))
    elseif implements_adjacency_list(g)
        laplacian_matrix_by_adjlist_sparse(g)
    elseif implements_incidence_list(g)
        laplacian_matrix_by_inclist_sparse(g)
    else
        throw(ArgumentError("g must implement edge_list, adjacency_list, or incidence list."))
    end
end

function laplacian_matrix{W}(n::Int, edges, eweights::AbstractVector{W})
    L = zeros(W, (n, n))
    ui::Int = 0
    vi::Int = 0
    
    for e in edges
        w = eweights[edge_index(e)]
        ui = vertex_index(source(e))
        vi = vertex_index(target(e))
        
        L[ui, ui] += w
        L[vi, vi] += w
        L[ui, vi] -= w
        L[vi, ui] -= w
    end        
    return L
end

function laplacian_matrix_sparse{W}(n::Int, edges, eweights::AbstractVector{W})

    ne = 4*length(edges)
    
    ui = Array(Int, ne)
    vi = Array(Int, ne)
    w = Array(Int, ne)
    idx = 1
    for e in edges
        ww = eweights[edge_index(e)]
        uu = vertex_index(source(e))
        vv = vertex_index(target(e))

        ui[idx] = uu
        vi[idx] = uu
        w[idx] = ww
        idx += 1

        ui[idx] = vv
        vi[idx] = vv
        w[idx] = ww
        idx += 1

        ui[idx] = uu
        vi[idx] = vv
        w[idx] = -ww
        idx += 1

        ui[idx] = vv
        vi[idx] = uu
        w[idx] = -ww
        idx += 1
    end
    sparse(ui, vi, w, n, n)
end

function laplacian_matrix{W}(g::AbstractGraph, eweights::AbstractVector{W})

    @graph_requires g vertex_list vertex_map edge_map
    
    if is_directed(g)
        throw(ArgumentError("g must be an undirected graph."))
    end
    
    n::Int = num_vertices(g)
    ui::Int = 0
    vi::Int = 0    
    
    if implements_edge_list(g)
        L = laplacian_matrix(n, edges(g), eweights)
        
    elseif implements_incidence_list(g)
        L = zeros(n, n)
        for u in vertices(g)
            ui = vertex_index(u)
            for e in out_edges(u, g)
                w = eweights[edge_index(e, g)]
                vi = vertex_index(target(e, g))
                
                L[ui, ui] += w
                L[ui, vi] -= w
            end
        end
        L
    else
        throw(ArgumentError("g must implement edge_list or incidence_list."))
    end  
end

function laplacian_matrix_sparse{W}(g::AbstractGraph, eweights::AbstractVector{W})

    @graph_requires g vertex_list vertex_map edge_map

    if is_directed(g)
        throw(ArgumentError("g must be an undirected graph."))
    end

    n = num_vertices(g)

    if implements_edge_list(g)
        laplacian_matrix_sparse(n, edges(g), eweights)
    elseif implements_incidence_list(g)
        ne = 4*num_edges(g)
        ui = Array(Int, ne)
        vi = Array(Int, ne)
        w = Array(W, ne)
        idx = 1
        for u in vertices(g)
            uu = vertex_index(u)
            for e in out_edges(u, g)
                ww = eweights[edge_index(e, g)]
                vv = vertex_index(target(e, g))
                
                ui[idx] = uu
                vi[idx] = uu
                w[idx] = ww
                idx += 1

                ui[idx] = uu
                vi[idx] = vv
                w[idx] = -ww
                idx += 1
            end
        end
        sparse(ui, vi, w, n, n)
               
    else
        throw(ArgumentError("g must implement edge_list or incidence_list."))
    end
end

function sparse2adjacencylist{Tv,Ti<:Integer}(A::SparseMatrixCSC{Tv,Ti})
    colptr = A.colptr
    rowval = A.rowval
    n = size(A, 1)
    adjlist = Array(Array{Ti,1}, n)
    s = 0
    for j in 1:n
        adjj = Ti[]
        sizehint(adjj, colptr[j+1] - colptr[j] - 1)
        for k in colptr[j]:(colptr[j+1] - 1)
            rvk = A.rowval[k]
            if rvk != j push!(adjj, rvk) end
        end
        s += length(adjj)
        adjlist[j] = adjj
    end
    GenericAdjacencyList{Ti, Range1{Ti}, Vector{Vector{Ti}}}(!ishermitian(A),
                                                             one(Ti):convert(Ti,n),
                                                             s, adjlist)
end
