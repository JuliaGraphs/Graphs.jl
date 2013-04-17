# Test the random graph generation
# We're just running the functions, no testing that the graphs
# actually have the characteristics that they are supposed to have.

n = 10
p = 0.2
g = erdos_renyi_graph(n,p)
# A graph should have n vertices
@assert length(vertices(g)) == n
p = 1
g = erdos_renyi_graph(n,p)
# When p = 1, the graph should be complete.
@assert length(edges(g)) == sum(1:n-1)

#Setting an attribute should not break things
n = 10
p = 0.2
g = erdos_renyi_graph(n,p)
edge = collect(edges(g))[1]
vertex = collect(ends(edge))[1]
attrs = attributes(vertex)
@assert contains(vertices(g), vertex)
attrs["color"] = "red"
@assert contains(vertices(g), vertex)

n = 400
k = 10
p = 0.1
g = watts_strogatz_graph(n,k,p)
@assert length(edges(g)) == n*k/2
@assert length(vertices(g)) == n

edge = collect(edges(g))[1]
vertex = collect(ends(edge))[1]
attrs = attributes(vertex)
@assert contains(vertices(g), vertex)
attrs["color"] = "red"
@assert contains(vertices(g), vertex)