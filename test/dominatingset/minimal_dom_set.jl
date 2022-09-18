@testset "Minimal Dominating Set" begin

    g0 = SimpleGraph(0)
    for g in testgraphs(g0)
        d = @inferred(dominating_set(g, MinimalDominatingSet(); rng=StableRNG(3)))
        @test isempty(d)
    end

    g1 = SimpleGraph(1)
    for g in testgraphs(g1)
        d = @inferred(dominating_set(g, MinimalDominatingSet(); rng=StableRNG(3)))
        @test (d == [1,])
    end

    add_edge!(g1, 1, 1)
    for g in testgraphs(g1)
        d = @inferred(dominating_set(g, MinimalDominatingSet(); rng=StableRNG(3)))
        @test (d == [1,])
    end

    g3 = star_graph(5)
    for g in testgraphs(g3)
        d = @inferred(dominating_set(g, MinimalDominatingSet(); rng=StableRNG(3)))
        @test (length(d)== 1 || (length(d)== 4 && minimum(d) > 1 ))
    end
    
    g4 = complete_graph(5)
    for g in testgraphs(g4)
        d = @inferred(dominating_set(g, MinimalDominatingSet(); rng=StableRNG(3)))
        @test length(d)== 1 #Exactly one vertex
    end

    g5 = path_graph(4)
    for g in testgraphs(g5)
        d = @inferred(dominating_set(g, MinimalDominatingSet(); rng=StableRNG(3)))
        sort!(d)
        @test (d == [1, 2, 4] || d == [1, 3] || d == [1, 4] || d == [2, 3] || d == [2, 4])
    end

    add_edge!(g5, 2, 2)
    add_edge!(g5, 3, 3)
    for g in testgraphs(g5)
        d = @inferred(dominating_set(g, MinimalDominatingSet(); rng=StableRNG(3)))
        sort!(d)
        @test (d == [1, 2, 4] || d == [1, 3] || d == [1, 4] || d == [2, 3] || d == [2, 4])
    end
end
