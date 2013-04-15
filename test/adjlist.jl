# Tests of Adjacency List types

using Graphs
using Base.Test

gd = directed_adjacency_list(3)
gu = undirected_adjacency_list(3)

# concept test

@test implements_vertex_list(gd)    == true
@test implements_edge_list(gd)      == false
@test implements_vertex_map(gd)     == true
@test implements_edge_map(gd)       == false

@test implements_adjacency_list(gd) == true
@test implements_incidence_list(gd) == false
@test implements_bidirectional_adjacency_list(gd) == false
@test implements_bidirectional_incidence_list(gd) == false
@test implements_adjacency_matrix(gd) == false

# graph without edges

@test vertex_type(gd) == Int
@test edge_type(gd) == Edge{Int}

@test num_vertices(gd) == 3
@test num_edges(gd) == 0
@test vertices(gd) == 1:3
@test is_directed(gd) == true

@test num_vertices(gu) == 3
@test num_edges(gu) == 0
@test vertices(gu) == 1:3
@test is_directed(gu) == false

for i = 1 : 3
    @test out_degree(i, gd) == 0
    @test isempty(out_neighbors(i, gd))
    @test out_degree(i, gu) == 0
    @test isempty(out_neighbors(i, gu))
end

# graph with edges

add_edge!(gd, 1, 2)
add_edge!(gd, 1, 3)
add_edge!(gd, 2, 3)

@test num_edges(gd) == 3

nbs = {[2, 3], [3], Int[]}
for i = 1 : 3
    @test out_degree(i, gd) == length(nbs[i])
    @test out_neighbors(i, gd) == nbs[i]
end

add_edge!(gu, 1, 2)
add_edge!(gu, 2, 3)

@test num_edges(gu) == 2

nbs = {[2], [1, 3], [2]}
for i = 1 : 3
    @test out_degree(i, gu) == length(nbs[i])
    @test out_neighbors(i, gu) == nbs[i]
end

# another constructor

g = directed_adjacency_list([2, 3], [3], [2], Int[])

@test num_vertices(g) == 4
@test num_edges(g) == 4

@test is_directed(g) == true
nbs = {[2, 3], [3], [2], Int[]}
for i = 1 : 3
    @test out_degree(i, g) == length(nbs[i])
    @test out_neighbors(i, g) == nbs[i]
end


