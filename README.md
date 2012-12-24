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

    n1 = Node(1, "A")
    n2 = Node(2, "B")

    nodes = [n1, n2]

    e1 = Edge(n1, n2)

    edges = [e1]

    g = Graph(nodes, edges)

    m = ["a" "b";
         "a" "c";
         "b" "c";]

    g = Graph(m)
    adjacency_matrix(g)
