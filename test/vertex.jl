v1 = Vertex(1, "A")
v2 = Vertex(2, "B")

Set(v1, v2)

@assert isequal(id(v1), 1)
@assert isequal(label(v1), "A")
