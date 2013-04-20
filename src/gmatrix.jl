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


function laplacian_matrix{W}(g::AbstractGraph, eweights::AbstractVector{W})

    @graph_requires g vertex_list vertex_map edge_map
    
    if is_directed(g)
        throw(Argument("g must be an undirected graph."))
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
