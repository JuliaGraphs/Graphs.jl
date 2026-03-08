@testset "ECG" begin
    # Test ecg_weights
    # Undirected
    barbell = barbell_graph(3, 3)
    c = sparse(
        [
            0.0 1.0 1.0 0.0 0.0 0.0;
            1.0 0.0 1.0 0.0 0.0 0.0;
            1.0 1.0 0.0 0.0 0.0 0.0;
            0.0 0.0 0.0 0.0 1.0 1.0;
            0.0 0.0 0.0 1.0 0.0 1.0;
            0.0 0.0 0.0 1.0 1.0 0.0
        ],
    )
    for g in test_generic_graphs(barbell)
        r = ecg_weights(g)
        dropzeros!(r)
        @test c == r
    end

    # Empty, no edges
    empty = SimpleGraph(10)
    c = spzeros(10, 10)
    for g in test_generic_graphs(empty)
        r = @inferred ecg_weights(g)
        dropzeros!(r)
        @test c == r
    end

    # Empty, no nodes
    empty = SimpleGraph()
    c = spzeros(0, 0)
    for g in test_generic_graphs(empty)
        r = @inferred ecg_weights(g)
        @test c == r
    end

    # Undirected loops
    loops = complete_graph(2)
    add_edge!(loops, 1, 1)
    add_edge!(loops, 2, 2)
    c = sparse([
        2.0 0.0;
        0.0 2.0
    ])
    for g in test_generic_graphs(loops)
        r = ecg_weights(g)
        dropzeros!(r)
        @test c == r
    end

    # Directed
    triangle = SimpleDiGraph(3)
    add_edge!(triangle, 1, 2)
    add_edge!(triangle, 2, 3)
    add_edge!(triangle, 3, 1)

    # Directed Loops
    barbell = blockdiag(triangle, triangle)
    add_edge!(barbell, 1, 4)
    c = sparse(
        [
            0.0 1.0 0.0 0.0 0.0 0.0;
            0.0 0.0 1.0 0.0 0.0 0.0;
            1.0 0.0 0.0 0.0 0.0 0.0;
            0.0 0.0 0.0 0.0 1.0 0.0;
            0.0 0.0 0.0 0.0 0.0 1.0;
            0.0 0.0 0.0 1.0 0.0 0.0
        ],
    )
    for g in test_generic_graphs(barbell)
        r = ecg_weights(g)
        dropzeros!(r)
        @test r == c
    end

    # Directed loops
    barbell = SimpleDiGraph(2)
    add_edge!(barbell, 1, 1)
    add_edge!(barbell, 2, 2)
    add_edge!(barbell, 1, 2)
    c = sparse([
        1.0 0.0;
        0.0 1.0
    ])
    for g in test_generic_graphs(barbell)
        r = ecg_weights(g)
        dropzeros!(r)
        @test r == c
    end

    # Test ECG
    # Undirected
    barbell = barbell_graph(3, 3)
    c = [1, 1, 1, 2, 2, 2]
    for g in test_generic_graphs(barbell)
        r = ecg(g)
        @test c == r
    end

    # Directed
    triangle = SimpleDiGraph(3)
    add_edge!(triangle, 1, 2)
    add_edge!(triangle, 2, 3)
    add_edge!(triangle, 3, 1)

    barbell = blockdiag(triangle, triangle)
    add_edge!(barbell, 1, 4)
    c = [1, 1, 1, 2, 2, 2]
    for g in test_generic_graphs(barbell)
        r = ecg(g)
        @test r == c
    end

    # Empty, no edges
    empty = SimpleGraph(10)
    c = collect(1:10)
    for g in test_generic_graphs(empty)
        r = ecg(g)
        @test c == r
    end

    # Empty, no nodes
    empty = SimpleGraph()
    for g in test_generic_graphs(empty)
        r = ecg(g)
        @test length(r) == 0
    end
end
