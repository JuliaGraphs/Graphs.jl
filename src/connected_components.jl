# Algorithms to find connected components

###########################################################
#
#   Connected components of undirected graph
#
##########################################################

function connected_components(graph::AbstractGraph{V}) where {V}
    @graph_requires graph vertex_list vertex_map adjacency_list

    !is_directed(graph) || error("graph must be undirected.")

    cmap = zeros(Int, num_vertices(graph))
    components = Array{Vector{V}}(undef, 0)

    for vv in vertices(graph)
        if cmap[vertex_index(vv, graph)] == 0
            visitor = VertexListVisitor{V}(0)
            traverse_graph(graph, BreadthFirst(), vv, visitor, colormap=cmap)
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

#
# Recursively compute the strongly connected components of a directed graph.
#
# Adapted from
# http://en.wikipedia.org/wiki/Tarjan%27s_strongly_connected_components_algorithm
# on April 29, 2013.
#
function strongly_connected_components_recursive(graph::AbstractGraph{V}) where {V}
    @graph_requires graph vertex_list vertex_map adjacency_list

    is_directed(graph) || error("graph must be directed.")

    preorder_idx = 1
    stack        = Array{V}(0)
    lowlinks     = zeros(Int, num_vertices(graph))
    indices      = zeros(Int, num_vertices(graph))
    components   = Array{Vector{V}}(0)

    function strongconnect(v)
        v_idx = vertex_index(v, graph)
        indices[v_idx]  = preorder_idx
        lowlinks[v_idx] = preorder_idx
        preorder_idx   += 1
        push!(stack, v)

        # consider successors of v
        for w in out_neighbors(v, graph)
            w_idx = vertex_index(w, graph)
            if indices[v_idx(w)] == 0 # w is un-visited
                strongconnect(w)
                lowlinks[v_idx] = min(lowlinks[v_idx], lowlinks[w_idx])
            elseif (w in stack)
                lowlinks[v_idx] = min(lowlinks[v_idx], indices[w_idx])
            end
        end

        # if v is a root node, pop the stack and generate an SCC
        if lowlinks[v_idx] == indices[v_idx]
            component = Array{typeof(v)}(0)
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
        if indices[vertex_index(v, graph)] == 0
            strongconnect(v)
        end
    end
    components
end

mutable struct TarjanVisitor{G<:AbstractGraph,V} <: AbstractGraphVisitor
    graph::G
    stack::Vector{V}
    lowlink::Vector{Int}
    index::Vector{Int}
    components::Vector{Vector{V}}
end

TarjanVisitor(graph::AbstractGraph{V}) where {V} = TarjanVisitor{typeof(graph),V}(graph,
        V[], Int[], zeros(Int, num_vertices(graph)), Vector{V}[])

function discover_vertex!(vis::TarjanVisitor, v)
    iv = vertex_index(v, vis.graph)
    vis.index[iv] = length(vis.stack) + 1
    push!(vis.lowlink, length(vis.stack) + 1)
    push!(vis.stack, v)
    return true
end

function examine_neighbor!(vis::TarjanVisitor, v, w, w_color::Int, e_color::Int)
    if w_color == 1 # 1 means added seen, but not explored
        while vis.index[vertex_index(w, vis.graph)] < vis.lowlink[end]
            pop!(vis.lowlink)
        end
    end
end

function close_vertex!(vis::TarjanVisitor, v)
    iv = vertex_index(v, vis.graph)
    if vis.index[iv] == vis.lowlink[end]
        component = vis.stack[vis.index[iv]:end]
        splice!(vis.stack, vis.index[iv]:length(vis.stack))
        pop!(vis.lowlink)
        push!(vis.components, component)
    end
end

#
# Computes the strongly connected components of a directed graph.
#
# Adapated from
# http://code.activestate.com/recipes/578507-strongly-connected-components-of-a-directed-graph/
# on April 30, 2013.
#
function strongly_connected_components(graph::AbstractGraph{V}) where {V}
    @graph_requires graph vertex_list vertex_map adjacency_list

    cmap = zeros(Int, num_vertices(graph))
    components = Array{Vector{V}}(undef, 0)

    for vv in vertices(graph)
        if cmap[vertex_index(vv, graph)] == 0 # 0 means not visited yet
            visitor = TarjanVisitor(graph)
            traverse_graph(graph, DepthFirst(), vv, visitor, vertexcolormap=cmap)
            for component in visitor.components
                push!(components, component)
            end
        end
    end
    components
end
