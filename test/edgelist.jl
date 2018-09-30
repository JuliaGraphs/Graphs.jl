# test edge lists

using Graphs
using Test

## simple edge list

edge_pairs = [(1,2), (1,3), (2,3), (2,4), (3,5), (4,5), (2,5)]
eds = Edge{Int}[Edge(i,p[1],p[2]) for (i,p) in enumerate(edge_pairs)]

gd = simple_edgelist(5, eds)
gu = simple_edgelist(5, eds; is_directed=false)

@test implements_vertex_list(gd)    == true
@test implements_edge_list(gd)      == true
@test implements_vertex_map(gd)     == true
@test implements_edge_map(gd)       == true

@test implements_adjacency_list(gd) == false
@test implements_incidence_list(gd) == false
@test implements_bidirectional_adjacency_list(gd) == false
@test implements_bidirectional_incidence_list(gd) == false
@test implements_adjacency_matrix(gd) == false

# test for gd

@test vertex_type(gd) == Int
@test edge_type(gd) == Edge{Int}
@test is_directed(gd)

@test num_vertices(gd) == 5
@test vertices(gd) == 1:5

@test num_edges(gd) == 7
@test edges(gd) === eds

# test for gu

@test vertex_type(gu) == Int
@test edge_type(gu) == Edge{Int}
@test !is_directed(gu)

@test num_vertices(gu) == 5
@test vertices(gu) == 1:5

@test num_edges(gu) == 7
@test edges(gu) === eds


## edge list (based on vector of vertices)

for T in [ ExVertex, String ]
    g = edgelist(T[], ExEdge{T}[])

    vs = [ add_vertex!(g, "a"),
           add_vertex!(g, "b"),
           add_vertex!(g, "c") ]

    es = [ add_edge!(g, vs[1], vs[2]),
           add_edge!(g, vs[1], vs[3]) ]

    @test vertex_type(g) == T
    @test edge_type(g) == ExEdge{T}
    @test is_directed(g)

    @test num_vertices(g) == 3
    @test vertices(g) == vs

    @test num_edges(g) == 2
    @test edges(g) == es
end
