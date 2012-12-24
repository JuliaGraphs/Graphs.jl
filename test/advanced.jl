##############################################################################
#
# Undirected Graphs
#
##############################################################################

v1 = Vertex(1, "A")
v2 = Vertex(2, "B")

e1 = DirectedEdge(v1, v2)

g = DirectedGraph(Set(v1, v2), Set(e1))

@assert outdegree(v1, g) == 1
@assert indegree(v1, g) == 0
@assert outdegree(v2, g) == 0
@assert indegree(v2, g) == 1

@assert isequal(adjacency_matrix(g), [0 1; 0 0])

numeric_edges = [1 2;
                 1 3;
                 2 3;]
vertex_names = UTF8String["A", "B", "C"]

g1 = DirectedGraph(vertex_names, numeric_edges)

m = ["a" "b";
     "a" "c";
     "b" "c";]

g2 = DirectedGraph(m)

# TODO: Make this work
# @assert g1 == g2

##############################################################################
#
# Undirected Graphs
#
##############################################################################

v1 = Vertex(1, "A")
v2 = Vertex(2, "B")
v3 = Vertex(3, "C")

e1 = UndirectedEdge(v1, v2)
e2 = UndirectedEdge(v1, v3)
e3 = UndirectedEdge(v2, v3)

g = UndirectedGraph(Set(v1, v2, v3), Set(e1, e2, e3))

@assert degree(v1, g) == 2
@assert degree(v2, g) == 2
@assert degree(v3, g) == 2

@assert isequal(degrees(g), [2, 2, 2])
@assert isequal(degree_matrix(g), [2 0 0; 0 2 0; 0 0 2])
@assert isequal(adjacency_matrix(g), [0 1 1; 1 0 1; 1 1 0])
@assert isequal(laplacian(g), degree_matrix(g) - adjacency_matrix(g))
@assert isequal(laplacian(g), [2 -1 -1; -1 2 -1; -1 -1 2])
