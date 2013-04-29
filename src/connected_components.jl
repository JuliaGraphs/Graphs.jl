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

###########################################################
#
#   Connected components of directed graph
#
##########################################################

function strongly_connected_components{V}(graph::AbstractGraph{V})
    @graph_requires graph vertex_list vertex_map adjacency_list

    if !is_directed(graph)
        throw(ArgumentError("graph must be directed."))
    end

    idx = v -> vertex_index(v, graph)
    index = 1
    stack = Array(V, 0)
    lowlinks = zeros(Int, num_vertices(graph))
    indices  = zeros(Int, num_vertices(graph))
    components = Array(Vector{V}, 0)

    function strongconnect(v)
        indices[idx(v)]  = index
        lowlinks[idx(v)] = index
        index += 1
        push!(stack, v)

        # consider successors of v
        for w in out_neighbors(v, graph)
            if indices[idx(w)] == 0 # w is un-visited
                strongconnect(w)
                lowlinks[idx(v)] = min(lowlinks[idx(v)], lowlinks[idx(w)])
            elseif contains(stack, w)
                lowlinks[idx(v)] = min(lowlinks[idx(v)], indices[idx(w)])
            end
        end

        # if v is a root node, pop the stack and generate an SCC
        if lowlinks[idx(v)] == indices[idx(v)]
            component = Array(typeof(v), 0)
            while !isempty(stack)
                w = pop!(stack)
                push!(component, w)
                if w == v
                    break
                end
            end
            push!(components, component)
        end 
    end

    for v in vertices(graph)
        if indices[idx(v)] == 0
            strongconnect(v)
        end
    end
    components
end
