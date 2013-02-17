##############################################################################
#
# Basic graph type definitions and constructors
#
# TODO: Add a Multigraph type
#
##############################################################################

abstract AbstractGraph

type UndirectedGraph <: AbstractGraph
    vertices::Set{Vertex}
    edges::Set{UndirectedEdge}

    # Enforces integrity constraints during construction if violated:
    #  * Min vertex ID = 1
    #  * Max vertex ID = length(vertices)
    function UndirectedGraph(v::Set{Vertex}, e::Set{UndirectedEdge})
        ids = Int[vertex.id for vertex in v]
        if sort(ids) != 1:length(v)
            i = 1
            for vertex in v
                vertex.id = i
                i += 1
            end
        end
        new(v, e)
    end
end
UndirectedGraph() = UndirectedGraph(Set{Vertex}(), Set{UndirectedEdge}())
empty_graph(::Type{UndirectedGraph}) = UndirectedGraph()

type DirectedGraph <: AbstractGraph
    vertices::Set{Vertex}
    edges::Set{DirectedEdge}

    # Enforces integrity constraints during construction if violated:
    #  * Min vertex ID = 1
    #  * Max vertex ID = length(vertices)
    function DirectedGraph(v::Set{Vertex}, e::Set{DirectedEdge})
        ids = Int[vertex.id for vertex in v]
        if sort(ids) != 1:length(v)
            i = 1
            for vertex in v
                vertex.id = i
                i += 1
            end
        end
        new(v, e)
    end
end
DirectedGraph() = DirectedGraph(Set{Vertex}(), Set{DirectedEdge}())
empty_graph(::Type{DirectedGraph}) = DirectedGraph()

type MixedGraph <: AbstractGraph
    vertices::Set{Vertex}
    edges::Set{Edge}

    # Enforces integrity constraints during construction if violated:
    #  * Min vertex ID = 1
    #  * Max vertex ID = length(vertices)
    function MixedGraph(v::Set{Vertex}, e::Set{Edge})
        ids = Int[vertex.id for vertex in v]
        if sort(ids) != 1:length(v)
            i = 1
            for vertex in v
                vertex.id = i
                i += 1
            end
        end
        new(v, e)
    end
end
MixedGraph() = MixedGraph(Set{Vertex}(), Set{Edge}())
empty_graph(::Type{MixedGraph}) = MixedGraph()

typealias Digraph DirectedGraph

# TODO: Use @eval to make all of these constructors DRYer
function UndirectedGraph(vertex_list::Vector{Any}, edge_list::Vector{Any})
    n_vertices = length(vertex_list)
    n_edges = length(edge_list)

    vertex_set = Set{Vertex}()
    vertices = Array(Vertex, n_vertices)
    for i in 1:n_vertices
        v = Vertex(i, utf8(string(vertex_list[i])))
        add!(vertex_set, v)
        vertices[i] = v
    end

    edge_set = Set{UndirectedEdge}()
    for i in 1:n_edges
        e = UndirectedEdge(vertices[edge_list[i][1]],
                           vertices[edge_list[i][2]],
                           utf8(""),
                           1.0,
                           Dict{UTF8String, Any}())
        add!(edge_set, e)
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
        add!(vertex_set, v)
        vertices[i] = v
    end

    edge_set = Set{DirectedEdge}()
    for i in 1:n_edges
        e = DirectedEdge(vertices[edge_list[i][1]],
                         vertices[edge_list[i][2]],
                         utf8(""),
                         1.0,
                         Dict{UTF8String, Any}())
        add!(edge_set, e)
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
        add!(vertex_set, v)
        vertices[i] = v
    end

    edge_set = Set{UndirectedEdge}()
    for i in 1:n_edges
        e = UndirectedEdge(vertices[numeric_edges[i, 1]],
                         vertices[numeric_edges[i, 2]],
                         utf8(""),
                         1.0,
                         Dict{UTF8String, Any}())
        add!(edge_set, e)
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
        add!(vertex_set, v)
        vertices[i] = v
    end

    edge_set = Set{DirectedEdge}()
    for i in 1:n_edges
        e = DirectedEdge(vertices[numeric_edges[i, 1]],
                         vertices[numeric_edges[i, 2]],
                         utf8(""),
                         1.0,
                         Dict{UTF8String, Any}())
        add!(edge_set, e)
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
            grow!(vertex_labels, 2 * length(vertex_labels))
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
            grow!(vertex_labels, 2 * length(vertex_labels))
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

function Graph(vertex_list::Vector{Any}, edge_list::Vector{Any})
    if isa(edge_list[1], Tuple)
        DirectedGraph(vertex_list, edge_list)
    else
        UndirectedGraph(vertex_list, edge_list)
    end
end

function UndirectedGraph(a::Matrix{Int})
    if !isequal(a, a')
        error("Adjacency matrix of an undirected graph must be symmetric")
    end
    n_vertices = size(a, 1)

    vertex_set = Set{Vertex}()
    vertices = Array(Vertex, n_vertices)

    edge_set = Set{UndirectedEdge}()

    for i in 1:n_vertices
        v = Vertex(i, utf8(""), Dict{UTF8String, Any}())
        add!(vertex_set, v)
        vertices[i] = v
    end

    for i in 1:n_vertices
        for j in i:n_vertices
            if a[i, j] == 1
                e = UndirectedEdge(vertices[i],
                                   vertices[j],
                                   utf8(""),
                                   1.0,
                                   Dict{UTF8String, Any}())
                add!(edge_set, e)
            end
        end
    end

    return UndirectedGraph(vertex_set, edge_set)
end

function DirectedGraph(a::Matrix{Int})
    if size(a, 1) != size(a, 2)
        error("Adjacency matrix must be square")
    end
    n_vertices = size(a, 1)

    vertex_set = Set{Vertex}()
    vertices = Array(Vertex, n_vertices)

    edge_set = Set{DirectedEdge}()

    for i in 1:n_vertices
        v = Vertex(i, utf8(""), Dict{UTF8String, Any}())
        add!(vertex_set, v)
        vertices[i] = v
    end

    for i in 1:n_vertices
        for j in 1:n_vertices
            if a[i, j] == 1
                e = DirectedEdge(vertices[i],
                                 vertices[j],
                                 utf8(""),
                                 1.0,
                                 Dict{UTF8String, Any}())
                add!(edge_set, e)
            end
        end
    end

    return DirectedGraph(vertex_set, edge_set)
end

##############################################################################
#
# Basic properties of a graph
#
##############################################################################

vertices(g::AbstractGraph) = g.vertices
edges(g::AbstractGraph) = g.edges
order(g::AbstractGraph) = length(vertices(g))
size(g::AbstractGraph) = length(edges(g))

##############################################################################
#
# Comparisons
#
##############################################################################

function isequal(g1::AbstractGraph, g2::AbstractGraph)
    return isequal(g1.vertices, g2.vertices) && isequal(g1.edges, g2.edges)
end

##############################################################################
#
# Add and remove vertices and edges from an existing
#
##############################################################################

function add!(g::AbstractGraph, v::Vertex)
    add!(vertices(g), v)
end

function del(g::AbstractGraph, v::Vertex)
    del(vertices(g), v)
end

function add!(g::AbstractGraph, v::Edge)
    add!(edges(g), v)
end

function del(g::AbstractGraph, v::Edge)
    del(edges(g), v)
end
