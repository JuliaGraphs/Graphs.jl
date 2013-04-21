# Test of Depth-first visit

using Graphs
using Base.Test

g = simple_adjlist(6)

add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
add_edge!(g, 1, 6)
add_edge!(g, 2, 4)
add_edge!(g, 2, 5)
add_edge!(g, 3, 5)
add_edge!(g, 3, 6)

g2 = simple_adjlist(6)

add_edge!(g2, 1, 2)
add_edge!(g2, 1, 3)
add_edge!(g2, 1, 6)
add_edge!(g2, 2, 4)
add_edge!(g2, 2, 5)
add_edge!(g2, 3, 5)
add_edge!(g2, 3, 6)
add_edge!(g2, 5, 1)

# DFS traversal

vs1 = visited_vertices(g, DepthFirst(), 1)
@assert vs1 == [1, 2, 4, 5, 3, 6]

vs2 = visited_vertices(g2, DepthFirst(), 1)
@assert vs2 == [1, 2, 4, 5, 3, 6]

# Cyclic test

@assert test_cyclic_by_dfs(g) == false
@assert test_cyclic_by_dfs(g2) == true

# Topological sort

ts = topological_sort_by_dfs(g)
@assert ts == [1, 3, 6, 2, 5, 4]

@test_fails topological_sort_by_dfs(g2)  # g2 contains a loop
