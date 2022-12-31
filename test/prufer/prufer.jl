@testset "Prufer trees" begin
    g1 = Graph(6)
    for e in [(1, 4), (2, 4), (3, 4), (4, 5), (5, 6)]
        add_edge!(g1)
    end

    g2 = path_graph(10)

    for g in testgraphs(g1)
        @test is_tree(g)
        code = prufer_encode(g)
        @test code = [4, 4, 4, 5]
        @test prufer_decode(code) == g
    end
end