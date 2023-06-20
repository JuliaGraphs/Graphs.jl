@testset "Stress" begin
    rng = StableRNG(1)
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")

    c = vec(readdlm(joinpath(testdir, "testdata", "graph-50-500-sc.txt"), ','))
    for g in testdigraphs(gint)
        z = @inferred(stress_centrality(g))
        @test z == c

        x = @inferred(stress_centrality(g, 3, rng=rng))
        x2 = @inferred(stress_centrality(g, collect(1:20)))
        @test length(x) == 50
        @test length(x2) == 50
    end

    g1 = cycle_graph(4)
    add_vertex!(g1)
    add_edge!(g1, 4, 5)
    for g in testgraphs(g1)
        z = @inferred(stress_centrality(g))
        @test z == [4, 2, 4, 10, 0]
    end
end
