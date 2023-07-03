@testset "Bidijkstra" begin
    g3 = path_graph(5)
    g4 = path_digraph(5)

    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
    for g in testgraphs(g3), dg in testdigraphs(g4)
        @test @inferred(bidijkstra_shortest_path(g, 1, 4, d1)) ==
            @inferred(bidijkstra_shortest_path(dg, 1, 4, d1)) ==
            @inferred(bidijkstra_shortest_path(g, 1, 4, d2))
        @test isempty(@inferred(bidijkstra_shortest_path(dg, 4, 1)))
    end

    # test for #1258
    g = complete_graph(4)
    w = float([1 1 1 4; 1 1 1 1; 1 1 1 1; 4 1 1 1])
    ds = dijkstra_shortest_paths(g, 1, w)
    @test length(bidijkstra_shortest_path(g, 1, 4, w)) == 3 # path is a sequence of vertices
end
