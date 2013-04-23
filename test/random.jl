using Graphs
using Base.Test

# Test the random graph generation
# We're just running the functions, no testing that the graphs
# actually have the characteristics that they are supposed to have.

n = 10
p = 0.2
g = erdos_renyi_graph(n,p)
# A graph should have n vertices
@test length(vertices(g)) == n
p = 1
g = erdos_renyi_graph(n,p)
# When p = 1, the graph should be complete.
@test length(edges(g)) == sum(1:n-1)

#Setting an attribute should not break things
n = 10
p = 0.2
g = erdos_renyi_graph(n,p)
edge = collect(edges(g))[1]
vertex = collect(ends(edge))[1]
attrs = attributes(vertex)
@test contains(vertices(g), vertex)
attrs["color"] = "red"
@test contains(vertices(g), vertex)

n = 400
k = 10
p = 0.1
g = watts_strogatz_graph(n,k,p)
@test length(edges(g)) == n*k/2
@test length(vertices(g)) == n

edge = collect(edges(g))[1]
vertex = collect(ends(edge))[1]
attrs = attributes(vertex)
@test contains(vertices(g), vertex)
attrs["color"] = "red"
@test contains(vertices(g), vertex)
