# Test the show functions on different kinds of graphs

using Graphs

adjlst = simple_adjlist(3)
add_edge!(adjlst, 1, 2)
add_edge!(adjlst, 1, 3)
add_edge!(adjlst, 2, 3)

println("simple_adjlist")
println("====================")
println(adjlst)
println()

inclst = simple_inclist(4, is_directed=false)
add_edge!(inclst, 1, 2)
add_edge!(inclst, 1, 3)
add_edge!(inclst, 2, 4)
add_edge!(inclst, 3, 4)

println("simple_inclist")
println("====================")
println(inclst)
println()

sg = simple_graph(4)
add_edge!(sg, 1, 2)
add_edge!(sg, 1, 3)
add_edge!(sg, 2, 4)
add_edge!(sg, 3, 4)

println("simple_graph")
println("====================")
println(sg)
println()

eg = graph(ExVertex, ExEdge{ExVertex})
v1 = add_vertex!(eg, "a")
v2 = add_vertex!(eg, "b")
v3 = add_vertex!(eg, "c")
add_edge!(eg, v1, v2)
add_edge!(eg, v1, v3)
add_edge!(eg, v2, v3)

println("extended_graph")
println("====================")
println(eg)
println()
