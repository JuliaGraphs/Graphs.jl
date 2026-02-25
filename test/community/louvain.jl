@testset "Louvain" begin
    # Basic Test case
    barbell = barbell_graph(3, 3)
    c = [1, 1, 1, 2, 2, 2]
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
    loops = complete_graph(2)
    add_edge!(loops, 1, 1)
    add_edge!(loops, 2, 2)
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

    # Directed cases

    # Simple
    triangle = SimpleDiGraph(3)
    add_edge!(triangle, 1, 2)
    add_edge!(triangle, 2, 3)
    add_edge!(triangle, 3, 1)

    barbell = blockdiag(triangle, triangle)
    add_edge!(barbell, 1, 4)
    c1 = [1, 1, 1, 2, 2, 2]
    c2 = [1, 1, 1, 1, 1, 1]
    for g in test_generic_graphs(barbell)
        r = @inferred louvain(g)
        @test r == c1
        r = @inferred louvain(g, γ=10e-5)
        @test r == c2
    end

    # Self loops
    barbell = SimpleDiGraph(2)
    add_edge!(barbell, 1, 1)
    add_edge!(barbell, 2, 2)
    add_edge!(barbell, 1, 2)
    c1 = [1, 2]
    c2 = [1, 1]
    for g in test_generic_graphs(barbell)
        r = @inferred louvain(g)
        @test r == c1
        r = @inferred louvain(g, γ=10e-5)
        @test r == c2
    end

    # Weighted
    square = SimpleDiGraph(4)
    add_edge!(square, 1, 2)
    add_edge!(square, 2, 3)
    add_edge!(square, 3, 4)
    add_edge!(square, 4, 1)
    d1 = [
        [0 5 0 0]
        [0 0 1 0]
        [0 0 0 5]
        [1 0 0 0]
    ]
    d2 = [
        [0 1 0 0]
        [0 0 5 0]
        [0 0 0 1]
        [5 0 0 0]
    ]
    c1 = [1, 1, 2, 2]
    c2 = [1, 2, 2, 1]
    for g in test_generic_graphs(square)
        r = @inferred louvain(g, distmx=d1)
        @test r == c1
        r = @inferred louvain(g, distmx=d2)
        @test r == c2
    end
end
