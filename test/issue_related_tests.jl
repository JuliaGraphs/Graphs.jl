# issue related tests

using Graphs
using Test



g = graph([1, 3], [])  ## Create a graph with 2 vertices and no edges
e = Edge(1, 4, 2)
try
add_edge!(g, 2, 4)
catch
end
try
add_edge!(g, e)
catch
end
@test length(edges(g))==0
