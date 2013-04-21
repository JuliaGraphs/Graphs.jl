# Tests of Adjacency List types

using Graphs
using Base.Test

gd = simple_adjlist(3)
gu = simple_adjlist(3; is_directed=false)

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

g = simple_adjlist({[2, 3], [3], [2], Int[]})

@test num_vertices(g) == 4
@test num_edges(g) == 4

@test is_directed(g) == true
nbs = {[2, 3], [3], [2], Int[]}
for i = 1 : 3
    @test out_degree(i, g) == length(nbs[i])
    @test out_neighbors(i, g) == nbs[i]
end

# adjacency list with key vertices

g = adjlist(KeyVertex{ASCIIString})

vs = [  add_vertex!(g, "a"), 
        add_vertex!(g, "b"), 
        add_vertex!(g, "c") ]

@test num_vertices(g) == 3

for i = 1 : 3
    v = vs[i]
    @test vertices(g)[i] == v
    @test v.index == i
    @test out_degree(v, g) == 0
end

add_edge!(g, vs[1], vs[2])
add_edge!(g, vs[1], vs[3])
add_edge!(g, vs[2], vs[3])

@test num_edges(g) == 3

@test out_degree(vs[1], g) == 2
@test out_degree(vs[2], g) == 1
@test out_degree(vs[3], g) == 0

@test out_neighbors(vs[1], g) == [vs[2], vs[3]]
@test out_neighbors(vs[2], g) == [vs[3]]
@test isempty(out_neighbors(vs[3], g))

