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
using DataStructures

export shortest_path

mkindx(t) = typeof(t) == Int ? t : t.index

function a_star_impl!(
    graph::AbstractGraph{V},# the graph
    frontier,               # an initialized heap containing the active vertices
    colormap::Vector{Int},  # an (initialized) color-map to indicate status of vertices
    edge_dists::AbstractEdgePropertyInspector{D},  # cost of each edge
    heuristic::Function,    # heuristic fn (under)estimating distance to target
    t::V) where {V,D} # the end vertex

    tindx = mkindx(t)

    while !isempty(frontier)
        (cost_so_far, path, u) = DataStructures.dequeue!(frontier)
        uindx = mkindx(u)
        if uindx == tindx
            return path
        end

        for edge in out_edges(u, graph)
            v = target(edge)
            vindx = mkindx(v)
            if colormap[vindx] < 2
                colormap[vindx] = 1
                new_path = cat(path, edge, dims=1)
                path_cost = cost_so_far + edge_property(edge_dists, edge, graph)
                DataStructures.enqueue!(frontier,
                        (path_cost, new_path, v),
                        path_cost + heuristic(vindx))
            end
        end
        colormap[uindx] = 2
    end
    nothing
end


function shortest_path(
    graph::AbstractGraph{V,E},  # the graph
    edge_dists::AbstractEdgePropertyInspector{D},      # cost of each edge
    s::V,                       # the start vertex
    t::V,                       # the end vertex
    heuristic::Function = n -> 0) where {V,E,D} # heuristic (under)estimating distance to target
    #
    frontier = DataStructures.PriorityQueue{Tuple{D,Array{E,1},V},D}()
    # frontier = DataStructures.PriorityQueue(Tuple{D,Array{E,1},V},D)
    frontier[(zero(D), E[], s)] = zero(D)
    colormap = zeros(Int, num_vertices(graph))
    sindx = mkindx(s)
    colormap[sindx] = 1
    a_star_impl!(graph, frontier, colormap, edge_dists, heuristic, t)
end

function shortest_path(
    graph::AbstractGraph{V,E},  # the graph
    edge_dists::Vector{D},      # cost of each edge
    s::V,                       # the start vertex
    t::V,                       # the end vertex
    heuristic::Function = n -> 0 )  where {V,E,D}
    #
    edge_len::AbstractEdgePropertyInspector{D} = VectorEdgePropertyInspector(edge_dists)
    shortest_path(graph, edge_len, s, t, heuristic)
end


end

using .AStar
