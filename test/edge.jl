v1 = Vertex(1, "A")
v2 = Vertex(2, "B")

e1 = DirectedEdge(v1, v2)

@assert out(e1) == v1
@assert in(e1) == v2
@assert name(e1) == ""
@assert abs(weight(e1) - 1.0) < 10e-8
