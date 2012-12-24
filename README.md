Graphs.jl
========

Graphs.jl is a Julia package for working with graphs. It supports a basic core
of functions now and will add many features and performance improvements as
time goes on.

# Installation

You can install Graphs.jl using the Julia package manager.

    require("pkg")
    Pkg.add("Graphs")

# Usage

In the following examples, we'll assume that you are familiar with the
mathematical properties of graphs and only need an introduction to the API
for working with them in Julia.

To get start, let's load the Graphs package:

    require("Graphs")
    using Graphs

Then we'll create our first vertex whose numeric ID is 1 and whose label
will be `"A"`:

    v1 = Vertex(1, "A")

We can create a second vertex with the label `"B"` and then create an
unlabeled vertex as well:

    v2 = Vertex(2, "B")
    v3 = Vertex(3)

Every vertex has a numeric ID, a label and a set of attributes:

    id(v1)
    label(v1)
    attributes(v1)

To place vertices together, we'll use Julia's `Set` type:

    vertex_set = Set(v1, v2)

While there is only type of vertex, we distinguish between two types of edges:
undirected edges and directed edges. Let's create examples of both types:

    ue1 = UndirectedEdge(v1, v2)
    de1 = DirectedEdge(v1, v2)

Both undirected and directed edges have several associated items:

    ends(ue1)
    label(ue1)
    weight(ue1)
    attributes(ue1)

Because directed edges have a well-defined direction, you can access the
outgoing and ingoing vertices individualy:

    ends(ue1)
    out(de1)
    in(de1)
    label(de1)
    weight(de1)
    attributes(de1)

You can also confirm for yourself that undirected edges really do not
have direction, while directed edges do:

    e1 = UndirectedEdge(v1, v2)
    rev_e1 = UndirectedEdge(v2, v1)
    isequal(e1, rev_e1)

    e1 = DirectedEdge(v1, v2)
    rev_e1 = DirectedEdge(v2, v1)
    isequal(e1, rev_e1)

Again, we'll put edges together into an edge set:

    edge_set = Set(e1)

From there we can construct a directed graph:

    g = DirectedGraph(vertex_set, edge_set)

Often we'll want to do this using several other input types. For example,
we can construct a directed graph using a matrix of labels:

    m = ["a" "b";
         "a" "c";
         "b" "c";]

    g = DirectedGraph(m)

Alternatively, we can use a more mathematical style of notation:

    V = {1, 2, 3, 4, 5, 6}
    E = {{1, 2}, {1, 5}, {2, 3}, {2, 5}, {3, 4}, {4, 5}, {4, 6}}

    g = UndirectedGraph(V, E)
    g = DirectedGraph(V, E)

If we distinguish between curly braces and round braces, we use a more
generic `Graph` constructor to construct undirected and directed graphs
using a single form of notation:

    V = {1, 2, 3, 4, 5, 6}
    E = {{1, 2}, {1, 5}, {2, 3}, {2, 5}, {3, 4}, {4, 5}, {4, 6}}
    g = Graph(V, E)

    V = {1, 2, 3, 4, 5, 6}
    E = {(1, 2), (1, 5), (2, 3), (2, 5), (3, 4), (4, 5), (4, 6)}
    g = Graph(V, E)

Sometimes we have an adjacency matrix instead. We can also use that
to construct a graph:

    A = [1 0 0; 0 0 1; 0 0 1]
    g = DirectedGraph(A)

If the adjacency matrix is not symmetric, we cannot construct an
undirected graph from it:

    g = UndirectedGraph(A)

But if it is symmetric, we can:

    A = [0 1 0; 1 0 0; 0 0 0]
    g = UndirectedGraph(A)

Once we have a graph, we can several important matrix representations of it:

    degree_matrix(g)

    adjacency_matrix(g)

    laplacian(g)

    incidence_matrix(g)
