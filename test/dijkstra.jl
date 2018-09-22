# Test of Dijkstra's algorithm for shorest paths

using Graphs
using Test

# g1: the example in CLRS (2nd Ed.)
global g1 = simple_inclist(5)

global g1_wedges = [
    (1, 2, 10.),
    (1, 3, 5.),
    (2, 3, 2.),
    (3, 2, 3.),
    (2, 4, 1.),
    (3, 5, 2.),
    (4, 5, 4.),
    (5, 4, 6.),
    (5, 1, 7.),
    (3, 4, 9.) ]

global ne = length(g1_wedges)
global eweights1 = zeros(ne)
for i = 1 : ne
    we = g1_wedges[i]
    add_edge!(g1, we[1], we[2])
    eweights1[i] = we[3]
end

@assert num_vertices(g1) == 5
@assert num_edges(g1) == 10

global s1 = dijkstra_shortest_paths(g1, eweights1, 1)

@test s1.parents == [1, 3, 1, 2, 3]
@test s1.dists == [0., 8., 5., 9., 7.]
@test s1.colormap == [2, 2, 2, 2, 2]

global s1 = dijkstra_shortest_paths(g1, eweights1, [1])

@test s1.parents == [1, 3, 1, 2, 3]
@test s1.dists == [0., 8., 5., 9., 7.]
@test s1.colormap == [2, 2, 2, 2, 2]


global g1ex = graph([i for i in 1:5], ExEdge{Int}[], is_directed=true)

#todo -- this should be doable in a comprehension, I can't get the types to work
for (i,vv) in enumerate(g1_wedges)
    ed = ExEdge(i, vv[1], vv[2])
    ed.attributes["length"] = vv[3]
    add_edge!(g1ex, ed)
end

global edgel = AttributeEdgePropertyInspector{Float64}("length")
global s1ex = dijkstra_shortest_paths(g1ex, edgel, [1])

@test s1ex.parents == [1, 3, 1, 2, 3]
@test s1ex.dists == [0., 8., 5., 9., 7.]
@test s1ex.colormap == [2, 2, 2, 2, 2]

# Check early termination

mutable struct EndWhenNode <: AbstractDijkstraVisitor
  n::Int
end

function Graphs.include_vertex!(visitor::EndWhenNode, u, v, d)
  v != visitor.n
end

global s1b = dijkstra_shortest_paths(g1, eweights1, [1], visitor=EndWhenNode(5))

@test s1b.parents == [1, 3, 1, 3, 3]
@test s1b.dists == [0.0, 8.0, 5.0, 14.0, 7.0]
@test s1b.colormap == [2, 1, 2, 1, 2]

# g2: the example in Wikipedia
global g2 = simple_inclist(6, is_directed=false)

global g2_wedges = [
    (5, 6, 9.),
    (5, 4, 6.),
    (6, 3, 2.),
    (4, 3, 11.),
    (6, 1, 14.),
    (3, 1, 9.),
    (3, 2, 10.),
    (4, 2, 15.),
    (1, 2, 7.) ]

global ne = length(g2_wedges)
global eweights2 = zeros(ne)
for i = 1 : ne
    we = g2_wedges[i]
    add_edge!(g2, we[1], we[2])
    eweights2[i] = we[3]
end

@assert num_vertices(g2) == 6
@assert num_edges(g2) == 9

global s2 = dijkstra_shortest_paths(g2, eweights2, 1)

@test s2.parents == [1, 1, 1, 3, 6, 3]
@test s2.dists == [0., 7., 9., 20., 20., 11.]
@test s2.colormap == [2, 2, 2, 2, 2, 2]

global s2 = dijkstra_shortest_paths(g2, eweights2, [1])

@test s2.parents == [1, 1, 1, 3, 6, 3]
@test s2.dists == [0., 7., 9., 20., 20., 11.]
@test s2.colormap == [2, 2, 2, 2, 2, 2]

global g3 = simple_graph(4)
add_edge!(g3,1,2); add_edge!(g3,1,3); add_edge!(g3,2,3); add_edge!(g3,3,4); add_edge!(g3,4,3); add_edge!(g3,3,1)

global s3 = dijkstra_shortest_paths(g3,2)
global sps = enumerate_paths(vertices(g3), s3.parent_indices)
@test length(sps) == 4
@test sps[1] == [2,3,1]
@test sps[2] == [2]
@test sps[3] == [2, 3]
@test sps[4] == [2, 3, 4]

global sps = enumerate_paths(vertices(g3), s3.parent_indices, [2,4])
@test length(sps) == 2
@test sps[1] == [2]
@test sps[2] == [2, 3, 4]

global sps = enumerate_paths(vertices(g3), s3.parent_indices, 4)
@test sps == [2, 3, 4]

global g4 = Graphs.inclist([4,5,6,7],is_directed=true)
add_edge!(g4,4,5); add_edge!(g4,4,6); add_edge!(g4,5,6); add_edge!(g4,6,7)

global s4 = dijkstra_shortest_paths(g4,5)
global sps = enumerate_indices(s4.parent_indices)
@test length(sps) == 4
@test sps[1] == []
@test sps[2] == [2]
@test sps[3] == [2, 3]
@test sps[4] == [2, 3, 4]

global sps = enumerate_indices(s4.parent_indices, [2,4])
@test length(sps) == 2
@test sps[1] == [2]
@test sps[2] == [2, 3, 4]

global sps = enumerate_indices(s4.parent_indices, 4)
@test sps == [2, 3, 4]

global sps = enumerate_paths(vertices(g4), s4.parent_indices)
@test length(sps) == 4
@test sps[1] == []
@test sps[2] == [5]
@test sps[3] == [5, 6]
@test sps[4] == [5, 6, 7]

global sps = enumerate_paths(vertices(g4), s4.parent_indices, [2,4])
@test length(sps) == 2
@test sps[1] == [5]
@test sps[2] == [5, 6, 7]

global sps = enumerate_paths(vertices(g4), s4.parent_indices, 4)
@test sps == [5, 6, 7]
