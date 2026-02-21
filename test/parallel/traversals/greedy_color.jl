@testset "Parallel.Greedy Coloring" for parallel in [:threads, :distributed]
    g3 = star_graph(10)
    for g in testgraphs(g3)
        for op_sort in (true, false)
            C = @inferred(Parallel.greedy_color(g; reps=5, sort_degree=op_sort, parallel))
            @test C.num_colors == 2
        end
    end

    g4 = path_graph(20)
    g5 = complete_graph(20)

    let g = testgraphs(g4)[1]
        # An error should be reported if the parallel mode could not be understood
        @test_throws ArgumentError Parallel.greedy_color(
            g; reps=5, sort_degree=false, parallel=:thread
        )
        @test_throws ArgumentError Parallel.greedy_color(
            g; reps=5, sort_degree=false, parallel=:distriibuted
        )
    end

    for graph in [g4, g5]
        for g in testgraphs(graph)
            for op_sort in (true, false)
                C = @inferred(
                    Parallel.greedy_color(g; reps=5, sort_degree=op_sort, parallel)
                )

                @test C.num_colors <= maximum(degree(g)) + 1
                correct = true
                for e in edges(g)
                    C.colors[src(e)] == C.colors[dst(e)] && (correct = false)
                end
                @test correct
            end
        end
    end
end
