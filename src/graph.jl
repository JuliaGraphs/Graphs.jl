##############################################################################
#
# Basic graph type definitions and constructors
#
##############################################################################

# TODO: Add a Multigraph type
# TODO: Enforce integrity constraints during construction
#       * Min vertex ID = 1
#       * Max vertex ID = length(vertices)

type UndirectedGraph
    vertices::Set{Vertex}
    edges::Set{UndirectedEdge}
end

type DirectedGraph
    vertices::Set{Vertex}
    edges::Set{DirectedEdge}
end
typealias Digraph DirectedGraph
typealias Graph Union(UndirectedGraph, DirectedGraph)

# TODO: Use @eval to make these DRYer
function UndirectedGraph(vertex_list::Vector{Any}, edge_list::Vector{Any})
    n_vertices = length(vertex_list)
    n_edges = length(edge_list)

    vertex_set = Set{Vertex}()
    vertices = Array(Vertex, n_vertices)
    for i in 1:n_vertices
        v = Vertex(i, utf8(string(vertex_list[i])))
        add(vertex_set, v)
        vertices[i] = v
    end

    edge_set = Set{UndirectedEdge}()
    for i in 1:n_edges
        e = UndirectedEdge(vertices[edge_list[i][1]],
                         vertices[edge_list[i][2]],
                         utf8(""),
                         1.0)
        add(edge_set, e)
    end

    return UndirectedGraph(vertex_set, edge_set)
end

function DirectedGraph(vertex_list::Vector{Any}, edge_list::Vector{Any})
    n_vertices = length(vertex_list)
    n_edges = length(edge_list)

    vertex_set = Set{Vertex}()
    vertices = Array(Vertex, n_vertices)
    for i in 1:n_vertices
        v = Vertex(i, utf8(string(vertex_list[i])))
        add(vertex_set, v)
        vertices[i] = v
    end

    edge_set = Set{DirectedEdge}()
    for i in 1:n_edges
        e = DirectedEdge(vertices[edge_list[i][1]],
                         vertices[edge_list[i][2]],
                         utf8(""),
                         1.0)
        add(edge_set, e)
    end

    return DirectedGraph(vertex_set, edge_set)
end

function UndirectedGraph(vertex_labels::Vector{UTF8String}, numeric_edges::Matrix{Int})
    n_vertices = length(vertex_labels)
    n_edges = size(numeric_edges, 1)

    vertex_set = Set{Vertex}()
    vertices = Array(Vertex, n_vertices)
    for i in 1:n_vertices
        v = Vertex(i, vertex_labels[i])
        add(vertex_set, v)
        vertices[i] = v
    end

    edge_set = Set{UndirectedEdge}()
    for i in 1:n_edges
        e = UndirectedEdge(vertices[numeric_edges[i, 1]],
                         vertices[numeric_edges[i, 2]],
                         utf8(""),
                         1.0)
        add(edge_set, e)
    end

    return UndirectedGraph(vertex_set, edge_set)
end

function DirectedGraph(vertex_labels::Vector{UTF8String}, numeric_edges::Matrix{Int})
    n_vertices = length(vertex_labels)
    n_edges = size(numeric_edges, 1)

    vertex_set = Set{Vertex}()
    vertices = Array(Vertex, n_vertices)
    for i in 1:n_vertices
        v = Vertex(i, vertex_labels[i])
        add(vertex_set, v)
        vertices[i] = v
    end

    edge_set = Set{DirectedEdge}()
    for i in 1:n_edges
        e = DirectedEdge(vertices[numeric_edges[i, 1]],
                         vertices[numeric_edges[i, 2]],
                         utf8(""),
                         1.0)
        add(edge_set, e)
    end

    return DirectedGraph(vertex_set, edge_set)
end

function UndirectedGraph{T <: String}(edges::Matrix{T})
    default_max_vertices = 1_000
    vertex_labels = Array(UTF8String, default_max_vertices)
    vertex_ids = Dict{UTF8String, Int}()

    next_vertex_id = 1
    numeric_edges = Array(Int, size(edges))

    for i in 1:size(edges, 1)
        if length(vertex_labels) - 1 <= next_vertex_id
            grow(vertex_labels, 2 * length(vertex_labels))
        end

        out_vertex_label, in_vertex_label = edges[i, 1], edges[i, 2]

        out_vertex_id = get(vertex_ids, out_vertex_label, 0)
        if out_vertex_id == 0
            out_vertex_id = next_vertex_id
            vertex_ids[out_vertex_label] = out_vertex_id
            vertex_labels[out_vertex_id] = out_vertex_label
            next_vertex_id += 1
        end

        in_vertex_id = get(vertex_ids, in_vertex_label, 0)
        if in_vertex_id == 0
            in_vertex_id = next_vertex_id
            vertex_ids[in_vertex_label] = in_vertex_id
            vertex_labels[in_vertex_id] = in_vertex_label
            next_vertex_id += 1
        end

        numeric_edges[i, 1], numeric_edges[i, 2] = out_vertex_id, in_vertex_id
    end

    return UndirectedGraph(vertex_labels[1:(next_vertex_id - 1)], numeric_edges)
end

function DirectedGraph{T <: String}(edges::Matrix{T})
    default_max_vertices = 1_000
    vertex_labels = Array(UTF8String, default_max_vertices)
    vertex_ids = Dict{UTF8String, Int}()

    next_vertex_id = 1
    numeric_edges = Array(Int, size(edges))

    for i in 1:size(edges, 1)
        if length(vertex_labels) - 1 <= next_vertex_id
            grow(vertex_labels, 2 * length(vertex_labels))
        end

        out_vertex_label, in_vertex_label = edges[i, 1], edges[i, 2]

        out_vertex_id = get(vertex_ids, out_vertex_label, 0)
        if out_vertex_id == 0
            out_vertex_id = next_vertex_id
            vertex_ids[out_vertex_label] = out_vertex_id
            vertex_labels[out_vertex_id] = out_vertex_label
            next_vertex_id += 1
        end

        in_vertex_id = get(vertex_ids, in_vertex_label, 0)
        if in_vertex_id == 0
            in_vertex_id = next_vertex_id
            vertex_ids[in_vertex_label] = in_vertex_id
            vertex_labels[in_vertex_id] = in_vertex_label
            next_vertex_id += 1
        end

        numeric_edges[i, 1], numeric_edges[i, 2] = out_vertex_id, in_vertex_id
    end

    return DirectedGraph(vertex_labels[1:(next_vertex_id - 1)], numeric_edges)
end

##############################################################################
#
# Basic properties of a graph
#
##############################################################################

vertices(g::Graph) = g.vertices
edges(g::Graph) = g.edges
order(g::Graph) = length(vertices(g))
size(g::Graph) = length(edges(g))

##############################################################################
#
# Comparisons
#
##############################################################################

function isequal(g1::Graph, g2::Graph)
    return isequal(g1.vertices, g2.vertices) && isequal(g1.edges, g2.edges)
end
