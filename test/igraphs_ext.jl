using Graphs
using IGraphs
using Test

@testset "IGraphs Extension" begin
    g = SimpleGraph(3)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)

    # Test conversion
    ig = Graphs.igraph(g)
    @test ig isa IGraphs.IGraph
    @test Graphs.nv(ig) == 3
    @test Graphs.ne(ig) == 2

    # Test real dispatch (Pagerank)
    # This should call the implementation in ext/IGraphsExt.jl
    pr = Graphs.pagerank(g, Graphs.IGraphAlgorithm())
    @test pr isa Vector{Float64}
    @test length(pr) == 3
    @test sum(pr) ≈ 1.0

    # Test real dispatch (Betweenness)
    bc = Graphs.betweenness_centrality(g, Graphs.IGraphAlgorithm())
    @test bc isa Vector{Float64}
    @test length(bc) == 3
    # For 1-2-3 graph, 2 has betweenness 1.0 (normalized) or 2.0 (unnormalized)
    # igraph usually returns unnormalized by default unless specified
    @test bc[2] > 0

    # Test real dispatch (SIR Model)
    # Using a slightly larger graph for better SIR simulation results
    g_sir = SimpleGraph(10)
    for i in 1:9
        add_edge!(g_sir, i, i+1)
    end
    res = Graphs.sir_model(g_sir, Graphs.IGraphAlgorithm(); beta=0.5, gamma=0.1, no_sim=10)
    @test res isa Vector{Vector{Float64}}
    @test length(res) == 10
    for sim_res in res
        @test !isempty(sim_res)
    end
end
