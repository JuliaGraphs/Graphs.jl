using Graphs
using Test

function test_simple_example()
    # From the wikipedia page for the Hopcroft-Karp algorithm
    # https://en.wikipedia.org/wiki/Hopcroft–Karp_algorithm
    g = Graph()
    add_vertices!(g, 10)
    add_edge!(g, (1, 6))
    add_edge!(g, (1, 7))
    add_edge!(g, (2, 6))
    add_edge!(g, (2, 10))
    add_edge!(g, (3, 8))
    add_edge!(g, (3, 9))
    add_edge!(g, (4, 6))
    add_edge!(g, (4, 10))
    add_edge!(g, (5, 6))
    add_edge!(g, (5, 9))

    matching = hopcroft_karp_matching(g)
    @test length(matching) == 10
    for i in 1:10
        @test i in keys(matching)
        @test matching[i] in neighbors(g, i)
    end
end

function test_imperfect_matching()
    g = Graph()
    add_vertices!(g, 16)
    add_edge!(g, (1, 9))
    add_edge!(g, (2, 9))
    add_edge!(g, (3, 9))
    add_edge!(g, (1, 10))
    add_edge!(g, (4, 10))
    add_edge!(g, (2, 11))
    add_edge!(g, (4, 11))
    add_edge!(g, (3, 12))
    add_edge!(g, (4, 12))
    add_edge!(g, (1, 13))
    add_edge!(g, (2, 13))
    add_edge!(g, (3, 13))
    add_edge!(g, (4, 13))
    add_edge!(g, (1, 14))
    add_edge!(g, (5, 14))
    add_edge!(g, (8, 14))
    add_edge!(g, (2, 15))
    add_edge!(g, (6, 15))
    add_edge!(g, (8, 15))
    add_edge!(g, (3, 16))
    add_edge!(g, (7, 16))
    add_edge!(g, (8, 16))

    matching = hopcroft_karp_matching(g)
    println(matching)
    println(length(matching))
    @test length(matching) == 14

    possibly_unmatched_1 = Set([5, 6, 7, 8])
    possibly_unmatched_2 = Set([9, 10, 11, 12, 13])

    for i in 1:16
        if i in keys(matching)
            # Sanity check
            @test matching[i] in neighbors(g, i)
        elseif i <= 8
            # Make sure the unmatched vertices match what we predict.
            # (Possibly unmatched vertices are computed via the
            # Dulmage-Mendelsohn decomposition.)
            @test i in possibly_unmatched_1
        else
            @test i in possibly_unmatched_2
        end
    end
end

function test_complete_bipartite()
    g = complete_bipartite_graph(10, 20)
    matching = hopcroft_karp_matching(g)
    @test length(matching) == 20
    for i in 1:10
        @test i in keys(matching)
        @test matching[i] > 10
    end
end

function test_not_bipartite()
    g = complete_graph(5)
    @test_throws(ArgumentError, hopcroft_karp_matching(g))
end

@testset "Hopcroft-Karp matching" begin
    test_simple_example()
    test_imperfect_matching()
    test_complete_bipartite()
    test_not_bipartite()
end
