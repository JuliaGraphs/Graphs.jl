# Tests of Incidence List

using Graphs
using Test

#################################################
#
#   DirectedIncidenceList
#
#################################################

g = directed_incidence_list(Edge{Int}, 5)

# concept test

@test implements_vertex_list(g)    == true
@test implements_edge_list(g)      == false
@test implements_adjacency_list(g) == true
@test implements_incidence_list(g) == true
@test implements_bidirectional_adjacency_list(g) == false
@test implements_bidirectional_incidence_list(g) == false
@test implements_adjacency_matrix(g) == false

# graph without edges

@test vertex_type(g) == Int
@test edge_type(g) == (Int, Int)

@test num_vertices(g) == 5
@test vertices(g) == 1:5
@test is_directed(g) == true

for i = 1 : 5
    @test out_degree(i, g) == 0
    @test isempty(out_edges(i, g))
    @test isempty(out_neighbors(i, g))
end

# graph with edges

add_edge!(g, Edge(1, 2))
add_edge!(g, Edge(2, 4))
add_edge!(g, Edge(1, 3))
add_edge!(g, Edge(3, 4))
add_edge!(g, Edge(2, 3))
add_edge!(g, Edge(4, 5))

@test out_degree(1, g) == 2
@test out_degree(2, g) == 2
@test out_degree(3, g) == 1
@test out_degree(4, g) == 1
@test out_degree(5, g) == 0

@test collect(out_edges(1, g)) == [Edge(1, 2), Edge(1, 3)]
@test collect(out_edges(2, g)) == [Edge(2, 4), Edge(2, 3)]
@test collect(out_edges(3, g)) == [Edge(3, 4)]
@test collect(out_edges(4, g)) == [Edge(4, 5)]
@test collect(out_edges(5, g)) == Array((Int, Int), 0)

@test collect(out_neighbors(1, g)) == [2, 3]
@test collect(out_neighbors(2, g)) == [4, 3]
@test collect(out_neighbors(3, g)) == [4]
@test collect(out_neighbors(4, g)) == [5]
@test collect(out_neighbors(5, g)) == Int[]
