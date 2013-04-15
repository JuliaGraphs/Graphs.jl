# Test the random graph generation
# We're just running the functions, no testing that the graphs
# actually have the characteristics that they are supposed to have.

n = 10
p = 0.2
g = erdos_renyi_graph(n,p)
@assert length(vertices(g)) == n
p = 1
g = erdos_renyi_graph(n,p)
@assert length(edges(g)) == sum(1:n-1)

n = 400
k = 10
p = 0.1
g = watts_strogatz_graph(n,k,p)
@assert length(edges(g)) == n*k/2
@assert length(vertices(g)) == n