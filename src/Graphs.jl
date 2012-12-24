module Graphs
    import Base.order, Base.size, Base.string, Base.repl_show, Base.show, Base.print
    import Base.isequal

    export Vertex
    export id, label

    export UndirectedEdge, DirectedEdge, Edge
    export out, in, label, weight, ends

    export UndirectedGraph, DirectedGraph, Digraph, Graph
    export vertices, edges, order, size

    export degree, indegree, outdegree, degrees
    export connected, adjacent, coincident
    export isconnected, iscomplete, isdirected, isregular
    export issimple, issymmetric, isweighted

    export adjacency_matrix, degree_matrix, distance_matrix
    export incidence_matrix, laplacian_matrix, laplacian

    export read_edgelist, read_tgf, read_graphml

    require("Graphs/src/vertex.jl")
    require("Graphs/src/edge.jl")
    require("Graphs/src/graph.jl")
    require("Graphs/src/advanced.jl")
    require("Graphs/src/io.jl")
    require("Graphs/src/show.jl")
end
