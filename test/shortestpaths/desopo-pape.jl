@testset "D'Esopo-Pape" begin
    g4 = path_digraph(5)
    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
    @testset "generic tests: $(typeof(g))" for g in test_generic_graphs(g4)
        y = @inferred(desopo_pape_shortest_paths(g, 2, d1))
        z = @inferred(desopo_pape_shortest_paths(g, 2, d2))
        @test y.parents == z.parents == [0, 0, 2, 3, 4]
        @test y.dists == z.dists == [Inf, 0, 6, 17, 33]
    end

    gx = path_graph(5)
    add_edge!(gx, 2, 4)
    d = ones(Int, 5, 5)
    d[2, 3] = 100
    @testset "cycles: $(typeof(g))" for g in test_generic_graphs(gx)
        z = @inferred(desopo_pape_shortest_paths(g, 1, d))
        @test z.dists == [0, 1, 3, 2, 3]
        @test z.parents == [0, 1, 4, 2, 4]
    end

    m = [0 2 2 0 0; 2 0 0 0 3; 2 0 0 1 2; 0 0 1 0 1; 0 3 2 1 0]
    G = SimpleGraph(5)
    add_edge!(G, 1, 2)
    add_edge!(G, 1, 3)
    add_edge!(G, 2, 5)
    add_edge!(G, 3, 5)
    add_edge!(G, 3, 4)
    add_edge!(G, 4, 5)

    @testset "more cycles: $(typeof(g))" for g in test_generic_graphs(G)
        y = @inferred(desopo_pape_shortest_paths(g, 1, m))
        @test y.parents == [0, 1, 1, 3, 3]
        @test y.dists == [0, 2, 2, 3, 4]
    end

    G = SimpleGraph(5)
    add_edge!(G, 2, 2)
    add_edge!(G, 1, 2)
    add_edge!(G, 1, 3)
    add_edge!(G, 3, 3)
    add_edge!(G, 1, 5)
    add_edge!(G, 2, 4)
    add_edge!(G, 4, 5)
    m = [0 10 2 0 15; 10 9 0 1 0; 2 0 1 0 0; 0 1 0 0 2; 15 0 0 2 0]
    @testset "self loops: $(typeof(g))" for g in test_generic_graphs(G)
        z = @inferred(desopo_pape_shortest_paths(g, 1, m))
        y = @inferred(dijkstra_shortest_paths(g, 1, m))
        @test isapprox(z.dists, y.dists)
    end

    G = SimpleGraph(5)
    add_edge!(G, 1, 2)
    add_edge!(G, 1, 3)
    add_edge!(G, 4, 5)
    inf = typemax(eltype(G))
    @testset "disconnected: $(typeof(G))" for g in test_generic_graphs(G)
        z = @inferred(desopo_pape_shortest_paths(g, 1))
        @test z.dists == [0, 1, 1, inf, inf]
        @test z.parents == [0, 1, 1, 0, 0]
    end

    G = SimpleGraph(3)
    inf = typemax(eltype(G))
    @testset "empty: $(typeof(g))" for g in test_generic_graphs(G)
        z = @inferred(desopo_pape_shortest_paths(g, 1))
        @test z.dists == [0, inf, inf]
        @test z.parents == [0, 0, 0]
    end

    @testset "random simple graphs" begin
        for seed in 1:5
            rng = StableRNG(seed)
            nvg = Int(ceil(250 * rand(rng)))
            neg = Int(floor((nvg * (nvg - 1) / 2) * rand(rng)))
            g = GenericGraph(SimpleGraph(nvg, neg; rng=rng))
            z = desopo_pape_shortest_paths(g, 1)
            y = dijkstra_shortest_paths(g, 1)
            @test isapprox(z.dists, y.dists)
        end
    end

    @testset "random simple digraphs" begin
        for seed in 1:5
            rng = StableRNG(seed)
            nvg = Int(ceil(250 * rand(rng)))
            neg = Int(floor((nvg * (nvg - 1) / 2) * rand(rng)))
            g = GenericDiGraph(SimpleDiGraph(nvg, neg; rng=rng))
            z = desopo_pape_shortest_paths(g, 1)
            y = dijkstra_shortest_paths(g, 1)
            @test isapprox(z.dists, y.dists)
        end
    end

    @testset "misc graphs" begin
        G = GenericGraph(complete_graph(9))
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = GenericDiGraph(complete_digraph(9))
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = GenericGraph(cycle_graph(9))
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = GenericDiGraph(cycle_digraph(9))
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = GenericGraph(star_graph(9))
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = GenericGraph(wheel_graph(9))
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = GenericGraph(roach_graph(9))
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = GenericGraph(clique_graph(5, 19))
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)
    end

    @testset "smallgraphs: $s" for s in [
        :bull,
        :chvatal,
        :cubical,
        :desargues,
        :diamond,
        :dodecahedral,
        :frucht,
        :heawood,
        :house,
        :housex,
        :icosahedral,
        :krackhardtkite,
        :moebiuskantor,
        :octahedral,
        :pappus,
        :petersen,
        :sedgewickmaze,
        :tutte,
        :tetrahedral,
        :truncatedcube,
        :truncatedtetrahedron,
        :truncatedtetrahedron_dir,
    ]
        GS = smallgraph(s)
        GG = is_directed(GS) ? GenericDiGraph(GS) : GenericGraph(GS)
        z = desopo_pape_shortest_paths(GG, 1)
        y = dijkstra_shortest_paths(GG, 1)
        @test isapprox(z.dists, y.dists)
    end

    @testset "errors" begin
        g = GenericGraph(Graph())
        @test_throws DomainError desopo_pape_shortest_paths(g, 1)
        g = GenericGraph(Graph(5))
        @test_throws DomainError desopo_pape_shortest_paths(g, 6)
    end
end
