@testset "Maximal Independent Set" begin

    rng = StableRNG(1)

    g0 = SimpleGraph(0)
    for parallel in [:threads, :distributed]    
        for g in testgraphs(g0)
            z = @inferred(Parallel.independent_set(g, 4, MaximalIndependentSet(); parallel=parallel, rng=rng))
            @test isempty(z)
        end
    end

    g1 = SimpleGraph(1)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g1)
            z = @inferred(Parallel.independent_set(g, 4, MaximalIndependentSet(); parallel=parallel, rng=rng))
            @test (z == [1,])
        end
    end

    add_edge!(g1, 1, 1)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g1)
            z = @inferred(Parallel.independent_set(g, 4, MaximalIndependentSet(); parallel=parallel, rng=rng))
            isempty(z)
        end
    end
      
    g3 = star_graph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g3)
            z = @inferred(Parallel.independent_set(g, 4, MaximalIndependentSet(); parallel=parallel, rng=rng))
            @test (length(z)== 1 || length(z)== 4)
        end
    end
    
    g4 = complete_graph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g4)
            z = @inferred(Parallel.independent_set(g, 4, MaximalIndependentSet(); parallel=parallel, rng=rng))
            @test length(z)== 1 #Exactly one vertex 
        end
    end

    g5 = path_graph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g5)
            z = @inferred(Parallel.independent_set(g, 4, MaximalIndependentSet(); parallel=parallel, rng=rng))
            sort!(z)
            @test (z == [2, 4] || z == [2, 5] || z == [1, 3, 5] || z == [1, 4])
        end
    end

    add_edge!(g5, 2, 2)
    add_edge!(g5, 3, 3)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g5)
            z = @inferred(Parallel.independent_set(g, 4, MaximalIndependentSet(); parallel=parallel, rng=rng))
            sort!(z)
            @test (z == [4,] || z == [5,] || z == [1, 5] || z == [1, 4])
        end
    end
end
