# Depth-first visit / traversal


#################################################
#
#  Depth-first visit
#
#################################################

mutable struct DepthFirst <: AbstractGraphVisitAlgorithm
end

function depth_first_visit_impl!(
    graph::AbstractGraph{V,E},      # the graph
    stack,                          # an (initialized) stack of vertex
    vertexcolormap::Vector{Int},    # an (initialized) color-map to indicate status of vertices
    edgecolormap::Vector{Int},      # an (initialized) color-map to indicate status of edges
    visitor::AbstractGraphVisitor) where {V,E} # the visitor

    while !isempty(stack)
        u, uegs, tstate = pop!(stack)
        found_new_vertex = false
        while tstate <= length(uegs) && !found_new_vertex #!done(uegs, tstate)
            v_edge, tstate = iterate(uegs, tstate)
            # v_edge, tstate = next(uegs, tstate)
            v = v_edge.target
            v_color = vertexcolormap[vertex_index(v, graph)]
            e_color = edgecolormap[edge_index(v_edge, graph)]
            examine_neighbor!(visitor, u, v, v_color, e_color)

            if e_color == 0
                edgecolormap[edge_index(v_edge, graph)] = 1
            end

            if v_color == 0
                found_new_vertex = true
                vertexcolormap[vertex_index(v, graph)] = 1
                if !discover_vertex!(visitor, v)
                    return
                end
                push!(stack, (u, uegs, tstate))

                open_vertex!(visitor, v)
                vegs = out_edges(v, graph)
                push!(stack, (v, vegs, 1)) # push!(stack, (v, vegs, start(vegs)))
            end
        end

        if !found_new_vertex
            close_vertex!(visitor, u)
            vertexcolormap[vertex_index(u, graph)] = 2
        end
    end
end

function traverse_graph(
    graph::G,
    alg::DepthFirst,
    s::V,
    visitor::AbstractGraphVisitor;
    vertexcolormap = zeros(Int, num_vertices(graph)),
    edgecolormap = zeros(Int, num_edges(graph))) where {V,G <: AbstractGraph}

    @graph_requires graph incidence_list vertex_map

    vertexcolormap[vertex_index(s, graph)] = 1
    if !discover_vertex!(visitor, s)
        return
    end

    segs = out_edges(s, graph)
    sstate = 1 #sstate = start(segs)
    stack = [(s, segs, sstate)]

    depth_first_visit_impl!(graph, stack, vertexcolormap, edgecolormap, visitor)
end


#################################################
#
#  Useful applications
#
#################################################

# Test whether a graph is cyclic

mutable struct DFSCyclicTestVisitor <: AbstractGraphVisitor
    found_cycle::Bool

    DFSCyclicTestVisitor() = new(false)
end

function examine_neighbor!(
    vis::DFSCyclicTestVisitor,
    u::V,
    v::V,
    vcolor::Int,
    ecolor::Int) where {V}

    if vcolor == 1 && ecolor == 0
        vis.found_cycle = true
    end
end

discover_vertex!(vis::DFSCyclicTestVisitor, v) = !vis.found_cycle

function test_cyclic_by_dfs(graph::G) where {G <: AbstractGraph}
    @graph_requires graph vertex_list incidence_list vertex_map

    cmap = zeros(Int, num_vertices(graph))
    visitor = DFSCyclicTestVisitor()

    for s in vertices(graph)
        if cmap[vertex_index(s, graph)] == 0
            traverse_graph(graph, DepthFirst(), s, visitor, vertexcolormap=cmap)
        end

        if visitor.found_cycle
            return true
        end
    end
    return false
end

# Topological sort using DFS

mutable struct TopologicalSortVisitor{V} <: AbstractGraphVisitor
    vertices::Vector{V}
    function TopologicalSortVisitor{V}(n::Int) where V
      vs = Array{Int}(undef, 0)
      sizehint!(vs, n)
      new{V}(vs)
    end
end


function examine_neighbor!(visitor::TopologicalSortVisitor{V}, u::V, v::V, vcolor::Int, ecolor::Int) where {V}
    if vcolor == 1 && ecolor == 0
        throw(ArgumentError("The input graph contains at least one loop."))
    end
end

function close_vertex!(visitor::TopologicalSortVisitor{V}, v::V) where {V}
    push!(visitor.vertices, v)
end

function topological_sort_by_dfs(graph::AbstractGraph{V}) where {V}
    @graph_requires graph vertex_list incidence_list vertex_map

    cmap = zeros(Int, num_vertices(graph))
    visitor = TopologicalSortVisitor{V}(num_vertices(graph))
    for s in vertices(graph)
        if cmap[vertex_index(s, graph)] == 0
            traverse_graph(graph, DepthFirst(), s, visitor, vertexcolormap=cmap)
        end
    end

    reverse(visitor.vertices)
end
