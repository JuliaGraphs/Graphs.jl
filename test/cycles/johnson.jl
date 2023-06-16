@testset "Cycles" begin
    rng = StableRNG(1)
    completedg = complete_digraph(4)
    pathdg = path_digraph(5)
    triangle = random_regular_graph(3, 2; rng=rng)
    quadrangle = random_regular_graph(4, 2; rng=rng)
    pentagon = random_regular_graph(5, 2; rng=rng)

    @testset "path digraph" for g in testgraphs(pathdg)
        @test maxsimplecycles(g) == 0
        @test maxsimplecycles(g, false) == 84
        @test simplecyclescount(g) == 0
        @test length(simplecycles(g)) == 0
        @test isempty(simplecycles(g)) == true
        @test isempty(simplecycles_iter(g)) == true
        @test simplecycleslength(g) == (zeros(5), 0)
        @test simplecyclescount(g, 10) == 0
        @test isempty(simplecycles_iter(g, 10)) == true
        @test simplecycleslength(g, 10) == (zeros(5), 0)
    end

    @testset "maxsimplecycles(4)" begin
        @test maxsimplecycles(4) == 20
    end

    @testset "complete digraph" for g in testgraphs(completedg)
        @test maxsimplecycles(g) == 20
        @test length(simplecycles(g)) == 20
        @test simplecycles(g) == @inferred(simplecycles_iter(g))
        @test simplecyclescount(g) == 20
        @test simplecycleslength(g) == ([0, 6, 8, 6], 20)
        @test simplecyclescount(g, 10) == 10
        @test simplecycleslength(g, 10)[2] == 10
    end

    @testset "triangle" for g in testgraphs(triangle)
        trianglelengths, triangletotal = simplecycleslength(DiGraph(g))
        @test sum(trianglelengths) == triangletotal
    end

    @testset "quadrangle" for g in testgraphs(quadrangle)
        quadranglelengths, quadrangletotal = simplecycleslength(DiGraph(g))
        @test sum(quadranglelengths) == quadrangletotal
        @test simplecycles(DiGraph(g)) == @inferred(simplecycles_iter(DiGraph(g)))
    end

    @testset "pentagon" for g in testgraphs(pentagon)
        pentagonlengths, pentagontotal = simplecycleslength(DiGraph(g))
        @test sum(pentagonlengths) == pentagontotal
    end

    selfloopg = DiGraph([
        0 1 0 0
        0 0 1 0
        1 0 1 0
        0 0 0 1
    ])

    @testset "self loops" for g in testgraphs(selfloopg)
        cycles = simplecycles(g)
        @test [3] in cycles
        @test [4] in cycles
        @test [1, 2, 3] in cycles || [2, 3, 1] in cycles || [3, 1, 2] in cycles
        @test length(cycles) == 3

        cycles2 = simplecycles_iter(g)
        @test [3] in cycles2
        @test [4] in cycles2
        @test [1, 2, 3] in cycles2 || [2, 3, 1] in cycles2 || [3, 1, 2] in cycles2
        @test length(cycles2) == 3
    end
end
