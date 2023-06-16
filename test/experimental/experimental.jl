const exptestdir = dirname(@__FILE__)
tests = ["isomorphism", "parallel/runtests", "shortestpaths", "traversals"]

@testset "Experimental" begin
    @test length(description()) > 1

    for t in tests
        tp = joinpath(exptestdir, "$(t).jl")
        include(tp)
    end
end
