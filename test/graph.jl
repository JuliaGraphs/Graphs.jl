# Testing of the graph types

using Graphs
using Test


#################################################
#
#  SimpleDirectedGraph
#
#################################################

@testset "SimpleDirectedGraph" begin

global sgd = simple_graph(3)
add_vertex!(sgd)

# concept test

@testset "concept test" begin

@test implements_vertex_list(sgd)    == true
@test implements_edge_list(sgd)      == true
@test implements_vertex_map(sgd)     == true
@test implements_edge_map(sgd)       == true

@test implements_adjacency_list(sgd) == true
@test implements_incidence_list(sgd) == true
@test implements_bidirectional_adjacency_list(sgd) == true
@test implements_bidirectional_incidence_list(sgd) == true
@test implements_adjacency_matrix(sgd) == false

end

# properties

@testset "properties" begin

@test is_directed(sgd) == true
@test num_vertices(sgd) == 4
@test num_edges(sgd) == 0

for u = 1 : 4
    @test out_degree(u, sgd) == 0
    @test in_degree(u, sgd) == 0
    @test isempty(out_neighbors(u, sgd))
    @test isempty(out_edges(u, sgd))
    @test isempty(in_neighbors(u, sgd))
    @test isempty(in_edges(u, sgd))
end

@test collect_edges(sgd) == []

global es = [  add_edge!(sgd, 1, 2)
               add_edge!(sgd, 1, 3)
               add_edge!(sgd, 2, 4)
               add_edge!(sgd, 3, 4) ]

@test num_edges(sgd) == 4

end

# outgoing

@testset "outgoing" begin

@test [out_degree(v, sgd) for v = 1:4] == [2, 1, 1, 0]

@test out_edges(1, sgd) == es[1:2]
@test out_edges(2, sgd) == es[[3]]
@test out_edges(3, sgd) == es[[4]]
@test isempty(out_edges(4, sgd))

@test collect(out_neighbors(1, sgd)) == [2, 3]
@test collect(out_neighbors(2, sgd)) == [4]
@test collect(out_neighbors(3, sgd)) == [4]
@test isempty(out_neighbors(4, sgd))

end

# incoming

@testset "incoming" begin

@test [in_degree(v, sgd) for v = 1:4] == [0, 1, 1, 2]

@test isempty(in_edges(1, sgd))
@test in_edges(2, sgd) == es[[1]]
@test in_edges(3, sgd) == es[[2]]
@test in_edges(4, sgd) == es[3:4]

@test isempty(in_neighbors(1, sgd))
@test collect(in_neighbors(2, sgd)) == [1]
@test collect(in_neighbors(3, sgd)) == [1]
@test collect(in_neighbors(4, sgd)) == [2, 3]


@test collect_edges(sgd) == [Edge(1,1,2), Edge(2,1,3), Edge(3,2,4), Edge(4,3,4)]

global sgd = simple_graph(0)
global v = add_vertex!(sgd)
@test v == 1

end

end

#################################################
#
#  SimpleUndirectedGraph
#
#################################################

@testset "SimpleUndirectedGraph" begin

global sgu = simple_graph(4, is_directed=false)

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

global es = sgu.edges
global rs = [revedge(e) for e in es]

@test num_edges(sgu) == 5

# outgoing

@test [out_degree(vv, sgu) for vv = 1:4] == [3, 2, 2, 3]

@test out_edges(1, sgu) == [es[1], es[2], rs[5]]
@test out_edges(2, sgu) == [rs[1], es[3]]
@test out_edges(3, sgu) == [rs[2], es[4]]
@test out_edges(4, sgu) == [rs[3], rs[4], es[5]]

@test collect(out_neighbors(1, sgu)) == [2, 3, 4]
@test collect(out_neighbors(2, sgu)) == [1, 4]
@test collect(out_neighbors(3, sgu)) == [1, 4]
@test collect(out_neighbors(4, sgu)) == [2, 3, 1]

# incoming

@test [in_degree(vv, sgu) for vv = 1:4] == [3, 2, 2, 3]

@test in_edges(1, sgu) == [rs[1], rs[2], es[5]]
@test in_edges(2, sgu) == [es[1], rs[3]]
@test in_edges(3, sgu) == [es[2], rs[4]]
@test in_edges(4, sgu) == [es[3], es[4], rs[5]]

@test collect(in_neighbors(1, sgu)) == [2, 3, 4]
@test collect(in_neighbors(2, sgu)) == [1, 4]
@test collect(in_neighbors(3, sgu)) == [1, 4]
@test collect(in_neighbors(4, sgu)) == [2, 3, 1]

end


@testset "Extended and General directed graph" begin

for T in [ExVertex, String]

#################################################
#
#  Extended and General directed graph
#
#################################################

global egd = graph(T[], ExEdge{T}[])
@test is_directed(egd) == true

global test_names = ["a", "b", "c", "d"]

for (i, x) in enumerate(test_names)
    global v = add_vertex!(egd, x)
    @test vertex_index(v, egd) == i
end
global vs = vertices(egd)

@test num_vertices(egd) == 4
@test num_edges(egd) == 0

add_edge!(egd, vs[1], vs[2])
add_edge!(egd, vs[1], vs[3])
add_edge!(egd, vs[2], vs[4])
add_edge!(egd, vs[3], vs[4])
global es = edges(egd)

@test num_edges(egd) == 4

# outgoing

@test [out_degree(v, egd) for v in vs] == [2, 1, 1, 0]

@test out_edges(vs[1], egd) == es[1:2]
@test out_edges(vs[2], egd) == es[[3]]
@test out_edges(vs[3], egd) == es[[4]]
@test isempty(out_edges(vs[4], egd))

global vals1 = iterate(out_neighbors(vs[1], egd))
global vals2 = iterate(out_neighbors(vs[1], egd), vals1[2])

@test collect(out_neighbors(vs[1], egd)) == [vs[2], vs[3]]
@test collect(out_neighbors(vs[2], egd)) == vs[[4]]
@test collect(out_neighbors(vs[3], egd)) == vs[[4]]
@test isempty(out_neighbors(vs[4], egd))

# incoming

@test [in_degree(v, egd) for v in vs] == [0, 1, 1, 2]

@test isempty(in_edges(vs[1], egd))
@test in_edges(vs[2], egd) == es[[1]]
@test in_edges(vs[3], egd) == es[[2]]
@test in_edges(vs[4], egd) == es[3:4]

@test isempty(in_neighbors(vs[1], egd))
@test collect(in_neighbors(vs[2], egd)) == vs[[1]]
@test collect(in_neighbors(vs[3], egd)) == vs[[1]]
@test collect(in_neighbors(vs[4], egd)) == vs[2:3]


#################################################
#
#  Extended and General undirected graph
#
#################################################

global egu = graph(T[], ExEdge{T}[]; is_directed=false)
@test is_directed(egu) == false

global test_names = ["a", "b", "c", "d"]

for (i, x) in enumerate(test_names)
    global v = add_vertex!(egu, x)
    @test vertex_index(v, egu) == i
end
global vs = vertices(egu)

@test num_vertices(egu) == 4
@test num_edges(egu) == 0

add_edge!(egu, vs[1], vs[2])
add_edge!(egu, vs[1], vs[3])
add_edge!(egu, vs[2], vs[4])
add_edge!(egu, vs[3], vs[4])
global es = edges(egu)
global rs = [revedge(e) for e in es]

@test num_edges(egu) == 4

# outgoing

@test [out_degree(v, egu) for v in vs] == [2, 2, 2, 2]

@test out_edges(vs[1], egu) == [es[1], es[2]]
@test out_edges(vs[2], egu) == [rs[1], es[3]]
@test out_edges(vs[3], egu) == [rs[2], es[4]]
@test out_edges(vs[4], egu) == [rs[3], rs[4]]

@test collect(out_neighbors(vs[1], egu)) == [vs[2], vs[3]]
@test collect(out_neighbors(vs[2], egu)) == [vs[1], vs[4]]
@test collect(out_neighbors(vs[3], egu)) == [vs[1], vs[4]]
@test collect(out_neighbors(vs[4], egu)) == [vs[2], vs[3]]

# incoming

@test [in_degree(v, egu) for v in vs] == [2, 2, 2, 2]

@test in_edges(vs[1], egu) == [rs[1], rs[2]]
@test in_edges(vs[2], egu) == [es[1], rs[3]]
@test in_edges(vs[3], egu) == [es[2], rs[4]]
@test in_edges(vs[4], egu) == [es[3], es[4]]

@test collect(in_neighbors(vs[1], egu)) == [vs[2], vs[3]]
@test collect(in_neighbors(vs[2], egu)) == [vs[1], vs[4]]
@test collect(in_neighbors(vs[3], egu)) == [vs[1], vs[4]]
@test collect(in_neighbors(vs[4], egu)) == [vs[2], vs[3]]

end

end

#################################################
#
#  graph() constructor
#
#################################################

@testset "graph() constructor" begin

global v = [ExVertex(1,""),ExVertex(2,"")]
global e = [ExEdge(1,v[1],v[2])]
global g = graph(v,e,is_directed=true)
@test num_edges(g) == 1
@test num_vertices(g) == 2

# Integer vertices and edges
global n = 100
global m = 1000

# We ensure that vertices have random but different values
function uniqueRands(range,nb::Int)
    result=Dict{Int,Bool}()
    i= 0
    while i < nb
        r = rand(1:10*n)
        if !haskey( result, r)
           i += 1
           result[r] = true
        end
    end
    collect(keys(result))
end

global vs = uniqueRands(1:10*n,n)

global es = Edge{Int}[]
for i in 1:m
  push!(es,Edge(i,vs[rand(1:n)],vs[rand(1:n)]))
end
global g = graph(vs,es)
for i in 1:m
  add_edge!(g,vs[rand(1:n)],vs[rand(1:n)])
end

@test num_vertices(g) == n
@test num_edges(g) == 2 * m
for vv in vs
  @test vertex_index(vv,g) == g.indexof[vv]
end
for i in 1:m
  @test edge_index(es[i],g) == i
end

# same for undirected graph
global n = 100
global m = 1000

global vs = uniqueRands(1:10*n,n)

global es = Edge{Int}[]
for i in 1:m
  push!(es,Edge(i,vs[rand(1:n)],vs[rand(1:n)]))
end
global g = graph(vs,es,is_directed=false)
for i in 1:m
  add_edge!(g,vs[rand(1:n)],vs[rand(1:n)])
end

@test num_vertices(g) == n
@test num_edges(g) == 2 * m
for vv in vs
  @test vertex_index(vv,g) == g.indexof[vv]
end
for i in 1:m
  @test edge_index(es[i],g) == i
end

end
