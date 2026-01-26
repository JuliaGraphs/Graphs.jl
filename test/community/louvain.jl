@testset "Louvain" begin
    # Basic Test case
    barbell = barbell_graph(4, 4)
    c = [1, 1, 1, 1, 2, 2, 2, 2]
    for g in test_generic_graphs(barbell)
        # Should work regardless of rng
        r = @inferred louvain(g)
        @test c == r
    end

    # Test clique
    clique = complete_graph(10)
    c = ones(10)
    for g in test_generic_graphs(clique)
        # Should work regardless of rng
        r = @inferred louvain(g)
        @test c == r
    end

    # Test disconnected
    disconnected = barbell_graph(4, 4)
    rem_edge!(disconnected, 4, 5)
    c = [1, 1, 1, 1, 2, 2, 2, 2]
    for g in test_generic_graphs(disconnected)
        # Should work regardless of rng
        r = @inferred louvain(g)
        @test c == r
    end

    # Test Empty Graph
    empty = SimpleGraph(10)
    c = collect(1:10)
    for g in test_generic_graphs(empty)
        # Should work regardless of rng
        r = @inferred louvain(g)
        @test c == r
    end

    # Test multiple merges
    g = blockdiag(barbell_graph(3, 3), complete_graph(10))
    add_edge!(g, 2, 5)
    c = [ones(6); 2*ones(10)]
    # Should work regardless of rng
    # generic_graphs uses UInt8 for T that is too small
    r = @inferred louvain(g)
    @test c == r

    # Test loops
    loops = SimpleGraph(2)
    add_edge!(loops, 1, 1)
    add_edge!(loops, 2, 2)
    add_edge!(loops, 1, 2)
    c = [1, 2]
    for g in test_generic_graphs(loops)
        # Should work regardless of rng
        r = @inferred louvain(g)
        @test c == r
    end

    # Test γ
    g = complete_graph(2)
    c1 = [1, 1]
    c2 = [1, 2]
    for g in test_generic_graphs(g)
        # Should work regardless of rng
        r = @inferred louvain(g)
        @test c1 == r
        r = @inferred louvain(g, γ=2)
        @test c2 == r
    end

    # Test custom distmx
    square = CycleGraph(4)
    d = [
        [0 4 0 1]
        [4 0 1 0]
        [0 1 0 4]
        [1 0 4 0]
    ]
    c = [1, 1, 2, 2]
    for g in test_generic_graphs(square)
        # Should work regardless of rng
        r = @inferred louvain(g, distmx=d)
        @test c == r
    end

    # Test max_merges
    g = blockdiag(barbell_graph(3, 3), complete_graph(10))
    add_edge!(g, 2, 5)
    c = [ones(3); 2*ones(3)]
    # Should work regardless of rng
    # generic_graphs uses UInt8 for T that is too small
    r = @inferred louvain(g, max_merges=0)
    @test c == r[1:6]
    # the clique does not resolve in one step so we don't know what
    # the coms will be. But we know the barbell splits into two groups
    # of 3 in step one and merges in step two.
end
