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
        @test art == findall(is_articulation.(Ref(g), vertices(g)))
    end
    for level in 1:6
        btree = Graphs.binary_tree(level)
        for tree in test_generic_graphs(btree; eltypes=[Int, UInt8, Int16])
            artpts = @inferred(articulation(tree))
            @test artpts == collect(1:(2 ^ (level - 1) - 1))
            @test artpts == findall(is_articulation.(Ref(tree), vertices(tree)))
        end
    end

    hint = blockdiag(wheel_graph(5), wheel_graph(5))
    add_edge!(hint, 5, 6)
    for h in test_generic_graphs(hint; eltypes=[Int, UInt8, Int16])
        art = @inferred(articulation(h))
        @test art == [5, 6]
        @test art == findall(is_articulation.(Ref(h), vertices(h)))
    end

    # graph with disconnected components
    g = path_graph(5)
    es = collect(edges(g))
    g2 = Graph(vcat(es, [Edge(e.src + nv(g), e.dst + nv(g)) for e in es]))
    @test articulation(g) == [2, 3, 4] # a single connected component
    @test articulation(g2) == [2, 3, 4, 7, 8, 9] # two identical connected components
    @test articulation(g2) == findall(is_articulation.(Ref(g2), vertices(g2)))
end
