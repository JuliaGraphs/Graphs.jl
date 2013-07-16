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
    @test contains(["[\"foo\"=\"bar\",\"baz\"=\"qux\"]",
                      "[\"baz\"=\"qux\",\"foo\"=\"bar\"]"], to_dot(attrs))

    sp = split(to_dot(g), "\n")
    @test contains(sp, "1 [\"foo\"=\"bar\",\"baz\"=\"qux\"]") ||
          contains(sp, "1 [\"baz\"=\"qux\",\"foo\"=\"bar\"]")
end

typealias ExEIncidenceList{V} GenericIncidenceList{V, ExEdge{V}, Vector{V}, Vector{Vector{ExEdge{V}}}}
typealias G ExEIncidenceList{ExVertex}
function Graphs.add_vertex!(g::G, v::ExVertex)
    nv::Int = num_vertices(g)
    iv::Int = vertex_index(v)
    if iv != nv + 1
        throw(ArgumentError("Invalid vertex index."))
    end        
    
    push!(g.vertices, v)
    push!(g.inclist, Array(ExEdge,0))
    v
end
function Graphs.add_edge!{V}(g::G, u::V, v::V)
    nv::Int = num_vertices(g)
    ui::Int = vertex_index(u)
    vi::Int = vertex_index(v)
    
    if !(ui >= 1 && ui <= nv && vi >= 1 && vi <= nv)
        throw(ArgumentError("u or v is not a valid vertex."))
    end
    ei::Int = (g.nedges += 1)
    e = ExEdge{V}(ei, u, v)
    push!(g.inclist[ui], e)
    
    if !g.is_directed
        push!(g.inclist[vi], ExEdge{V}(ei, v, u, e.attributes))
    end
end
# Edge attributes get layed out correctly
let 
    g = G(false, Array(ExVertex, 0), 0, Array(Vector{ExEdge{ExVertex}},0))
    add_vertex!(g, ExVertex(1, "label1"))
    add_vertex!(g, ExVertex(2, "label2"))
    
    add_edge!(g, vertices(g)[1], vertices(g)[2])

    e = out_edges(vertices(g)[2], g)[1]

    attrs = attributes(e, g)
    attrs["foo"] = "bar"
    @test to_dot(attrs) == "[\"foo\"=\"bar\"]"

    attrs["baz"] = "qux"

    sp = split(to_dot(g), "\n")
    @test contains(sp, "1 -- 2 [\"foo\"=\"bar\",\"baz\"=\"qux\"]") ||
          contains(sp, "1 -- 2 [\"baz\"=\"qux\",\"foo\"=\"bar\"]")
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

# I don't know a clean way to make this work, as the dot output edge order changes with every run.
#let g=read_edgelist(joinpath("test", "data", "graph1.edgelist"))
#    f = open(joinpath("test","data","graph1.dot"))
#    str = readall(f)
#    close(f)
#    println(str)
#    println(to_dot(g))
#    @test to_dot(g) == str
#end