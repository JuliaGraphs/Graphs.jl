# Test of connected components

using Graphs
using Test

global g = simple_adjlist(8, is_directed=false)

global eds = [(1, 2), (1, 3), (2, 4), (3, 4), (5, 6), (6, 7), (7, 5)]

for i = 1 : length(eds)
    ee = eds[i]
    add_edge!(g, ee[1], ee[2])
end

global ccs = connected_components(g)

@test length(ccs) == 3

@test ccs[1] == [1, 2, 3, 4]
@test ccs[2] == [5, 6, 7]
@test ccs[3] == [8]

###########################################################
#
#   Connected components of directed graph
#
##########################################################

# test 1
global eds = [(1, 2), (2, 3), (3, 1), (4, 1)]
global g = simple_graph(4)

for (u, vv) in eds
    add_edge!(g, u, vv)
end

scc = strongly_connected_components(g)
@test length(scc) == 2
@test scc[1] == [1, 2, 3]
@test scc[2] == [4]

# test 2, from Vazirani's notes
# (http://www.cs.berkeley.edu/~vazirani/s99cs170/notes/lec12.pdf)

eds = [(1, 2), (2, 3), (2, 4), (2, 5), (3, 6),
       (4, 5), (4, 7), (5, 2), (5, 6), (5, 7),
       (6, 3), (6, 8), (7, 8), (7, 10), (8, 7),
       (9, 7), (10, 9), (10, 11), (11, 12), (12, 10)]
g = simple_graph(12)

for (u, v) in eds
    add_edge!(g, u, v)
end

scc = strongly_connected_components(g)
@test length(scc) == 4
@test scc[1] == [8, 7, 10, 9, 11, 12]
@test scc[2] == [3, 6]
@test scc[3] == [2, 4, 5]
@test scc[4] == [1]
