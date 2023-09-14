@testset "Radiality" begin
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")

    c = vec(readdlm(joinpath(testdir, "testdata", "graph-50-500-rc.txt"), ','))
    for g in test_generic_graphs(gint)
        z = @inferred(radiality_centrality(g))
        @test z == c
    end

    g1 = cycle_graph(4)
    add_vertex!(g1)
    add_edge!(g1, 4, 5)
    for g in test_generic_graphs(g1)
        z = @inferred(radiality_centrality(g))
        @test z ≈ [5//6, 3//4, 5//6, 11//12, 2//3]
    end
end
