# Test of the A* algorithm for finding the shortest path between two vertices

using Graphs
using Test

# The "touring Romania" example from Russell and Norvig
global g1 = simple_inclist(20, is_directed=false)

global g1_wedges = [
    (1, 20, 75.),
    (1, 16, 140.), #2, Arad -- Sibiu
    (1, 17, 118.),
    (20, 13, 71.),
    (13, 16, 151.),
    (16, 6, 99.),
    (16, 15, 80.), #7, Sibiu -- Rimnicu Vilcea
    (6, 2, 211.),
    (17, 10, 111.),
    (10, 11, 70.),
    (11, 4, 75.),
    (4, 3, 120.),
    (3, 15, 146.),
    (3, 14, 138.),
    (15, 14, 97.), #15, Rimnicu Vilcea -- Pitesti
    (14, 2, 101.), #16, Pitesti -- Bucharest
    (2, 7, 90.),
    (2, 18, 85.),
    (18, 8, 98.),
    (8, 5, 86.),
    (18, 19, 142.),
    (19, 9, 92.),
    (9, 12, 87.) ]

global g1_heuristics = [
    366, 0, 160, 242, 161, 176, 77, 151, 226, 244, 241, 234, 380, 100, 193,
    253, 329, 80, 199, 374 ]

global ne = length(g1_wedges)
global eweights1 = zeros(ne)
for i = 1 : ne
    we = g1_wedges[i]
    add_edge!(g1, we[1], we[2])
    eweights1[i] = we[3]
end

global sp = shortest_path(g1, eweights1, 1, 2, n -> g1_heuristics[n])
global edge_numbers = map(e -> edge_index(e, g1), sp)
@test edge_numbers == [2, 7, 15, 16]
