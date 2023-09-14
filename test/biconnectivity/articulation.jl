@testset "Articulation" begin
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
        art = @inferred(articulation(g))
        ans = [1, 7, 8, 12]
        @test art == ans
    end
    for level in 1:6
        btree = Graphs.binary_tree(level)
        for tree in test_generic_graphs(btree; eltypes=[Int, UInt8, Int16])
            artpts = @inferred(articulation(tree))
            @test artpts == collect(1:(2^(level - 1) - 1))
        end
    end

    hint = blockdiag(wheel_graph(5), wheel_graph(5))
    add_edge!(hint, 5, 6)
    for h in test_generic_graphs(hint, eltypes=[Int, UInt8, Int16])
        @test @inferred(articulation(h)) == [5, 6]
    end
end
