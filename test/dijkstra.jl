# Test of Dijkstra's algorithm for shorest paths

using Graphs
using Base.Test

# g1: the example in CLRS (2nd Ed.)
g1 = simple_inclist(5)

g1_wedges = [
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

ne = length(g1_wedges)
eweights1 = zeros(ne)
for i = 1 : ne
    we = g1_wedges[i]
    add_edge!(g1, we[1], we[2])
    eweights1[i] = we[3]
end

@assert num_vertices(g1) == 5
@assert num_edges(g1) == 10

s1 = dijkstra_shortest_paths(g1, eweights1, 1)

@test s1.parents == [1, 3, 1, 2, 3]
@test s1.dists == [0., 8., 5., 9., 7.]
@test s1.colormap == [2, 2, 2, 2, 2]

s1 = dijkstra_shortest_paths(g1, eweights1, [1])

@test s1.parents == [1, 3, 1, 2, 3]
@test s1.dists == [0., 8., 5., 9., 7.]
@test s1.colormap == [2, 2, 2, 2, 2]


g1ex = graph([i for i in 1:5], ExEdge{Int}[], is_directed=true)

#todo -- this should be doable in a comprehension, I can't get the types to work
for (i,v) in enumerate(g1_wedges)
    ed = ExEdge(i, v[1], v[2])
    ed.attributes["length"] = v[3]
    add_edge!(g1ex, ed)
end

edgel = AttributeEdgePropertyInspector{Float64}("length")
s1ex = dijkstra_shortest_paths(g1ex, edgel, [1])

@test s1ex.parents == [1, 3, 1, 2, 3]
@test s1ex.dists == [0., 8., 5., 9., 7.]
@test s1ex.colormap == [2, 2, 2, 2, 2]

# Check early termination

type EndWhenNode <: AbstractDijkstraVisitor
  n::Int
end

function Graphs.include_vertex!(visitor::EndWhenNode, u, v, d)
  v != visitor.n
end

s1b = dijkstra_shortest_paths(g1, eweights1, [1], visitor=EndWhenNode(5))

@test s1b.parents == [1, 3, 1, 3, 3]
@test s1b.dists == [0.0, 8.0, 5.0, 14.0, 7.0]
@test s1b.colormap == [2, 1, 2, 1, 2]

# g2: the example in Wikipedia
g2 = simple_inclist(6, is_directed=false)

g2_wedges = [
    (5, 6, 9.),
    (5, 4, 6.),
    (6, 3, 2.),
    (4, 3, 11.),
    (6, 1, 14.),
    (3, 1, 9.),
    (3, 2, 10.),
    (4, 2, 15.),
    (1, 2, 7.) ]

ne = length(g2_wedges)
eweights2 = zeros(ne)
for i = 1 : ne
    we = g2_wedges[i]
    add_edge!(g2, we[1], we[2])
    eweights2[i] = we[3]
end

@assert num_vertices(g2) == 6
@assert num_edges(g2) == 9

s2 = dijkstra_shortest_paths(g2, eweights2, 1)

@test s2.parents == [1, 1, 1, 3, 6, 3]
@test s2.dists == [0., 7., 9., 20., 20., 11.]
@test s2.colormap == [2, 2, 2, 2, 2, 2]

s2 = dijkstra_shortest_paths(g2, eweights2, [1])

@test s2.parents == [1, 1, 1, 3, 6, 3]
@test s2.dists == [0., 7., 9., 20., 20., 11.]
@test s2.colormap == [2, 2, 2, 2, 2, 2]

g3 = simple_graph(4)
add_edge!(g3,1,2); add_edge!(g3,1,3); add_edge!(g3,2,3); add_edge!(g3,3,4); add_edge!(g3,4,3); add_edge!(g3,3,1)
sps = dijkstra_shortest_paths_explicit(g3,2)
@test length(sps[1]) == 3
@test sps[4][2] == 3
