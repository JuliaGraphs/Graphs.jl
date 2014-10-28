# Kruskal's algorithm for minimum spanning tree/forest


# select edges from a sorted list of weighted edges
function kruskal_select{V,E,W}(
    graph::AbstractGraph{V,E},
    sorted_wedges::AbstractVector{WeightedEdge{E,W}},
    K::Integer)

    @graph_requires graph vertex_map

    n = num_vertices(graph)
    re = Array(E, 0)
    rw = Array(W, 0)

    if n > 1
        dsets = IntDisjointSets(n)
        sizehint(re, n-1)
        sizehint(rw, n-1)

        ui::Int = 0
        vi::Int = 0

        for we in sorted_wedges
            e::E = we.edge
            ui = vertex_index(source(e, graph), graph)
            vi = vertex_index(target(e, graph), graph)

            if !in_same_set(dsets, ui, vi)
                union!(dsets, ui, vi)
                push!(re, e)
                push!(rw, we.weight)
            end

            if num_groups(dsets) <= K
                break
            end
        end
    end

    return (re, rw)
end

function kruskal_minimum_spantree(graph::AbstractGraph, eweights::AbstractEdgePropertyInspector; K::Integer=1)

    # collect & sort edges

    wedges = collect_weighted_edges(graph, eweights)
    sort!(wedges)

    # select the tree edges
    kruskal_select(graph, wedges, K)
end


function kruskal_minimum_spantree(graph::AbstractGraph, eweights::AbstractVector; K::Integer=1)
    visitor::AbstractEdgePropertyInspector = VectorEdgePropertyInspector(eweights)
    kruskal_minimum_spantree(graph, visitor, K=K)
end