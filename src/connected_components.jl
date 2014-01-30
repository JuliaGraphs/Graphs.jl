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
    """
    Recursively compute the strongly connected components of a directed graph.

    Adapted from
    http://en.wikipedia.org/wiki/Tarjan%27s_strongly_connected_components_algorithm
    on April 29, 2013.
    """

    @graph_requires graph vertex_list vertex_map adjacency_list

    if !is_directed(graph)
        throw(ArgumentError("graph must be directed."))
    end

    preorder_idx = 1
    stack        = Array(V, 0)
    lowlinks     = zeros(Int, num_vertices(graph))
    indices      = zeros(Int, num_vertices(graph))
    components   = Array(Vector{V}, 0)

    function strongconnect(v)
        v_idx = vertex_index(v)
        indices[v_idx]  = preorder_idx
        lowlinks[v_idx] = preorder_idx
        preorder_idx   += 1
        push!(stack, v)

        # consider successors of v
        for w in out_neighbors(v, graph)
            w_idx = vertex_index(w)
            if indices[v_idx(w)] == 0 # w is un-visited
                strongconnect(w)
                lowlinks[v_idx] = min(lowlinks[v_idx], lowlinks[w_idx])
            elseif (w in stack)
                lowlinks[v_idx] = min(lowlinks[v_idx], indices[w_idx])
            end
        end

        # if v is a root node, pop the stack and generate an SCC
        if lowlinks[v_idx] == indices[v_idx]
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
        if indices[vertex_index(v)] == 0
            strongconnect(v)
        end
    end
    components
end

type TarjanVisitor{V} <: AbstractGraphVisitor
    vertex_index :: Function
    stack        :: Array{V}
    lowlink      :: Array{Int}
    index        :: Array{Int}
    components   :: Array{Vector{V}}

    function TarjanVisitor(graph::AbstractGraph)
        v_idx  = v -> vertex_index(v, graph)
        stack  = Array(V, 0)
        index  = zeros(Int, num_vertices(graph))
        lowlink    = Array(Int, 0)
        components = Array(Vector{V}, 0)

        new(v_idx, stack, lowlink, index, components)
    end
end
function discover_vertex!(vis::TarjanVisitor, v)
    vis.index[vis.vertex_index(v)] = length(vis.stack) + 1
    push!(vis.lowlink, length(vis.stack) + 1)
    push!(vis.stack, v)
    true
end
function examine_neighbor!(vis::TarjanVisitor, v, w, w_color::Int, e_color::Int)
    if w_color == 1 # 1 means added seen, but not explored
        while vis.index[vis.vertex_index(w)] < vis.lowlink[end]
            pop!(vis.lowlink)
        end
    end
end
function close_vertex!(vis::TarjanVisitor, v)
    v_idx = vis.vertex_index(v)
    if vis.index[v_idx] == vis.lowlink[end]
        component = vis.stack[vis.index[v_idx]:end]
        splice!(vis.stack, vis.index[v_idx]:length(vis.stack))
        pop!(vis.lowlink)
        push!(vis.components, component)
    end
end

function strongly_connected_components{V}(graph::AbstractGraph{V})
    """Computes the strongly connected components of a directed graph.

    julia> g = simple_graph(4)
    julia> add_edge!(g, 1, 2)
    julia> add_edge!(g, 2, 3)
    julia> add_edge!(g, 3, 1)
    julia> add_edge!(g, 4, 1)

    julia> strongly_connected_components(g)
    2-element Array{Int64,1} Array:
     [1, 2, 3]
     [4]

    Adapated from
    http://code.activestate.com/recipes/578507-strongly-connected-components-of-a-directed-graph/
    on April 30, 2013.

    """

    @graph_requires graph vertex_list vertex_map adjacency_list

    cmap = zeros(Int, num_vertices(graph))
    components = Array(Vector{V}, 0)

    for v in vertices(graph)
        if cmap[vertex_index(v, graph)] == 0 # 0 means not visited yet
            visitor = TarjanVisitor{V}(graph)
            traverse_graph(graph, DepthFirst(), v, visitor, vertexcolormap=cmap)
            for component in visitor.components
                push!(components, component)
            end
        end
    end
    components
end
