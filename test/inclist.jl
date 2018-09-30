# Tests of Incidence List

using Graphs
using Test

#################################################
#
#   Directed simple incidence list
#
#################################################

gd = simple_inclist(5)

# concept test

@test implements_vertex_list(gd)    == true
@test implements_edge_list(gd)      == false
@test implements_vertex_map(gd)     == true
@test implements_edge_map(gd)       == true

@test implements_adjacency_list(gd) == true
@test implements_incidence_list(gd) == true
@test implements_bidirectional_adjacency_list(gd) == false
@test implements_bidirectional_incidence_list(gd) == false
@test implements_adjacency_matrix(gd) == false

# graph without edges

@test vertex_type(gd) == Int
@test edge_type(gd) == Edge{Int}

@test num_vertices(gd) == 5
@test num_edges(gd) == 0
@test vertices(gd) == 1:5
@test is_directed(gd) == true

for i = 1 : 5
    @test out_degree(i, gd) == 0
    @test isempty(out_edges(i, gd))
    @test isempty(out_neighbors(i, gd))
end

# graph with edges

add_edge!(gd, 1, 2)
add_edge!(gd, 2, 4)
add_edge!(gd, 1, 3)
add_edge!(gd, 3, 4)
add_edge!(gd, 2, 3)
add_edge!(gd, 4, 5)

@test num_edges(gd) == 6

@test out_degree(1, gd) == 2
@test out_degree(2, gd) == 2
@test out_degree(3, gd) == 1
@test out_degree(4, gd) == 1
@test out_degree(5, gd) == 0

@test collect(out_edges(1, gd)) == [Edge(1, 1, 2), Edge(3, 1, 3)]
@test collect(out_edges(2, gd)) == [Edge(2, 2, 4), Edge(5, 2, 3)]
@test collect(out_edges(3, gd)) == [Edge(4, 3, 4)]
@test collect(out_edges(4, gd)) == [Edge(6, 4, 5)]
@test collect(out_edges(5, gd)) == Array{Tuple{Int, Int}}(undef, 0)

# import Graphs: iterate
# iter_state = iterate(out_neighbors(1, gd))
# iter_state = iterate(out_neighbors(1, gd), (2, 1))
# iter_state = iterate(out_neigh

@test collect(out_neighbors(1, gd)) == [2, 3]
@test collect(out_neighbors(2, gd)) == [4, 3]
@test collect(out_neighbors(3, gd)) == [4]
@test collect(out_neighbors(4, gd)) == [5]
@test collect(out_neighbors(5, gd)) == Int[]

@test collect_edges(gd) == [Edge(1,1,2), Edge(3,1,3), Edge(2,2,4), Edge(5,2,3), Edge(4,3,4), Edge(6,4,5)]

target_it = out_neighbors(1, gd)
@test !isempty(target_it)
@test length(target_it) == 2
@test target_it[1] == 2
@test target_it[2] == 3


#################################################
#
#   Undirected simple incidence list
#
#################################################

global gu = simple_inclist(5, is_directed=false)

# graph without edges

@test vertex_type(gu) == Int
@test edge_type(gu) == Edge{Int}

@test num_vertices(gu) == 5
@test num_edges(gu) == 0
@test vertices(gu) == 1:5
@test is_directed(gu) == false

for i = 1 : 5
    @test out_degree(i, gu) == 0
    @test isempty(out_edges(i, gu))
    @test isempty(out_neighbors(i, gu))
end

# graph with edges

add_edge!(gu, 1, 2)
add_edge!(gu, 2, 3)
add_edge!(gu, 3, 1)
add_edge!(gu, 2, 4)
add_edge!(gu, 3, 4)
add_edge!(gu, 4, 5)

@test num_edges(gu) == 6

@test out_degree(1, gu) == 2
@test out_degree(2, gu) == 3
@test out_degree(3, gu) == 3
@test out_degree(4, gu) == 3
@test out_degree(5, gu) == 1

@test collect(out_edges(1, gu)) == [Edge(1, 1, 2), Edge(3, 1, 3)]
@test collect(out_edges(2, gu)) == [Edge(1, 2, 1), Edge(2, 2, 3), Edge(4, 2, 4)]
@test collect(out_edges(3, gu)) == [Edge(2, 3, 2), Edge(3, 3, 1), Edge(5, 3, 4)]
@test collect(out_edges(4, gu)) == [Edge(4, 4, 2), Edge(5, 4, 3), Edge(6, 4, 5)]
@test collect(out_edges(5, gu)) == [Edge(6, 5, 4)]


#################################################
#
#   normal list
#
#################################################
global g
g = let g = g
    for g in [inclist(KeyVertex{String}), inclist(String)]

        global vs = [ add_vertex!(g, "a"), add_vertex!(g, "b"), add_vertex!(g, "c") ]

        @test num_vertices(g) == 3

        for i = 1 : 3
            @test vertices(g)[i] == vs[i]
            @test out_degree(vs[i], g) == 0
        end

        add_edge!(g, vs[1], vs[2])
        add_edge!(g, vs[1], vs[3])
        add_edge!(g, vs[2], vs[3])

        @test out_degree(vs[1], g) == 2
        @test out_degree(vs[2], g) == 1
        @test out_degree(vs[3], g) == 0

        @test out_edges(vs[1], g) == [Edge(1, vs[1], vs[2]), Edge(2, vs[1], vs[3])]
        @test out_edges(vs[2], g) == [Edge(3, vs[2], vs[3])]
        @test isempty(out_edges(vs[3], g))
    end
end

let
    global g = inclist(ExVertex, ExEdge{ExVertex}; is_directed=false)

    global vs = [ add_vertex!(g, ExVertex(1,"a")),
                  add_vertex!(g, ExVertex(2,"b")),
                  add_vertex!(g, ExVertex(3,"c")) ]

    @test num_vertices(g) == 3

    for i = 1 : 3
        @test vertices(g)[i] == vs[i]
        @test out_degree(vs[i], g) == 0
    end

    add_edge!(g, vs[1], vs[2])
    add_edge!(g, vs[1], vs[3])
    add_edge!(g, vs[2], vs[3])

    @test out_degree(vs[1], g) == 2
    @test out_degree(vs[2], g) == 2
    @test out_degree(vs[3], g) == 2

    e1 = out_edges(vs[1], g)[1]
    @test source(e1, g) == vs[1]
    @test target(e1, g) == vs[2]

    e2 = out_edges(vs[2], g)[1]
    @test source(e2, g) == vs[2]
    @test target(e2, g) == vs[1]

    @test edge_index(e1, g) == edge_index(e2, g)
end
