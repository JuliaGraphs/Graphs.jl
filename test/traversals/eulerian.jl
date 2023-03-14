@testset "Eulerian tours/cycles" begin
    # a cycle (identical start/end)
    g0 = SimpleGraph([Edge(1,2), Edge(2,3), Edge(3,1)])
    @test eulerian(g0, 1) == eulerian(g0)
    @test last(eulerian(g0, 1)) == 1 # a cycle

    # a tour (different start/end)
    g1 = SimpleGraph([Edge(1,2), Edge(2,3), Edge(3,4)])
    @test eulerian(g1, 1) == [1,2,3,4]
    @test_throws "starting vertex has even degree but there are other vertices with odd degree" eulerian(g1, 2)
    
    # a cycle with a node (vertex 2) with multiple neighbors
    g2 = SimpleGraph([Edge(1,2), Edge(2,3), Edge(3,4), Edge(4,1), Edge(2,5), Edge(5,6), 
                      Edge(6,2)])
    @test eulerian(g2) == eulerian(g2, 1) == [1, 2, 5, 6, 2, 3, 4, 1]

    # graph with odd-degree vertices
    g3 = SimpleGraph([Edge(1,2), Edge(2,3), Edge(3,4), Edge(2,4), Edge(4,1), Edge(4,2)])
    @test_throws "starting vertex has even degree but there are other vertices with odd degree" eulerian(g3, 1)

    # start/end point not in graph
    @test_throws "starting vertex is not in the graph" eulerian(g3, 5)

    # disconnected components
    g4 = SimpleGraph([Edge(1,2), Edge(2,3), Edge(3,1),  # component 1
                      Edge(4,5), Edge(5,6), Edge(6,4)]) # component 2
    @test_throws "graph is not connected" eulerian(g4)

    # zero-degree nodes
    g5 = SimpleGraph(4)
    add_edge!(g5, Edge(1,2)); add_edge!(g5, Edge(2,3)); add_edge!(g5, Edge(3,1))
    @test_throws "some vertices have degree zero" eulerian(g5)

    # not yet implemented for directed graphs
    @test_broken eulerian(SimpleDiGraph([Edge(1,2), Edge(2,3), Edge(3,1)]))
end