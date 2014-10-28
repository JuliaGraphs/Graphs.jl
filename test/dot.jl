using Graphs
using Base.Test

function has_match(regex, str)
    !isa(match(regex, str), Nothing)
end

function xor(a, b)
    (a || b) && !(a && b)
end

# Vertex attributes get layed out correctly
let g=inclist(ExVertex, is_directed=false)
    add_vertex!(g, ExVertex(1, "label1"))
    add_vertex!(g, ExVertex(2, "label2"))
    add_edge!(g, vertices(g)[1], vertices(g)[2])
    attrs = attributes(vertices(g)[1], g)

    @test to_dot(attrs) == ""

    attrs["foo"] = "bar"
    @test to_dot(attrs) == "[\"foo\"=\"bar\"]"

    attrs["baz"] = "qux"
    # Below here we do some messing around so as not to assert on dict iteration order.

    @test to_dot(attrs) in ["[\"foo\"=\"bar\",\"baz\"=\"qux\"]",
                            "[\"baz\"=\"qux\",\"foo\"=\"bar\"]"]

    sp = split(to_dot(g), "\n")
    @test ("1 [\"foo\"=\"bar\",\"baz\"=\"qux\"]" in sp) ||
          ("1 [\"baz\"=\"qux\",\"foo\"=\"bar\"]" in sp)
end

# Edge attributes get layed out correctly
let
    g = inclist(ExVertex, ExEdge{ExVertex}, is_directed=false)
    add_vertex!(g, ExVertex(1, "label1"))
    add_vertex!(g, ExVertex(2, "label2"))

    add_edge!(g, vertices(g)[1], vertices(g)[2])

    e = out_edges(vertices(g)[2], g)[1]

    attrs = attributes(e, g)
    attrs["foo"] = "bar"
    @test to_dot(attrs) == "[\"foo\"=\"bar\"]"

    attrs["baz"] = "qux"

    sp = split(to_dot(g), "\n")
    @test ("1 -- 2 [\"foo\"=\"bar\",\"baz\"=\"qux\"]" in sp) ||
          ("1 -- 2 [\"baz\"=\"qux\",\"foo\"=\"bar\"]" in sp)
end

let g=simple_graph(0, is_directed=false)
    @test to_dot(g) == "graph graphname {\n}\n"
end

let g=simple_graph(0, is_directed=true)
    @test to_dot(g) == "digraph graphname {\n}\n"
end

let g=simple_adjlist(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 2)
    str = to_dot(g)
    @test has_match(r"1 -> 2", str)
    @test has_match(r"1 -> 3", str)
    @test has_match(r"2 -> 3", str)
    @test has_match(r"3 -> 2", str)
    @test !has_match(r"--", str)
end

let g=simple_adjlist(3, is_directed=false)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 2, 3)
    str = to_dot(g)
    @test xor(has_match(r"1 -- 2", str), has_match(r"2 -- 1", str))
    @test xor(has_match(r"1 -- 3", str), has_match(r"3 -- 1", str))
    @test xor(has_match(r"2 -- 3", str), has_match(r"3 -- 2", str))
    @test !has_match(r"->", str)
end
