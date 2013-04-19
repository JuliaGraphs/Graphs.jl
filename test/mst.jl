# Test of minimum spanning tree algorithms

using Graphs
using Base.Test

g = simple_inclist(7, is_directed=false)

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

function verify_redge(r, p, w)
    e = r.edge
    return e.source == p[1] && e.target == p[2] && r.weight == w
end

@test verify_redge(r[1], (1, 4), 5.)
@test verify_redge(r[2], (4, 6), 6.)
@test verify_redge(r[3], (1, 2), 7.)
@test verify_redge(r[4], (2, 5), 7.)
@test verify_redge(r[5], (5, 3), 3.)
@test verify_redge(r[6], (5, 7), 9.)

r = kruskal_minimum_spantree(g, eweights)

@test verify_redge(r[1], (3, 5), 3.)
@test verify_redge(r[2], (1, 4), 5.)
@test verify_redge(r[3], (4, 6), 6.)
@test verify_redge(r[4], (1, 2), 7.)
@test verify_redge(r[5], (2, 5), 7.)
@test verify_redge(r[6], (5, 7), 9.)
