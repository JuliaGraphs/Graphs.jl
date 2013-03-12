# Tests of Adjacency List types

using Graphs
using Test

gd = SimpleAdjacencyList(3)
gu = SimpleAdjacencyList(3, false)

@test num_vertices(gd) == 3
@test vertices(gd) == 1:3
@test is_directed(gd) == true

@test num_vertices(gu) == 3
@test vertices(gu) == 1:3
@test is_directed(gu) == false

for i = 1 : 3
    @test out_degree(i, gd) == 0
    @test isempty(out_neighbors(i, gd))
    @test out_degree(i, gu) == 0
    @test isempty(out_neighbors(i, gu))
end

add_edge!(gd, (1, 2))
add_edge!(gd, (1, 3))
add_edge!(gd, (2, 3))

nbs = {[2, 3], [3], Int[]}
for i = 1 : 3
    @test out_degree(i, gd) == length(nbs[i])
    @test out_neighbors(i, gd) == nbs[i]
end


add_edge!(gu, (1, 2))
add_edge!(gu, (2, 3))

nbs = {[2], [1, 3], [2]}
for i = 1 : 3
    @test out_degree(i, gu) == length(nbs[i])
    @test out_neighbors(i, gu) == nbs[i]
end

