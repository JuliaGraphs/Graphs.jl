# A* shortest-path algorithm

#################################################
#
#  A* shortest-path algorithm
#
#################################################

module AStar

# The enqueue! and dequeue! methods defined in Base.Collections (needed for
# PriorityQueues) conflict with those used for queues. Hence we wrap the A*
# code in its own module.

using Graphs
using Base.Collections

export shortest_path

function a_star_impl!{V,D}(
    graph::AbstractGraph{V},# the graph
    frontier,               # an initialized heap containing the active vertices
    colormap::Vector{Int},  # an (initialized) color-map to indicate status of vertices
    edge_dists::AbstractEdgeLengthVisitor{D},  # cost of each edge
    heuristic::Function,    # heuristic fn (under)estimating distance to target
    t::V)  # the end vertex

    while !isempty(frontier)
        (cost_so_far, path, u) = dequeue!(frontier)
        if u == t
            return path
        end

        for edge in out_edges(u, graph)
            v = target(edge)
            if colormap[v] < 2
                colormap[v] = 1
                new_path = cat(1, path, edge)
                path_cost = cost_so_far + edge_length(edge_dists, edge, graph)
                enqueue!(frontier,
                        (path_cost, new_path, v),
                        path_cost + heuristic(v))
            end
        end
        colormap[u] = 2
    end
    nothing
end


function shortest_path{V,E,D}(
    graph::AbstractGraph{V,E},  # the graph
    edge_dists::AbstractEdgeLengthVisitor{D},      # cost of each edge
    s::V,                       # the start vertex
    t::V,                       # the end vertex
    heuristic::Function = n -> 0)
            # heuristic (under)estimating distance to target
    frontier = PriorityQueue{(D,Array{E,1},V),D}()
    frontier[(zero(D), E[], s)] = zero(D)
    colormap = zeros(Int, num_vertices(graph))
    colormap[s] = 1
    a_star_impl!(graph, frontier, colormap, edge_dists, heuristic, t)
end

function shortest_path{V,E,D}(
    graph::AbstractGraph{V,E},  # the graph
    edge_dists::Vector{D},      # cost of each edge
    s::V,                       # the start vertex
    t::V,                       # the end vertex
    heuristic::Function = n -> 0)
    edge_len::AbstractEdgeLengthVisitor{D} = VectorEdgeLengthVisitor(edge_dists)
    shortest_path(graph, edge_len, s, t, heuristic)
end


end

using .AStar
