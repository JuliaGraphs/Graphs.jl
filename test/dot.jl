using Graphs
using Base.Test

# Attributes get layed out correctly
#let v1 = Vertex(1)
#    attrs = attributes(v1)
#    @test to_dot(attrs) == ""
#
#    attrs["foo"] = "bar"
#    @test to_dot(attrs) == "[\"foo\"=\"bar\"]"
#    @test to_dot(v1) == "1 [\"foo\"=\"bar\"]\n"
#
#    attrs["baz"] = "qux"
#    @test contains(["[\"foo\"=\"bar\",\"baz\"=\"qux\"]",
#                      "[\"baz\"=\"qux\",\"foo\"=\"bar\"]"], to_dot(attrs))
#end

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
    str = to_dot(g)
    @test (match(r"1 -> 2", str) != Nothing)
    @test (match(r"1 -> 3", str) != Nothing)
    @test (match(r"2 -> 3", str) != Nothing)
end

# I don't know a clean way to make this work, as the dot output edge order changes with every run.
#let g=read_edgelist(joinpath("test", "data", "graph1.edgelist"))
#    f = open(joinpath("test","data","graph1.dot"))
#    str = readall(f)
#    close(f)
#    println(str)
#    println(to_dot(g))
#    @test to_dot(g) == str
#end