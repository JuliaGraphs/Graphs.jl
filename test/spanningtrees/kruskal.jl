@testset "Kruskal" begin
    g4 = complete_graph(4)

    distmx = [
        0 1 5 6
        1 0 4 10
        5 4 0 3
        6 10 3 0
    ]

    vec_mst = Vector{Edge}([Edge(1, 2), Edge(3, 4), Edge(2, 3)])
    max_vec_mst = Vector{Edge}([Edge(2, 4), Edge(1, 4), Edge(1, 3)])
    for g in test_generic_graphs(g4)
        # Testing Kruskal's algorithm
        mst = @inferred(kruskal_mst(g, distmx))
        max_mst = @inferred(kruskal_mst(g, distmx, minimize=false))
        # GenericEdge currently does not implement any comparison operators
        # so instead we compare tuples of source and target vertices
        @test sort([(src(e), dst(e)) for e in mst]) == sort([(src(e), dst(e)) for e in vec_mst])
        @test sort([(src(e), dst(e)) for e in max_mst]) == sort([(src(e), dst(e)) for e in max_vec_mst])
    end
    # second test
    distmx_sec = [
        0 0 0.26 0 0.38 0 0.58 0.16
        0 0 0.36 0.29 0 0.32 0 0.19
        0.26 0.36 0 0.17 0 0 0.4 0.34
        0 0.29 0.17 0 0 0 0.52 0
        0.38 0 0 0 0 0.35 0.93 0.37
        0 0.32 0 0 0.35 0 0 0.28
        0.58 0 0.4 0.52 0.93 0 0 0
        0.16 0.19 0.34 0 0.37 0.28 0 0
    ]

    gx = SimpleGraph(distmx_sec)
    vec2 = Vector{Edge}([
        Edge(1, 8), Edge(3, 4), Edge(2, 8), Edge(1, 3), Edge(6, 8), Edge(5, 6), Edge(3, 7)
    ])
    max_vec2 = Vector{Edge}([
        Edge(5, 7), Edge(1, 7), Edge(4, 7), Edge(3, 7), Edge(5, 8), Edge(2, 3), Edge(5, 6)
    ])
    for g in test_generic_graphs(gx)
        mst2 = @inferred(kruskal_mst(g, distmx_sec))
        max_mst2 = @inferred(kruskal_mst(g, distmx_sec, minimize=false))
        @test sort([(src(e), dst(e)) for e in mst2]) == sort([(src(e), dst(e)) for e in vec2])
        @test sort([(src(e), dst(e)) for e in max_mst2]) == sort([(src(e), dst(e)) for e in max_vec2])
    end
end
