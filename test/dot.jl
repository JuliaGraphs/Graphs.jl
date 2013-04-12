
# A vertex with no attributes has a blank dot representation.
let v1 = Vertex(1)
  @assert to_dot(v1) == ""
end

# A directed edge with no attributes:
let e1 = DirectedEdge(1,2)
    @assert to_dot(e1) == "1 -> 2 \n"
end

# An undirected edge with no attributes:
let e1 = UndirectedEdge(1,2)
    @assert contains(["1 -- 2 \n","2 -- 1 \n"],to_dot(e1))
end

# Attributes get layed out correctly
# I'm assuming here that all the graph bits have the same sort of attributes
# No attributes are layed out for now.
let v1 = Vertex(1)
    attr_type = typeof(attributes(v1))
    attrs = attr_type()
    @assert to_dot(attrs) == ""

    attrs["foo"] = "bar"
    @assert to_dot(attrs) == "[\"foo\"=\"bar\"]"

    attrs["baz"] = "qux"
    @assert contains(["[\"foo\"=\"bar\",\"baz\"=\"qux\"]",
                      "[\"baz\"=\"qux\",\"foo\"=\"bar\"]"], to_dot(attrs))
end

let g=UndirectedGraph()
    @assert to_dot(g) == "graph graphname {\n}\n"
end

let g=DirectedGraph()
    @assert to_dot(g) == "digraph graphname {\n}\n"
end

# I don't know a clean way to make this work, as the dot output edge order changes with every run.
#let g=read_edgelist(joinpath("test", "data", "graph1.edgelist"))
#    f = open(joinpath("test","data","graph1.dot"))
#    str = readall(f)
#    close(f)
#    println(str)
#    println(to_dot(g))
#    @assert to_dot(g) == str
#end