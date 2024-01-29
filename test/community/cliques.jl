##################################################################
#
#   Maximal cliques of undirected graph
#   Derived from Graphs.jl: https://github.com/julialang/Graphs.jl
#
##################################################################

@testset "Cliques" begin
    function setofsets(array_of_arrays)
        return Set(map(Set, array_of_arrays))
    end

    function test_cliques(graph, expected)
        # Make test results insensitive to ordering
        return setofsets(@inferred(maximal_cliques(graph))) == setofsets(expected)
    end

    gx = SimpleGraph(3)
    add_edge!(gx, 1, 2)
    for g in test_generic_graphs(gx)
        @test test_cliques(g, Array[[1, 2], [3]])
    end
    add_edge!(gx, 2, 3)
    for g in test_generic_graphs(gx)
        @test test_cliques(g, Array[[1, 2], [2, 3]])
    end
    # Test for "pivotdonenbrs not defined" bug
    h = SimpleGraph(6)
    add_edge!(h, 1, 2)
    add_edge!(h, 1, 3)
    add_edge!(h, 1, 4)
    add_edge!(h, 2, 5)
    add_edge!(h, 2, 6)
    add_edge!(h, 3, 4)
    add_edge!(h, 3, 6)
    add_edge!(h, 5, 6)

    for g in test_generic_graphs(h)
        @test !isempty(@inferred(maximal_cliques(g)))
    end

    # test for extra cliques bug

    h = SimpleGraph(7)
    add_edge!(h, 1, 3)
    add_edge!(h, 2, 6)
    add_edge!(h, 3, 5)
    add_edge!(h, 3, 6)
    add_edge!(h, 4, 5)
    add_edge!(h, 4, 7)
    add_edge!(h, 5, 7)
    for g in test_generic_graphs(h)
        @test test_cliques(h, Array[[7, 4, 5], [2, 6], [3, 5], [3, 6], [3, 1]])
    end
end
