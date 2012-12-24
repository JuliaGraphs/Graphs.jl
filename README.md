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

    vertices = [v1, v2]

    e1 = Edge(v1, v2)

    edges = [e1]

    g = Graph(vertices, edges)

    m = ["a" "b";
         "a" "c";
         "b" "c";]

    g = Graph(m)
    adjacency_matrix(g)
