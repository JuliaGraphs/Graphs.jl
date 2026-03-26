@testset "igraphs" begin
    @test IGraphAlgorithm() isa AbstractGraphAlgorithm

    # Test error hint for sir_model
    try
        sir_model(SimpleGraph(3), 0.1, 0.1, 10)
        @test false # Should not reach here
    catch e
        @test e isa MethodError
        @test e.f === sir_model

        msg = sprint(showerror, e)
        @test contains(msg, "This function requires the IGraphs.jl package to be loaded")
    end

    # Test community_leiden
    try
        community_leiden(SimpleGraph(3))
        @test false
    catch e
        @test e isa MethodError
        msg = sprint(showerror, e)
        @test contains(msg, "This function requires the IGraphs.jl package to be loaded")
    end

    # Test modularity_matrix
    try
        modularity_matrix(SimpleGraph(3))
        @test false
    catch e
        @test e isa MethodError
        msg = sprint(showerror, e)
        @test contains(msg, "This function requires the IGraphs.jl package to be loaded")
    end
end

if !isnothing(Base.find_package("IGraphs"))
    include("igraphs_ext.jl")
    include("igraphs_interface.jl")
end
