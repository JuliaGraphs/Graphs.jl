# Breadth-first search / traversal

#################################################
#
#  Breadth-first visit
#
#################################################

mutable struct BreadthFirst <: AbstractGraphVisitAlgorithm
end

function breadth_first_visit_impl!(
    graph::AbstractGraph,   # the graph
    queue,                  # an (initialized) queue that stores the active vertices
    colormap,               # an (initialized) color-map to indicate status of vertices
    visitor::AbstractGraphVisitor)  # the visitor

    while !isempty(queue)
        u = dequeue!(queue)
        open_vertex!(visitor, u)

        for v in out_neighbors(u, graph)
            vi = vertex_index(v, graph)
            v_color::Int = colormap[vi]
            # TODO: Incorporate edge colors to BFS
            examine_neighbor!(visitor, u, v, v_color, -1)

            if v_color == 0
                colormap[vi] = 1
                if !discover_vertex!(visitor, v)
                    return
                end
                enqueue!(queue, v)
            end
        end

        colormap[vertex_index(u, graph)] = 2
        close_vertex!(visitor, u)
    end
    nothing
end

initialize_colormap(graph::AbstractGraph{V,E},visitor) where {V,E} =
    zeros(Int, num_vertices(graph))

function traverse_graph(
    graph::AbstractGraph{V,E},
    alg::BreadthFirst,
    s::V,
    visitor::AbstractGraphVisitor;
    colormap = nothing) where {V,E}

    if colormap === nothing
        colormap = initialize_colormap(graph, visitor)
    end

    @graph_requires graph adjacency_list vertex_map

    que = Queue{V}()

    colormap[vertex_index(s, graph)] = 1
    if !discover_vertex!(visitor, s)
        return
    end
    enqueue!(que, s)

    breadth_first_visit_impl!(graph, que, colormap, visitor)
end


function traverse_graph(
    graph::AbstractGraph{V,E},
    alg::BreadthFirst,
    sources::AbstractVector{V},
    visitor::AbstractGraphVisitor;
    colormap = nothing) where {V,E}

    if colormap === nothing
        colormap = initialize_colormap(graph, visitor)
    end

    @graph_requires graph adjacency_list vertex_map

    que = Queue{V}()

    for s in sources
        colormap[vertex_index(s, graph)] = 1
        if !discover_vertex!(visitor, s)
            return
        end
        enqueue!(que, s)
    end

    breadth_first_visit_impl!(graph, que, colormap, visitor)
end


#################################################
#
#  Useful applications
#
#################################################

# Get the map of the (geodesic) distances from vertices to source by BFS

struct GDistanceVisitor{G<:AbstractGraph,DMap} <: AbstractGraphVisitor
    graph::G
    dists::DMap
    GDistanceVisitor(g::G, dists::DMap) where {G <: AbstractGraph, DMap} = new{G,DMap}(g, dists)
    GDistanceVisitor{G,DMap}(g::G, dists::DMap) where {G <: AbstractGraph, DMap} = new{G,DMap}(g, dists)
end

# GDistanceVisitor{G<:AbstractGraph,DMap}(g::G, dists::DMap) = GDistanceVisitor{G,DMap}(g, dists)

function initialize_colormap(graph::AbstractGraph{V,E},dmap::GDistanceVisitor{G,DMap}) where {V,E,G,DMap<:Dict}
    colormap = similar(dmap)
    for k in keys(dmap)
        colormap[k] = 0
    end
    colormap
end

function examine_neighbor!(visitor::GDistanceVisitor, u, v, vcolor::Int, ecolor::Int)
    if vcolor == 0
        g = visitor.graph
        dists = visitor.dists
        dists[vertex_index(v, g)] = dists[vertex_index(u, g)] + 1
    end
end

function gdistances!(graph::AbstractGraph{V,E}, s::V, dists::DMap) where {V,E,DMap}
    visitor = GDistanceVisitor(graph, dists)
    dists[vertex_index(s, graph)] = 0
    traverse_graph(graph, BreadthFirst(), s, visitor)
    dists
end

function gdistances!(graph::AbstractGraph{V,E}, sources::AbstractVector{V}, dists::DMap) where {V,E,DMap}
    visitor = GDistanceVisitor(graph, dists)
    for s in sources
        dists[vertex_index(s, graph)] = 0
    end
    traverse_graph(graph, BreadthFirst(), sources, visitor)
    dists
end

function gdistances(graph::AbstractGraph, sources; defaultdist::Int=-1)
    dists = fill(defaultdist, num_vertices(graph))
    gdistances!(graph, sources, dists)
end
