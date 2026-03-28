using Graphs
using Test

@testset "VNGraphs Stubs" begin
    g = path_graph(5)
    
    @test_throws ErrorException chromatic_number(g)
    @test_throws ErrorException edge_chromatic_number(g)
    
    # Verify the error message contains the suggestion to load VNGraphs.jl
    try
        chromatic_number(g)
    catch e
        @test contains(e.msg, "VNGraphs.jl")
    end
    
    try
        edge_chromatic_number(g)
    catch e
        @test contains(e.msg, "VNGraphs.jl")
    end
end
