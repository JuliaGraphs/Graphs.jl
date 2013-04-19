# Testing of the graph types

using Graphs
using Base.Test

#################################################
#
#  SimpleDirectedGraph
#
#################################################

sgd = simple_graph(4)

@test is_directed(sgd) == true
@test num_vertices(sgd) == 4
@test num_edges(sgd) == 0

for u = 1 : 4
    @test out_degree(u, sgd) == 0
    @test isempty(out_neighbors(u, sgd))
    @test isempty(out_edges(u, sgd))
end

es = [  add_edge!(sgd, 1, 2)
        add_edge!(sgd, 1, 3)
        add_edge!(sgd, 2, 4)
        add_edge!(sgd, 3, 4) ]

@test num_edges(sgd) == 4

@test out_degree(1, sgd) == 2
@test out_degree(2, sgd) == 1
@test out_degree(3, sgd) == 1
@test out_degree(4, sgd) == 0

@test out_edges(1, sgd) == es[1:2]
@test out_edges(2, sgd) == [es[3]]
@test out_edges(3, sgd) == [es[4]]
@test isempty(out_edges(4, sgd))

@test out_neighbors(1, sgd) == [2, 3]
@test out_neighbors(2, sgd) == [4]
@test out_neighbors(3, sgd) == [4]
@test isempty(out_neighbors(4, sgd))


#################################################
#
#  SimpleUndirectedGraph
#
#################################################

sgu = simple_graph(4, is_directed=false)

@test is_directed(sgu) == false
@test num_vertices(sgu) == 4
@test num_edges(sgu) == 0

for u = 1 : 4
    @test out_degree(u, sgu) == 0
    @test isempty(out_neighbors(u, sgu))
    @test isempty(out_edges(u, sgu))
end

add_edge!(sgu, 1, 2)
add_edge!(sgu, 1, 3)
add_edge!(sgu, 2, 4)
add_edge!(sgu, 3, 4) 
add_edge!(sgu, 4, 1)

es = sgu.edges
rs = [revedge(e) for e in es]

@test num_edges(sgu) == 5

@test out_degree(1, sgu) == 3
@test out_degree(2, sgu) == 2
@test out_degree(3, sgu) == 2
@test out_degree(4, sgu) == 3

@test out_neighbors(1, sgu) == [2, 3, 4]
@test out_neighbors(2, sgu) == [1, 4]
@test out_neighbors(3, sgu) == [1, 4]
@test out_neighbors(4, sgu) == [2, 3, 1]

@test out_edges(1, sgu) == [es[1], es[2], rs[5]]
@test out_edges(2, sgu) == [rs[1], es[3]]
@test out_edges(3, sgu) == [rs[2], es[4]]
@test out_edges(4, sgu) == [rs[3], rs[4], es[5]]


#################################################
#
#  Extended directed graph
#
#################################################

egd = graph(ExVertex, ExEdge{ExVertex})
@test is_directed(egd) == true

names = ["a", "b", "c", "d"]

for i = 1 : length(names)
    v = add_vertex!(egd, names[i])
    @test vertex_index(v) == i
end

@test num_vertices(egd) == 4
@test num_edges(egd) == 0

vs = egd.vertices

add_edge!(egd, vs[1], vs[2])
add_edge!(egd, vs[1], vs[3])
add_edge!(egd, vs[2], vs[4])
add_edge!(egd, vs[3], vs[4])

es = egd.edges

@test num_edges(egd) == 4

@test out_degree(1, egd) == 2
@test out_degree(2, egd) == 1
@test out_degree(3, egd) == 1
@test out_degree(4, egd) == 0

@test out_edges(1, egd) == es[1:2]
@test out_edges(2, egd) == [es[3]]
@test out_edges(3, egd) == [es[4]]
@test isempty(out_edges(4, egd))

@test out_neighbors(1, egd) == [vs[2], vs[3]]
@test out_neighbors(2, egd) == [vs[4]]
@test out_neighbors(3, egd) == [vs[4]]
@test isempty(out_neighbors(4, egd))


#################################################
#
#  Extended undirected graph
#
#################################################

egu = graph(ExVertex, ExEdge{ExVertex}, is_directed=false)
@test is_directed(egu) == false

names = ["a", "b", "c", "d"]

for i = 1 : length(names)
    v = add_vertex!(egu, names[i])
    @test vertex_index(v) == i
end

@test num_vertices(egu) == 4
@test num_edges(egu) == 0

vs = vertices(egu)

add_edge!(egu, vs[1], vs[2])
add_edge!(egu, vs[1], vs[3])
add_edge!(egu, vs[2], vs[4])
add_edge!(egu, vs[3], vs[4])
add_edge!(egu, vs[4], vs[1])

es = egu.edges
rs = [revedge(e) for e in es]

@test num_edges(egu) == 5

@test out_degree(1, egu) == 3
@test out_degree(2, egu) == 2
@test out_degree(3, egu) == 2
@test out_degree(4, egu) == 3

@test out_neighbors(1, egu) == vs[[2, 3, 4]]
@test out_neighbors(2, egu) == vs[[1, 4]]
@test out_neighbors(3, egu) == vs[[1, 4]]
@test out_neighbors(4, egu) == vs[[2, 3, 1]]

