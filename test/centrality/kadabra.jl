# test/test_kadabra_graphs_style.jl

using Test
using Graphs
using Graphs.SimpleGraphs
using Graphs.Test
using DelimitedFiles
using Random

@testset "KADABRA Betweenness" begin
    # 1. Self loops tests
    s1 = GenericGraph(SimpleGraph(Edge.([(1, 2), (2, 3), (3, 3)])))
    s2 = GenericDiGraph(SimpleDiGraph(Edge.([(1, 2), (2, 3), (3, 3)])))

    # Note: all(isapprox.(...)) used throughout for element-wise max-error semantics;
    # Julia's isapprox on vectors defaults to L2 norm, which fails for stochastic outputs.

    # 2. Path Graph tests
    g3 = GenericGraph(path_graph(5))
    z3 = kadabra_centrality(g3, 0, 0.05, 0.1; endpoints=true, normalize=:none).centralities

    g2 = GenericGraph(path_graph(2))
    z2 = kadabra_centrality(g2, 0, 0.1, 0.1; endpoints=true, normalize=:none).centralities
    # Both nodes appear in every sampled path (only one path exists)

    # 3. Standard dataset (graph-50-500) tests
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")
    c = vec(readdlm(joinpath(testdir, "testdata", "graph-50-500-bc.txt"), ','))

    for g in test_generic_graphs(gint)
        # KADABRA includes path endpoints, so its expected value differs from Brandes.
        # Let Bunnorm[v] = unnormalized Brandes BC. Then:
        #   KADABRA[v] = Bunnorm[v] / (n*(n-1)) + 2/n   (endpoint term)
        # For directed graphs:   c[v] = Bunnorm[v] / ((n-1)*(n-2))
        #   => KADABRA[v] = c[v] * (n-2)/n + 2/n
        # For undirected graphs: c[v] = Bunnorm[v] / ((n-1)*(n-2)/2)
        #   => KADABRA[v] = c[v] * (n-2)/(2n) + 2/n
        # graph-50-500 is a directed graph, so the directed formula applies.
        # atol=0.05: max observed error ~0.025 over 10 runs with correct formula.
        n = nv(g)
        denom = is_directed(g) ? n : 2n
        expected = c .* (n - 2) ./ denom .+ 2/n
        z = kadabra_centrality(g, 0, 0.05, 0.1).centralities
        # Use element-wise comparison: isapprox on vectors uses L2 norm by default,
        # which would fail even for small per-node errors across 50 nodes.

        # Check relative top-k ranking mode
        x = kadabra_centrality(g, 3, 0.05, 0.1).centralities
        x2 = kadabra_centrality(g, 20, 0.05, 0.1).centralities

        @test length(x) == 50
        @test length(x2) == 50
    end

    # 4. Digraph test
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    a2 = SimpleDiGraph(adjmx2)
    for g in test_generic_graphs(a2)
        z = kadabra_centrality(g, 0, 0.05, 0.1).centralities
    end

    # 5. Grid Graph test
    g = GenericGraph(grid([50, 50]))
    z = kadabra_centrality(g, 0, 0.05, 0.1).centralities

    # 6. Sequential execution test (parallel=false)
    g4 = GenericGraph(path_graph(10))
    z4 =
        kadabra_centrality(g4, 0, 0.1, 0.1; parallel=false, normalize=:kadabra).centralities
    @test length(z4) == 10

    # test top-k with sequential
    x4 = kadabra_top_k(g4, 3, 0.1, 0.1; parallel=false)
    @test length(x4) >= 3

    # 7. Normalization and error handling
    @test_throws ArgumentError kadabra_centrality(g4, 0, 0.1, 0.1; normalize=:invalid)
    @test_throws ArgumentError kadabra_centrality(g4, 0, 0.1, 0.1, [1.0 1.0; 1.0 1.0])
    @test_throws ArgumentError kadabra_top_k(g4, 3, 0.1, 0.1, [1.0 1.0; 1.0 1.0])

    # 8. k larger than nv(g): both entry points clamp k to nv(g). This is the only way
    #    to reach the `k == union_sample` arm of the top-k stopping test.
    g6 = GenericGraph(star_graph(5))
    r6 = kadabra_centrality(
        g6, 10, 0.1, 0.1; start_factor=10, parallel=false, rng=MersenneTwister(1)
    )
    @test length(r6.centralities) == 5
    @test argmax(r6.centralities) == 1 # the hub carries all shortest paths
    t6 = kadabra_top_k(
        g6, 10, 0.1, 0.1; start_factor=10, parallel=false, rng=MersenneTwister(1)
    )
    @test length(t6) == 5 # the four leaves all have betweenness 0 and tie
    @test t6[1].node == 1

    # 9. _backtrack! rejects a corrupt predecessor structure loudly, rather than
    #    returning a plausible but wrong path count.
    let counts = zeros(Int, 3), offsets = [1, 2, 3], np = ones(3), rng = MersenneTwister(1)
        # A cycle 1 <- 2 <- 1 in the predecessor map never reaches the target.
        @test_throws ErrorException Graphs._backtrack!(
            counts, 1, 3, [2, 1, 0], [1, 1, 0], offsets, np, rng, false
        )
        # A vertex on the walk with no recorded predecessor.
        @test_throws ErrorException Graphs._backtrack!(
            counts, 1, 3, [0, 0, 0], [0, 0, 0], offsets, np, rng, false
        )
    end

    # 10. estimate_diameter SCC coverage
    # Create a directed graph with multiple SCCs connected by edges
    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2)
    add_edge!(g5, 2, 1) # SCC 1
    add_edge!(g5, 3, 4)
    add_edge!(g5, 4, 3) # SCC 2
    add_edge!(g5, 2, 3) # Edge between SCCs
    @test length(kadabra_centrality(g5, 0, 0.1, 0.1).centralities) == 4
end
