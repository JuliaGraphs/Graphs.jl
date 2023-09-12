
@testset "Edge Betweenness" begin
    rng = StableRNG(1)
    # self loops
    s1 = GenericGraph(SimpleGraph(Edge.([(1, 2), (2, 3), (3, 3)])))
    s2 = GenericDiGraph(SimpleDiGraph(Edge.([(1, 2), (2, 3), (3, 3)])))

    g3 = GenericGraph(path_graph(5))

    @test @inferred(edge_betweenness_centrality(s1)) ==
        sparse([1, 2, 3, 2], [2, 1, 2, 3], [2 / 3, 2 / 3, 2 / 3, 2 / 3], 3, 3)
    @test @inferred(edge_betweenness_centrality(s2)) ==
        sparse([1, 2], [2, 3], [1 / 3, 1 / 3], 3, 3)

    g = GenericGraph(path_graph(2))
    z = @inferred(edge_betweenness_centrality(g; normalize=true))
    @test z[1, 2] == z[2, 1] == 1.0
    z2 = @inferred(edge_betweenness_centrality(g; vs=vertices(g)))
    z3 = @inferred(edge_betweenness_centrality(g, nv(g)))
    @test z == z2 == z3
    z = @inferred(edge_betweenness_centrality(g3; normalize=false))
    @test z[1, 2] == z[5, 4] == 4.0

    ##
    # Weighted Graph tests
    g = GenericGraph(SimpleGraph(Edge.([(1, 2), (2, 3), (2, 5), (3, 4), (4, 5), (5, 6)])))

    distmx = [
        0.0 2.0 0.0 0.0 0.0 0.0
        2.0 0.0 4.2 0.0 1.2 0.0
        0.0 4.2 0.0 5.5 0.0 0.0
        0.0 0.0 5.5 0.0 0.9 0.0
        0.0 1.2 0.0 0.9 0.0 0.6
        0.0 0.0 0.0 0.0 0.6 0.0
    ]

    @test isapprox(
        nonzeros(
            edge_betweenness_centrality(g; vs=vertices(g), distmx=distmx, normalize=false)
        ),
        [5.0, 5.0, 4.0, 8.0, 4.0, 1.0, 1.0, 4.0, 8.0, 4.0, 5.0, 5.0],
    )

    @test isapprox(
        nonzeros(
            edge_betweenness_centrality(g; vs=vertices(g), distmx=distmx, normalize=true)
        ),
        [5.0, 5.0, 4.0, 8.0, 4.0, 1.0, 1.0, 4.0, 8.0, 4.0, 5.0, 5.0] /
        (nv(g) * (nv(g) - 1)) * 2,
    )

    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    a2 = SimpleDiGraph(adjmx2)

    for g in test_generic_graphs(a2)
        distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]
        c2 = [0.24390243902439027, 0.27027027027027023, 0.1724137931034483]

        @test isapprox(
            nonzeros(
                edge_betweenness_centrality(
                    g; vs=vertices(g), distmx=distmx2, normalize=false
                ),
            ),
            [1.0, 1.0, 2.0, 1.0, 2.0],
        )

        @test isapprox(
            nonzeros(
                edge_betweenness_centrality(
                    g; vs=vertices(g), distmx=distmx2, normalize=true
                ),
            ),
            [1.0, 1.0, 2.0, 1.0, 2.0] * (1 / 6),
        )
    end
    # test #1405 / #1406
    g = GenericGraph(grid([50, 50]))
    z = edge_betweenness_centrality(g; normalize=false)
    @test maximum(z) < nv(g) * (nv(g) - 1)
end
