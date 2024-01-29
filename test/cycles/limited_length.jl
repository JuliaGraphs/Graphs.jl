@testset "Limited Length Cycles" begin
    completedg = complete_digraph(4)
    pathdg = path_digraph(5)
    cycledg = cycle_digraph(5)

    @testset "complete digraph" for g in test_generic_graphs(completedg)
        @test length(simplecycles_limited_length(g, 0)) == 0
        @test length(simplecycles_limited_length(g, 1)) == 0
        @test length(simplecycles_limited_length(g, 2)) == 6
        @test length(simplecycles_limited_length(g, 3)) == 14
        @test length(simplecycles_limited_length(g, 4)) == 20
        @test length(simplecycles_limited_length(g, 4, 10)) == 10
        @test length(simplecycles_limited_length(g, 4, typemax(Int))) == 20
    end

    @testset "path digraph" for g in test_generic_graphs(pathdg)
        @test length(simplecycles_limited_length(g, 1)) == 0
        @test length(simplecycles_limited_length(g, 2)) == 0
        @test length(simplecycles_limited_length(g, 3)) == 0
        @test length(simplecycles_limited_length(g, 4)) == 0
        @test length(simplecycles_limited_length(g, 5)) == 0
    end

    @testset "cycle digraph" for g in test_generic_graphs(cycledg)
        @test length(simplecycles_limited_length(g, 1)) == 0
        @test length(simplecycles_limited_length(g, 2)) == 0
        @test length(simplecycles_limited_length(g, 3)) == 0
        @test length(simplecycles_limited_length(g, 4)) == 0
        @test length(simplecycles_limited_length(g, 5)) == 1
    end

    @testset "self loops" begin
        selfloopg = GenericDiGraph(DiGraph([
            0 1 0 0
            0 0 1 0
            1 0 1 0
            0 0 0 1
        ]))
        cycles = simplecycles_limited_length(selfloopg, nv(selfloopg))
        @test [3] in cycles
        @test [4] in cycles
        @test [1, 2, 3] in cycles || [2, 3, 1] in cycles || [3, 1, 2] in cycles
        @test length(cycles) == 3
    end

    @testset "octahedral graph" begin
        octag = smallgraph(:octahedral)
        octadg = DiGraph(octag)
        # TODO simplecycleslength does currently not yet work with GenericDiGraph.
        # This is probably because it uses induced_subgraph which fails on that graph type.
        octalengths, _ = simplecycleslength(octadg)
        for k in 1:6
            @test sum(octalengths[1:k]) ==
                length(simplecycles_limited_length(GenericGraph(octag), k))
            @test sum(octalengths[1:k]) ==
                length(simplecycles_limited_length(GenericDiGraph(octadg), k))
        end
    end
end
