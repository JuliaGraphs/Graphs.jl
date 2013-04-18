# Test of connected components

using Graphs
using Base.Test

g = simple_adjlist(8, is_directed=false)

edges = [(1, 2), (1, 3), (2, 4), (3, 4), (5, 6), (6, 7), (7, 5)]

for i = 1 : length(edges)
    e = edges[i]
    add_edge!(g, e[1], e[2])
end

ccs = connected_components(g)

@test length(ccs) == 3

@test ccs[1] == [1, 2, 3, 4]
@test ccs[2] == [5, 6, 7]
@test ccs[3] == [8]
