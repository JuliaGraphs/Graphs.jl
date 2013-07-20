# Depth-first visit / traversal


#################################################
#
#  Depth-first visit
#
#################################################

type DepthFirst <: AbstractGraphVisitAlgorithm
end

function depth_first_visit_impl!(
    graph::AbstractGraph,           # the graph
    stack,                          # an (initialized) stack of vertex
    colormap::Vector{Int},          # an (initialized) color-map to indicate status of vertices
    visitor::AbstractGraphVisitor)  # the visitor

    while !isempty(stack)
        u, unbs, tstate = pop!(stack)
        found_new_vertex = false

        while !done(unbs, tstate) && !found_new_vertex
            v, tstate = next(unbs, tstate)
            v_color = colormap[vertex_index(v, graph)]
            examine_neighbor!(visitor, u, v, v_color)

            if v_color == 0
                found_new_vertex = true
                colormap[vertex_index(v, graph)] = 1
                if !discover_vertex!(visitor, v)
                    return
                end
                push!(stack, (u, unbs, tstate))

                open_vertex!(visitor, v)
                vnbs = out_neighbors(v, graph)
                push!(stack, (v, vnbs, start(vnbs)))
            end
        end

        if !found_new_vertex
            close_vertex!(visitor, u)
            colormap[vertex_index(u, graph)] = 2
        end
    end
end

function traverse_graph{V,E}(
    graph::AbstractGraph{V,E},
    alg::DepthFirst,
    s::V,
    visitor::AbstractGraphVisitor;
    colormap = nothing)

    @graph_requires graph adjacency_list vertex_map

    if colormap == nothing
        colormap = zeros(Int, num_vertices(graph))
    end

    colormap[vertex_index(s, graph)] = 1
    if !discover_vertex!(visitor, s)
        return
    end

    snbs = out_neighbors(s, graph)
    sstate = start(snbs)
    stack = [(s, snbs, sstate)]

    depth_first_visit_impl!(graph, stack, colormap, visitor)
end


#################################################
#
#  Useful applications
#
#################################################

# Test whether a graph is cyclic

type DFSCyclicTestVisitor <: AbstractGraphVisitor
    found_cycle::Bool
    DFSCyclicTestVisitor() = new(false)
end

function examine_neighbor!{V}(vis::DFSCyclicTestVisitor, u::V, v::V, color::Int)
    if color == 1
        vis.found_cycle = true
    end
end

discover_vertex!(vis::DFSCyclicTestVisitor, v) = !vis.found_cycle

function test_cyclic_by_dfs(graph::AbstractGraph)
    @graph_requires graph vertex_list adjacency_list vertex_map

    cmap = zeros(Int, num_vertices(graph))
    visitor = DFSCyclicTestVisitor()

    for s in vertices(graph)
        if cmap[vertex_index(s, graph)] == 0
            traverse_graph(graph, DepthFirst(), s, visitor, colormap=cmap)
        end

        if visitor.found_cycle
            return true
        end
    end
    return false
end

# Topological sort using DFS

type TopologicalSortVisitor{V} <: AbstractGraphVisitor
    vertices::Vector{V}

    function TopologicalSortVisitor(n::Int)
        vs = Array(Int, 0)
        sizehint(vs, n)
        new(vs)
    end
end


function examine_neighbor!{V}(visitor::TopologicalSortVisitor{V}, u::V, v::V, color::Int)
    if color == 1
        throw(ArgumentError("The input graph contains at least one loop."))
    end
end

function close_vertex!{V}(visitor::TopologicalSortVisitor{V}, v::V)
    push!(visitor.vertices, v)
end

function topological_sort_by_dfs{V}(graph::AbstractGraph{V})
    @graph_requires graph vertex_list adjacency_list vertex_map

    cmap = zeros(Int, num_vertices(graph))
    visitor = TopologicalSortVisitor{V}(num_vertices(graph))

    for s in vertices(graph)
        if cmap[s] == 0
            traverse_graph(graph, DepthFirst(), s, visitor, colormap=cmap)
        end
    end

    reverse(visitor.vertices)
end






