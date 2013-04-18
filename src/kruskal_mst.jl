# Kruskal's algorithm for minimum spanning tree/forest


# select edges from a sorted list of weighted edges
function kruskal_select{V,E,W}(
    graph::AbstractGraph{V,E}, 
    sorted_wedges::AbstractVector{WeightedEdge{E,W}},
    K::Integer)
    
    @graph_requires vertex_map    
    
    n = num_vertices(graph)
    r = Array(WeightedEdge{E,W}, 0)
    
    if n > 1
        dsets = IntDisjointSets(n)
        sizehint(r, n-1)
    
        ui::Int = 0
        vi::Int = 0
                        
        for we in sorted_wedges
            e::E = we.edge            
            ui = vertex_index(source(e, graph))
            vi = vertex_index(target(e, graph))
        
            if !in_same_set(dsets, ui, vi)
                union!(dsets, ui, vi)
                push!(r, we)
            end
                
            if num_groups(dsets) <= K
                break
            end            
        end
    end
    
    return r
end

function kruskal_minimum_spantree(graph::AbstractGraph, eweights::AbstractVector; K::Integer=1)
    
    # collect & sort edges
    
    wedges = collect_weighted_edges(graph, eweights)
    sort!(wedges)
    
    # select the tree edges
    kruskal_select(graph, wedges, K)    
end
