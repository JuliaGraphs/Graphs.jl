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

function strongly_connected_components_recursive{V}(graph::AbstractGraph{V})
    """Recursively compute the strongly connected components of a directed graph.
    
    Adapted from http://bit.ly/12Xrp7C on April 29, 2013."""

    @graph_requires graph vertex_list vertex_map adjacency_list

    if !is_directed(graph)
        throw(ArgumentError("graph must be directed."))
    end

    v_idx = v -> vertex_index(v, graph)
    index = 1
    stack = Array(V, 0)
    lowlinks = zeros(Int, num_vertices(graph))
    indices  = zeros(Int, num_vertices(graph))
    components = Array(Vector{V}, 0)

    function strongconnect(v)
        indices[v_idx(v)]  = index
        lowlinks[v_idx(v)] = index
        index += 1
        push!(stack, v)

        # consider successors of v
        for w in out_neighbors(v, graph)
            if indices[v_idx(w)] == 0 # w is un-visited
                strongconnect(w)
                lowlinks[v_idx(v)] = min(lowlinks[v_idx(v)], lowlinks[v_idx(w)])
            elseif contains(stack, w)
                lowlinks[v_idx(v)] = min(lowlinks[v_idx(v)], indices[v_idx(w)])
            end
        end

        # if v is a root node, pop the stack and generate an SCC
        if lowlinks[v_idx(v)] == indices[v_idx(v)]
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
        if indices[v_idx(v)] == 0
            strongconnect(v)
        end
    end
    components
end

type TarjanVisitor{V} <: AbstractGraphVisitor
    v_idx      ::Function
    stack      ::Array{V}
    lowlinks   ::Array{Int}
    index      ::Array{Int}
    components ::Array{Vector{V}}

    function TarjanVisitor(graph::AbstractGraph) 
        v_idx  = v -> vertex_index(v, graph)
        stack  = Array(V, 0)
        index  = zeros(Int, num_vertices(graph))
        lowlinks   = Array(Int, 0)
        components = Array(Vector{V}, 0)

        new(v_idx, stack, lowlinks, index, components)
    end
end
function discover_vertex!(vis::TarjanVisitor, v) 
    vis.index[vis.v_idx(v)] = length(vis.stack) + 1
    push!(vis.lowlinks, length(vis.stack) + 1)
    push!(vis.stack, v)
    true
end
function examine_neighbor!(vis::TarjanVisitor, v, w, w_color::Int)
    if w_color == 1 # 1 means added seen, but not explored
        while vis.index[vis.v_idx(w)] < vis.lowlinks[end]
            pop!(vis.lowlinks)
        end
    end
end
function close_vertex!(vis::TarjanVisitor, v)
    if vis.index[vis.v_idx(v)] == vis.lowlinks[end] 
        component = vis.stack[vis.index[vis.v_idx(v)]:]
        delete!(vis.stack, vis.index[vis.v_idx(v)]:length(vis.stack))
        pop!(vis.lowlinks)
        push!(vis.components, component)
    end 
end

function strongly_connected_components{V}(graph::AbstractGraph{V})
    """Computes the strongly connected components of a directed graph."""
    
    @graph_requires graph vertex_list vertex_map adjacency_list

    cmap = zeros(Int, num_vertices(graph))
    components = Array(Vector{V}, 0)
    
    for v in vertices(graph)
        if cmap[vertex_index(v, graph)] == 0 # 0 means not visited yet
            visitor = TarjanVisitor{V}(graph)
            traverse_graph(graph, DepthFirst(), v, visitor, colormap=cmap)
            for component in visitor.components
                push!(components, component)
            end
        end
    end
    components
end
