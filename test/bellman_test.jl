# Test of Bellman Ford algorithm for shortest paths

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


s1 = bellman_ford_shortest_paths(g1, eweights1, [1])

@test s1.parents == [1, 3, 1, 2, 3]
@test s1.dists == [0., 8., 5., 9., 7.]
@test !has_negative_edge_cycle(g1, eweights1)

immutable MyEdge{V}
    index::Int
    source::V
    target::V
    dist::Float64
end
Graphs.target{V}(e::MyEdge{V}, g::AbstractGraph{V}) = e.target
Graphs.source{V}(e::MyEdge{V}, g::AbstractGraph{V}) = e.source
Graphs.edge_index(e::MyEdge) = e.index
g2 = inclist([i for i=1:10], MyEdge{Int})

for i = 2:10
    for j = 1:(i - 1)
        index = div((i-1)*(i-2), 2) + j
        weight = (i == j + 1) ? 1.0 : (i - j + 1.0)
        edge = MyEdge(index, j, i, weight)
        add_edge!(g2, edge)
    end
end

type MyEdgePropertyInspector{T} <: AbstractEdgePropertyInspector{T} end

Graphs.edge_property{T,V}(inspector::MyEdgePropertyInspector{T}, e::MyEdge, g::AbstractGraph{V}) = e.dist
insp =  MyEdgePropertyInspector{Float64}()
s2 = bellman_ford_shortest_paths(g2, insp, [1])
@test s2.dists == [i * 1.0 for i=0:9]
@test s2.parents == [i ==0 ? 1 : i for i = 0:9]
@test !has_negative_edge_cycle(g2, insp)
add_edge!(g2, MyEdge{Int}(46, 10, 1, -10.0))
@test has_negative_edge_cycle(g2, insp)
@test_throws NegativeCycleError bellman_ford_shortest_paths(g2, insp, [1])

# g1: the example in CLR[~S] (1st Ed. Figure 25.7)
g3 = simple_inclist(5)

g3_wedges = [
    (1, 2,  5.),
    (1, 3, -4.),
    (1, 4,  8.),
    (2, 1, -2.),
    (3, 2,  7.),
    (3, 5,  2.),
    (4, 2, -3.),
    (4, 3,  9.),
    (5, 4,  7.),
    (5, 1,  6.)]

ne3 = length(g3_wedges)
eweights3 = zeros(ne3)
for i = 1 : ne3
    we = g3_wedges[i]
    add_edge!(g3, we[1], we[2])
    eweights3[i] = we[3]
end

@assert num_vertices(g3) == 5
@assert num_edges(g3) == 10


s3 = bellman_ford_shortest_paths(g3, eweights3, [5])

@test s3.parents == [2, 4, 1, 5, 5]
@test s3.dists == [2.0, 4.0, -2.0, 7.0, 0.0]
@test !has_negative_edge_cycle(g3, eweights1)
