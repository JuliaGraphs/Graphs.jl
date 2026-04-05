##################################################################
#
#   Maximal independent sets of undirected graph
#   Derived from Graphs.jl: https://github.com/julialang/Graphs.jl
#
##################################################################

@testset "Independent Sets" begin
    function setofsets(array_of_arrays)
        return Set(map(Set, array_of_arrays))
    end

    function test_independent_sets(graph, expected)
        # Make test results insensitive to ordering
        okay_maximal =
            setofsets(@inferred(maximal_independent_sets(graph))) == setofsets(expected)
        okay_maximum = Set(@inferred(maximum_independent_set(graph))) in setofsets(expected)
        okay_maximum2 =
            length(@inferred(maximum_independent_set(graph))) == maximum(length.(expected))
        okay_number = @inferred(independence_number(graph)) == maximum(length.(expected))
        return okay_maximal && okay_maximum && okay_maximum2 && okay_number
    end

    gx = SimpleGraph(3)
    add_edge!(gx, 1, 2)
    for g in test_generic_graphs(gx)
        @test test_independent_sets(g, Array[[1, 3], [2, 3]])
    end
    add_edge!(gx, 2, 3)
    for g in test_generic_graphs(gx)
        @test test_independent_sets(g, Array[[1, 3], [2]])
    end
    @test independence_number(cycle_graph(11)) == 5
end
