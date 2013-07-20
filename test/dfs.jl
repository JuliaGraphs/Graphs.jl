# Test of Depth-first visit

using Graphs
using Base.Test

acyclic = [(1,2) (1,3) (1,6) (2,4) (2,5) (3,5) (3,6)]
cyclic  = [(1,2) (1,3) (1,6) (2,4) (2,5) (3,5) (3,6) (5,1)]

g = simple_adjlist(6)
map((edg) -> add_edge!(g, edg[1], edg[2]), acyclic)

g2 = simple_adjlist(6)
map((edg) -> add_edge!(g2, edg[1], edg[2]), cyclic)


gEx = graph(ExVertex, ExEdge{ExVertex}, is_directed = true)
map((x) -> add_vertex!(gEx, "edge:" * string(x)), 1:6)
V = vertices(gEx)
map((edg) -> add_edge!(gEx, V[edg[1]], V[edg[2]]), acyclic)

gEx2 = graph(ExVertex, ExEdge{ExVertex}, is_directed = true)
map((x) -> add_vertex!(gEx2, "edge:" * string(x)), 1:6)
V2 = vertices(gEx2)
map((edg) -> add_edge!(gEx2, V2[edg[1]], V2[edg[2]]), cyclic)

# DFS traversal

vs1 = visited_vertices(g, DepthFirst(), 1)
@assert vs1 == [1, 2, 4, 5, 3, 6]

vs2 = visited_vertices(g2, DepthFirst(), 1)
@assert vs2 == [1, 2, 4, 5, 3, 6]

# Cyclic test

@assert test_cyclic_by_dfs(g) == false
@assert test_cyclic_by_dfs(g2) == true

# Cyclic test with Extended Graph types

@assert test_cyclic_by_dfs(gEx) == false
@assert test_cyclic_by_dfs(gEx2) == true

# Topological sort

ts = topological_sort_by_dfs(g)
@assert ts == [1, 3, 6, 2, 5, 4]

@test_throws topological_sort_by_dfs(g2)  # g2 contains a loop
