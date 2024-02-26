@testset "Dijkstra" begin
    g4 = path_digraph(5)
    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))

    for g in test_generic_graphs(g4)
        y = @inferred(dijkstra_shortest_paths(g, 2, d1))
        z = @inferred(dijkstra_shortest_paths(g, 2, d2))

        @test y.parents == z.parents == [0, 0, 2, 3, 4]
        @test y.dists == z.dists == [Inf, 0, 6, 17, 33]

        y = @inferred(dijkstra_shortest_paths(g, 2, d1; allpaths=true))
        z = @inferred(dijkstra_shortest_paths(g, 2, d2; allpaths=true))
        @test z.predecessors[3] == y.predecessors[3] == [2]

        @test @inferred(enumerate_paths(z)) == enumerate_paths(y)
        @test @inferred(enumerate_paths(z))[4] ==
            enumerate_paths(z, 4) ==
            # test that we can pass a range into enumerate_paths - previously this caused
            # infinite recursion - see #1552
            enumerate_paths(z, 3:4)[2] ==
            enumerate_paths(y, 4) ==
            [2, 3, 4]
    end

    gx = path_graph(5)
    add_edge!(gx, 2, 4)
    d = ones(Int, 5, 5)
    d[2, 3] = 100
    for g in test_generic_graphs(gx)
        z = @inferred(dijkstra_shortest_paths(g, 1, d))
        @test z.dists == [0, 1, 3, 2, 3]
        @test z.parents == [0, 1, 4, 2, 4]
    end

    # small function to reconstruct the shortest path; I copied it from somewhere, can't find the original source to give the credits
    # @Beatzekatze on github
    function spath(target, dijkstraStruct, source)
        return if target == source
            target
        else
            [spath(dijkstraStruct.parents[target], dijkstraStruct, source) target]
        end
    end
    spaths(ds, targets, source) = [spath(i, ds, source) for i in targets]

    G = Graphs.Graph()
    add_vertices!(G, 4)
    add_edge!(G, 2, 1)
    add_edge!(G, 2, 3)
    add_edge!(G, 1, 4)
    add_edge!(G, 3, 4)
    add_edge!(G, 2, 2)
    w = [
        0.0 3.0 0.0 1.0
        3.0 0.0 2.0 0.0
        0.0 2.0 0.0 3.0
        1.0 0.0 3.0 0.0
    ]

    for g in test_generic_graphs(G)
        ds = @inferred(dijkstra_shortest_paths(g, 2, w))
        # this loop reconstructs the shortest path for vertices 1, 3 and 4
        @test spaths(ds, [1, 3, 4], 2) == Array[[2 1], [2 3], [2 1 4]]

        # here a selflink at source is introduced; it should not change the shortest paths
        w[2, 2] = 10.0
        ds = @inferred(dijkstra_shortest_paths(g, 2, w))
        shortest_paths = []
        # this loop reconstructs the shortest path for vertices 1, 3 and 4
        @test spaths(ds, [1, 3, 4], 2) == Array[[2 1], [2 3], [2 1 4]]
    end

    #615
    m = [0 2 2 0 0; 2 0 0 0 3; 2 0 0 1 2; 0 0 1 0 1; 0 3 2 1 0]
    G = SimpleGraph(5)
    add_edge!(G, 1, 2)
    add_edge!(G, 1, 3)
    add_edge!(G, 2, 5)
    add_edge!(G, 3, 5)
    add_edge!(G, 3, 4)
    add_edge!(G, 4, 5)
    for g in test_generic_graphs(G)
        ds = @inferred(dijkstra_shortest_paths(g, 1, m; allpaths=true))
        @test ds.pathcounts == [1.0, 1.0, 1.0, 1.0, 2.0]
        @test ds.predecessors == [[], [1], [1], [3], [3, 4]]
        @test ds.predecessors == [[], [1], [1], [3], [3, 4]]

        dm = @inferred(dijkstra_shortest_paths(g, 1; allpaths=true, trackvertices=true))
        @test dm.pathcounts == [1.0, 1.0, 1.0, 1.0, 2.0]
        @test dm.predecessors == [[], [1], [1], [3], [2, 3]]
        @test dm.closest_vertices == [1, 2, 3, 5, 4]
    end

    G = SimpleGraph(5)
    add_edge!(G, 1, 2)
    add_edge!(G, 1, 3)
    add_edge!(G, 4, 5)
    for g in test_generic_graphs(G)
        dm = @inferred(dijkstra_shortest_paths(g, 1; allpaths=true, trackvertices=true))
        @test dm.closest_vertices == [1, 2, 3, 4, 5]
    end

    #maximum distance setting limits paths found
    G = cycle_graph(6)
    add_edge!(G, 1, 3)
    m = float(
        [0 2 2 0 0 1; 2 0 1 0 0 0; 2 1 0 4 0 0; 0 0 4 0 1 0; 0 0 0 1 0 1; 1 0 0 0 1 0]
    )

    for g in test_generic_graphs(G)
        ds = @inferred(dijkstra_shortest_paths(g, 3, m; maxdist=3.0))
        @test ds.dists == [2, 1, 0, Inf, Inf, 3]
    end
end
