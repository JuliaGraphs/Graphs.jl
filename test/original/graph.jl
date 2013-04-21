v1 = Vertex(1, "A")
v2 = Vertex(2, "B")

e1 = DirectedEdge(v1, v2)

g = DirectedGraph(Set(v1, v2), Set(e1))

numeric_edges = [1 2;
                 1 3;
                 2 3;]
vertex_labels = UTF8String["A", "B", "C"]

g1 = DirectedGraph(vertex_labels, numeric_edges)

m = ["a" "b";
     "a" "c";
     "b" "c";]

g2 = DirectedGraph(m)

# TODO: Make this work
# @assert g1 == g2

v1 = Vertex(1, "A")
v2 = Vertex(2, "B")

e1 = UndirectedEdge(v1, v2)

g1 = UndirectedGraph(Set(v1, v2), Set(e1))
