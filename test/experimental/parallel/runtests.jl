# using Graphs
# using Graphs.Parallel
# using Base.Threads: @threads, Atomic

tests = [
# "traversals/gdistances",  # TODO currently disabled as the code in gdistances seems to be broken
]

@testset "Graphs.Experimental.Parallel" begin
    for t in tests
        tp = joinpath(dirname(@__FILE__), "$(t).jl")
        include(tp)
    end
end
