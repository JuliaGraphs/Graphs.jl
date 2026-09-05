@testset "External algorithms" begin
    @testset "declaration" begin
        # declared, but deliberately without methods: the implementation lives
        # in a separate package
        @test isempty(methods(max_weight_perfect_matching))
        @test haskey(Graphs.EXTERNAL_ALGORITHMS, max_weight_perfect_matching)
        @test Graphs.EXTERNAL_ALGORITHMS[max_weight_perfect_matching] == ["LEMONGraphs.jl"]

        # every registered entry must be a function Graphs.jl actually declares
        for f in keys(Graphs.EXTERNAL_ALGORITHMS)
            @test f isa Function
            @test !isempty(Graphs.EXTERNAL_ALGORITHMS[f])
        end
    end

    @testset "error hint" begin
        # `showerror` runs the registered hints
        message = try
            max_weight_perfect_matching(path_graph(4), [1, 1, 1], nothing)
            ""
        catch err
            sprint(showerror, err)
        end
        @test occursin("max_weight_perfect_matching", message)
        @test occursin("LEMONGraphs.jl", message)
        @test occursin("implemented elsewhere", message)

        # an unregistered function must not gain a hint
        untouched = try
            Graphs.nv(nothing)
            ""
        catch err
            sprint(showerror, err)
        end
        @test !occursin("LEMONGraphs.jl", untouched)
    end

    @testset "hint wording" begin
        # called directly with synthetic MethodErrors, so that the test does not
        # have to define methods on a function it shares with the rest of the suite
        hint(f) = sprint(io -> Graphs.external_algorithm_hint(io, MethodError(f, ())))

        # nothing registered: no hint at all
        @test isempty(hint(sin))

        # registered, no implementation package loaded
        @test occursin("implemented elsewhere", hint(max_weight_perfect_matching))

        # registered and the package is loaded, but still no method: the user
        # must not be told to install what they already have
        try
            Graphs.EXTERNAL_ALGORITHMS[max_weight_perfect_matching] = ["Test.jl"]
            message = hint(max_weight_perfect_matching)
            @test occursin("Test.jl is loaded but defines no method", message)
            @test !occursin("install and load", message)
        finally
            Graphs.EXTERNAL_ALGORITHMS[max_weight_perfect_matching] = ["LEMONGraphs.jl"]
        end

        # a registered function that does have methods
        try
            Graphs.EXTERNAL_ALGORITHMS[sin] = ["Nowhere.jl"]
            @test occursin("no method matches these argument types", hint(sin))
        finally
            delete!(Graphs.EXTERNAL_ALGORITHMS, sin)
        end
    end

    @testset "package detection" begin
        @test Graphs._is_package_loaded("Test.jl")
        @test Graphs._is_package_loaded("Test")
        @test !Graphs._is_package_loaded("NoSuchPackageReally.jl")
    end
end
