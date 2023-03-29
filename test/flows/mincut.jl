@testset "Mincut" begin

    g = Graphs.complete_digraph(5)
    cap1 = [
       0.0 2.0 2.0 0.0 0.0
       0.0 0.0 0.0 0.0 3.0
       0.0 1.0 0.0 3.0 0.0
       0.0 0.0 0.0 0.0 1.0
       0.0 0.0 0.0 0.0 0.0
    ];
    (part1, part2, value) = Graphs.mincut(g,1,5,cap1,Graphs.PushRelabelAlgorithm())
    @test value ≈ 4.0
    @test part1 == [1]
    @test sort(part2) == collect(2:5)
    cap2 = [
       0.0 3.0 2.0 0.0 0.0
       0.0 0.0 0.0 0.0 3.0
       0.0 1.0 0.0 3.0 0.0
       0.0 0.0 0.0 0.0 1.5
       0.0 0.0 0.0 0.0 0.0
    ];
    (part1, part2, value) = Graphs.mincut(g,1,5,cap2,Graphs.PushRelabelAlgorithm())
    @test value ≈ 4.5
    @test sort(part1) == collect(1:4)
    @test part2 == [5]

    g2 = Graphs.DiGraph(5)
    Graphs.add_edge!(g2,1,2)
    Graphs.add_edge!(g2,1,3)
    Graphs.add_edge!(g2,3,4)
    Graphs.add_edge!(g2,3,2)
    Graphs.add_edge!(g2,2,5)

    (part1, part2, value) = Graphs.mincut(g2,1,5,cap1,Graphs.PushRelabelAlgorithm())
    @test value ≈ 3.0
    @test sort(part1) == [1,3,4]
    @test sort(part2) == [2,5]

    #non regression test
    flow_graph = Graphs.DiGraph(7)
    capacity_matrix = zeros(7,7)
    flow_edges = [
    (1,2,2),(1,3,2),(2,4,4),(2,5,4),
    (3,5,4),(3,6,4),(4,7,1),(5,7,1),(6,7,1)
    ]
    for e in flow_edges
       u, v, f = e
    Graphs.add_edge!(flow_graph, u, v)
    capacity_matrix[u,v] = f
    end
    (part1, part2, value) = Graphs.mincut(flow_graph, 1, 7, capacity_matrix, EdmondsKarpAlgorithm())
    @test value ≈ 3.0
    @test sort(part1) == [1,2,3,4,5,6]
    @test sort(part2) == [7]

end
