using Graphs.Experimental

@testset "nautgraphs" begin
    g = Graph(1)

    if VERSION >= v"1.8"
        @test_throws "Canonization algorithms" canonize!(g)
        @test_throws "Using `AlgNautyGraphs`" has_induced_subgraphisomorph(
            g, g, AlgNautyGraphs()
        )
        @test_throws "Using `AlgNautyGraphs`" has_subgraphisomorph(g, g, AlgNautyGraphs())
        @test_throws "Using `AlgNautyGraphs`" has_isomorph(g, g, AlgNautyGraphs())
        @test_throws "Using `AlgNautyGraphs`" count_induced_subgraphisomorph(
            g, g, AlgNautyGraphs()
        )
        @test_throws "Using `AlgNautyGraphs`" count_subgraphisomorph(g, g, AlgNautyGraphs())
        @test_throws "Using `AlgNautyGraphs`" count_isomorph(g, g, AlgNautyGraphs())
        @test_throws "Using `AlgNautyGraphs`" all_induced_subgraphisomorph(
            g, g, AlgNautyGraphs()
        )
        @test_throws "Using `AlgNautyGraphs`" all_subgraphisomorph(g, g, AlgNautyGraphs())
        @test_throws "Using `AlgNautyGraphs`" all_isomorph(g, g, AlgNautyGraphs())
    end

    using NautyGraphs

    g1 = path_graph(5)
    g2 = path_graph(5)

    permute!(g2, [5, 3, 1, 2, 4])

    @test has_isomorph(g1, g2, AlgNautyGraphs())

    canonize!(g1, AlgNautyGraphs())
    canonize!(g2, AlgNautyGraphs())
    @test g1 == g2

    g3 = star_graph(5)
    g4 = path_graph(4)

    @test !has_isomorph(g1, g3, AlgNautyGraphs())
    @test !has_isomorph(g1, g4, AlgNautyGraphs())

    canonize!(g3, AlgNautyGraphs())
    canonize!(g4, AlgNautyGraphs())

    @test g1 != g3
    @test g1 != g3
end