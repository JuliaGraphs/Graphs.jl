@testset "Bridge" begin
    rng = StableRNG(1)

    gint = SimpleGraph(13)
    add_edge!(gint, 1, 7)
    add_edge!(gint, 1, 2)
    add_edge!(gint, 1, 3)
    add_edge!(gint, 12, 13)
    add_edge!(gint, 10, 13)
    add_edge!(gint, 10, 12)
    add_edge!(gint, 12, 11)
    add_edge!(gint, 5, 4)
    add_edge!(gint, 6, 4)
    add_edge!(gint, 8, 9)
    add_edge!(gint, 6, 5)
    add_edge!(gint, 1, 6)
    add_edge!(gint, 7, 5)
    add_edge!(gint, 7, 3)
    add_edge!(gint, 7, 8)
    add_edge!(gint, 7, 10)
    add_edge!(gint, 7, 12)

    for g in test_generic_graphs(gint)
        brd = @inferred(bridges(g))
        ans = [Edge(1, 2), Edge(8, 9), Edge(7, 8), Edge(11, 12)]
        @test brd == ans
    end
    for level in 1:6
        btree = Graphs.binary_tree(level)
        for tree in test_generic_graphs(btree; eltypes=[Int, UInt8, Int16])
            brd = @inferred(bridges(tree))
            ans = edges(tree)

            # AbstractEdge currently does not implement any comparison operators
            # so instead we compare tuples of source and target vertices
            @test sort([(src(e), dst(e)) for e in brd]) == sort([(src(e), dst(e)) for e in ans])
        end
    end

    hint = blockdiag(wheel_graph(5), wheel_graph(5))
    add_edge!(hint, 5, 6)
    for h in test_generic_graphs(hint; eltypes=[Int, UInt8, Int16])
        brd = @inferred bridges(h)
        @test length(brd) == 1
        @test src(brd[begin]) == 5
        @test dst(brd[begin]) == 6
    end

    dir = GenericDiGraph(SimpleDiGraph(10, 10; rng=rng))
    @test_throws MethodError bridges(dir)
end
