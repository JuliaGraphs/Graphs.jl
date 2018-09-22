# Test of Min-Cut and maximum adjacency visit

using Graphs
using Test

global g = simple_inclist(8, is_directed=false)

# Original example by Stoer

global wedges = [
    (1, 2, 2.),
    (1, 5, 3.),
    (2, 3, 3.),
    (2, 5, 2.),
    (2, 6, 2.),
    (3, 4, 4.),
    (3, 7, 2.),
    (4, 7, 2.),
    (4, 8, 2.),
    (5, 6, 3.),
    (6, 7, 1.),
    (7, 8, 3.) ]


global m = length(wedges)
global eweights = zeros(m)

for i = 1 : m
    we = wedges[i]
    add_edge!(g, we[1], we[2])
    eweights[i] = we[3]
end



@assert num_vertices(g) == 8
@assert num_edges(g) == m

global (parity, bestcut) = min_cut(g, eweights)

@test length(parity) == 8
@test parity == Bool[ true, true, false, false, true, true, false, false ]
@test bestcut == 4.0

global (parity, bestcut) = min_cut(g)

@test length(parity) == 8
@test parity == Bool[ true, false, false, false, false, false, false, false ]
@test bestcut == 2.0

global vertices_n = maximum_adjacency_visit(g)

@test vertices_n == Int[1, 2, 5, 6, 3, 7, 4, 8]
