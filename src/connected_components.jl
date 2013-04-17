# Algorithms to find connected components

###########################################################
#
#   Connected components of undirected graph
#
##########################################################

function connected_components{V}(graph::AbstractGraph{V})
    @graph_requires graph vertex_list vertex_map adjacency_list
    
    if is_directed(graph)
        throw(ArgumentError("graph must be undirected."))
    end
    
    cmap = zeros(Int, num_vertices(graph))
    components = Array(Vector{V}, 0)
    
    for v in vertices(graph)
        if cmap[vertex_index(v, graph)] == 0
            visitor = VertexListVisitor{V}(0)
            traverse_graph(graph, BreadthFirst(), v, visitor, colormap=cmap)
            push!(components, visitor.vertices)
        end
    end
    
    components
end

## TODO: add a function to detect strongly connected components of directed graph
