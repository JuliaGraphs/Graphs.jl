@testset "A star" begin
    g3 = path_graph(5)
    g4 = path_digraph(5)

    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
    @testset "SimpleGraph and SimpleDiGraph" for g in testgraphs(g3), dg in testdigraphs(g4)
        @test @inferred(a_star(g, 1, 4, d1)) ==
            @inferred(a_star(dg, 1, 4, d1)) ==
            @inferred(a_star(g, 1, 4, d2))
        @test isempty(@inferred(a_star(dg, 4, 1)))
    end
    @testset "GenericGraph and GenricDiGraph with SimpleEdge" for g in
                                                                  test_generic_graphs(g3),
        dg in test_generic_graphs(g4)

        zero_heuristic = n -> 0
        Eg = SimpleEdge{eltype(g)}
        Edg = SimpleEdge{eltype(dg)}
        @test @inferred(a_star(g, 1, 4, d1, zero_heuristic, Eg)) ==
            @inferred(a_star(dg, 1, 4, d1, zero_heuristic, Edg)) ==
            @inferred(a_star(g, 1, 4, d2, zero_heuristic, Eg))
        @test isempty(@inferred(a_star(dg, 4, 1, weights(dg), zero_heuristic, Edg)))
    end

    # test for #1258
    g = complete_graph(4)
    w = float([1 1 1 4; 1 1 1 1; 1 1 1 1; 4 1 1 1])
    @test length(a_star(g, 1, 4, w)) == 2

    # test for #120
    struct MyFavoriteEdgeType <: AbstractEdge{Int}
        s::Int
        d::Int
    end
    @test eltype(a_star(GenericGraph(g), 1, 4, w, n -> 0, MyFavoriteEdgeType)) ==
        MyFavoriteEdgeType
end
