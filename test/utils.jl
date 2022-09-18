@testset "Utils" begin
    rng = StableRNG(1)
    s = @inferred(Graphs.sample!(rng, [1:10;], 3))
    @test length(s) == 3
    for e in s
        @test 1 <= e <= 10
    end

    s = @inferred(Graphs.sample!(rng, [1:10;], 6, exclude=[1, 2]))
    @test length(s) == 6
    for e in s
        @test 3 <= e <= 10
    end

    s = @inferred(Graphs.sample(1:10, 6, exclude=[1, 2], rng=rng))
    @test length(s) == 6
    for e in s
        @test 3 <= e <= 10
    end

    # tests if isbounded has the correct behaviour
    bounded_int_types = [Int8, Int16, Int32, Int64, Int128, 
                         UInt8, UInt16, UInt32, UInt64, UInt128,
                         Int, Bool]
    unbounded_int_types = [BigInt, Signed, Unsigned, Integer, Union{Int8, UInt8}]
    for T in bounded_int_types
        @test Graphs.isbounded(T) == true
        @test Graphs.isbounded(T(0)) == true
    end
    for T in unbounded_int_types
        @test Graphs.isbounded(T) == false
        if isconcretetype(T)
            @test Graphs.isbounded(T(0)) == false
        end
    end

    @testset "rng_from_rng_or_seed" begin
        @test Graphs.rng_from_rng_or_seed(nothing, nothing) === Random.GLOBAL_RNG
        @test Graphs.rng_from_rng_or_seed(nothing, -10) === Random.GLOBAL_RNG
        @test Graphs.rng_from_rng_or_seed(nothing, 456) == Graphs.getRNG(456)
        @compat if ismutable(Random.GLOBAL_RNG)
            @test Graphs.rng_from_rng_or_seed(nothing, 456) !== Random.GLOBAL_RNG
        end
        rng = Random.MersenneTwister(789)
        @test Graphs.rng_from_rng_or_seed(rng, nothing) === rng
        @test_throws ArgumentError Graphs.rng_from_rng_or_seed(rng, -1)
    end

    A = [false, true, false, false, true, true]
    @test findall(A) == Graphs.findall!(A, Vector{Int16}(undef, 6))[1:3]
end

@testset "Unweighted Contiguous Partition" begin

    p = @inferred(Graphs.unweighted_contiguous_partition(4, 2))
    @test p == [1:2, 3:4]

    p = @inferred(Graphs.unweighted_contiguous_partition(10, 3))
    @test p == [1:3, 4:6, 7:10]

    p = @inferred(Graphs.unweighted_contiguous_partition(4, 4))
    @test p == [1:1, 2:2, 3:3, 4:4]
end

@testset "Greedy Contiguous Partition" begin

    p = @inferred(Graphs.greedy_contiguous_partition([1, 1, 1, 3], 2))
    @test p == [1:3, 4:4]

    p = @inferred(Graphs.greedy_contiguous_partition([1, 2, 3, 4, 5, 100, 1, 3, 1, 1], 3))
    @test p == [1:5, 6:6, 7:10]

    p = @inferred(Graphs.greedy_contiguous_partition([1, 1, 1, 1], 4))
    @test p == [1:1, 2:2, 3:3, 4:4]
end

@testset "Optimal Contiguous Partition" begin

    p = @inferred(Graphs.optimal_contiguous_partition([1, 1, 1, 3], 2))
    @test p == [1:3, 4:4]

    p = @inferred(Graphs.optimal_contiguous_partition([1, 2, 3, 4, 5, 100, 1, 3, 1, 1], 3))
    @test p == [1:5, 6:6, 7:10]

    p = @inferred(Graphs.optimal_contiguous_partition([1, 1, 1, 1], 4))
    @test p == [1:1, 2:2, 3:3, 4:4]
end
