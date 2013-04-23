using Graphs
using Base.Test

# Test the random graph generation
# We're just running the functions, no testing that the graphs
# actually have the characteristics that they are supposed to have.

n = 10
p = 0.2
g = erdos_renyi_graph(n,p, is_directed=false)
# A graph should have n vertices
@test num_vertices(g) == n
@test !is_directed(g)
p = 1
g = erdos_renyi_graph(n,p, is_directed=false)
# When p = 1, the graph should be complete.
@test num_edges(g) == sum(1:n-1)

p = 1
g = erdos_renyi_graph(n,p, is_directed=true)
# A graph should have n vertices
@test num_vertices(g) == n
@test is_directed(g)
# When p = 1, the graph should be complete.
@test num_edges(g) == 2*sum(1:n-1)