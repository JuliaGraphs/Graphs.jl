Graph.jl
========

# Installation

    require("pkg")
    Pkg.add("Graphs")

# Getting Started

    require("Graphs")
    using Graphs

# Usage

    require("Graphs")
    using Graphs

    v1 = Vertex(1, "A")
    v2 = Vertex(2, "B")
    id(v1)
    label(v1)

    vertex_set = Set(v1, v2)

    e1 = DirectedEdge(v1, v2)
    out(e1)
    in(e1)
    label(e1)
    weight(e1)

    rev_e1 = DirectedEdge(v2, v1)
    isequal(e1, rev_e1)

    edge_set = Set(e1)

    g = DirectedGraph(vertex_set, edge_set)

    m = ["a" "b";
         "a" "c";
         "b" "c";]

    g = DirectedGraph(m)

    adjacency_matrix(g)

    e1 = UndirectedEdge(v1, v2)
    alt_e1 = UndirectedEdge(v2, v1)
    isequal(e1, alt_e1)

    edge_set = Set(e1)

    g = UndirectedGraph(vertex_set, edge_set)

    degree_matrix(g)

    adjacency_matrix(g)

    laplacian(g)

    incidence_matrix(g)

    V = {1, 2, 3, 4, 5, 6}
    E = {{1, 2}, {1, 5}, {2, 3}, {2, 5}, {3, 4}, {4, 5}, {4, 6}}

    g = UndirectedGraph(V, E)

    adjacency_matrix(g)
    incidence_matrix(g)
