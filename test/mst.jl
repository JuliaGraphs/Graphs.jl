# Test of minimum spanning tree algorithms

using Graphs
using Base.Test

g = undirected_incidence_list(7)

wedges = [
    (1, 2, 7.),
    (2, 3, 8.),
    (1, 4, 5.),
    (2, 4, 9.),
    (2, 5, 7.),
    (3, 5, 3.),
    (4, 5, 15.),
    (4, 6, 6.),
    (5, 6, 8.),
    (5, 7, 9.),
    (6, 7, 11.) ]

m = length(wedges)
eweights = zeros(m)    
    
for i = 1 : m
    we = wedges[i]
    add_edge!(g, we[1], we[2])
    eweights[i] = we[3]
end

@assert num_vertices(g) == 7
@assert num_edges(g) == m

r = prim_minimum_spantree(g, eweights, 1)
@test length(r) == 6

@test r[1] == (Edge(3, 1, 4), 5.)
@test r[2] == (Edge(8, 4, 6), 6.)
@test r[3] == (Edge(1, 1, 2), 7.)
@test r[4] == (Edge(5, 2, 5), 7.)
@test r[5] == (Edge(6, 5, 3), 3.)
@test r[6] == (Edge(10, 5, 7), 9.)
