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

    vertex_set = Set(v1, v2)

    e1 = DirectedEdge(v1, v2)

    edge_set = Set(e1)

    g = DirectedGraph(vertex_set, edge_set)

    m = ["a" "b";
         "a" "c";
         "b" "c";]

    g = DirectedGraph(m)
    adjacency_matrix(g)

    e1 = UndirectedEdge(v1, v2)

    edge_set = Set(e1)

    g = UndirectedGraph(vertex_set, edge_set)

    laplacian(g)
