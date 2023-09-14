@testset "Core" begin
    e2 = GenericEdge(Edge(1, 3))
    e3 = GenericEdge(Edge(1, 4))
    # TODO do these tests make sense? One might define an edge type for some undirected
    # graph that is more like a set than a tuple -then reverse would not change the order
    @test @inferred(is_ordered(e2))
    @test @inferred(!is_ordered(reverse(e3)))

    # TODO we cannot test add_vertices! with generic graphs
    @testset "add_vertices!" begin
        gx = SimpleGraph(10)
        gdx = SimpleDiGraph(10)
        @testset "$g" for g in testgraphs(gx, gdx)
            gc = copy(g)
            @test add_vertices!(gc, 5) == 5
            @test @inferred(nv(gc)) == 15
        end
    end

    g5w = wheel_graph(5)
    g5wd = wheel_digraph(5)
    @testset "degree functions" begin
        @testset "$(typeof(g))" for g in test_generic_graphs(g5w)
            @test @inferred(indegree(g, 1)) == @inferred(outdegree(g, 1)) == 4
            @test degree(g, 1) == 4 # explicit codecov
            @test @inferred(indegree(g)) ==
                @inferred(outdegree(g)) ==
                @inferred(degree(g)) ==
                [4, 3, 3, 3, 3]

            @test @inferred(Δout(g)) == @inferred(Δin(g)) == @inferred(Δ(g)) == 4
            @test @inferred(δout(g)) == @inferred(δin(g)) == @inferred(δ(g)) == 3
            z1 = @inferred(degree_histogram(g))
            z2 = @inferred(degree_histogram(g, indegree))
            z3 = @inferred(degree_histogram(g, outdegree))
            @test z1 == z2 == z3 == Dict(4 => 1, 3 => 4)
        end
        @testset "$(typeof(g))" for g in test_generic_graphs(g5wd)
            @test @inferred(indegree(g, 2)) == 2
            @test @inferred(outdegree(g, 2)) == 1
            @test @inferred(degree(g, 2)) == 3
            @test @inferred(indegree(g)) == [0, 2, 2, 2, 2]
            @test @inferred(outdegree(g)) == [4, 1, 1, 1, 1]
            @test @inferred(degree(g)) == [4, 3, 3, 3, 3]
            @test @inferred(Δout(g)) == @inferred(Δ(g)) == 4
            @test @inferred(Δin(g)) == 2
            @test @inferred(δout(g)) == 1
            @test @inferred(δin(g)) == 0
            @test @inferred(δ(g)) == 3
            z1 = @inferred(degree_histogram(g))
            z2 = @inferred(degree_histogram(g, indegree))
            z3 = @inferred(degree_histogram(g, outdegree))
            @test z1 == Dict(4 => 1, 3 => 4)
            @test z2 == Dict(0 => 1, 2 => 4)
            @test z3 == Dict(4 => 1, 1 => 4)
        end
    end

    @testset "weights" begin
        @testset "$(typeof(g))" for g in test_generic_graphs(g5w, g5wd)
            @test @inferred(weights(g)) == Graphs.DefaultDistance(nv(g))
        end
    end

    @testset "neighbor functions" begin
        @testset "$(typeof(g))" for g in test_generic_graphs(g5w)
            @test collect(@inferred(neighbors(g, 2))) == [1, 3, 5]
            @test collect(@inferred(all_neighbors(g, 2))) == [1, 3, 5]
            @test @inferred(common_neighbors(g, 1, 5)) == [2, 4]
        end
        @testset "$(typeof(g))" for g in test_generic_graphs(g5wd)
            @test collect(@inferred(neighbors(g, 2))) == [3]
            @test Set(@inferred(all_neighbors(g, 2))) == Set([1, 3, 5])
            @test @inferred(common_neighbors(g, 1, 5)) == [2]
        end
    end

    @testset "self loops" begin
        @testset "$(typeof(g))" for g in testgraphs(g5w, g5wd)
            gsl = copy(g)
            add_edge!(gsl, 3, 3)
            add_edge!(gsl, 2, 2)
            @test @inferred(!has_self_loops(generic_graph(g)))
            @test @inferred(has_self_loops(generic_graph(gsl)))
            @test @inferred(num_self_loops(generic_graph(g))) == 0
            @test @inferred(num_self_loops(generic_graph(gsl))) == 2
        end
    end

    @testset "density" begin
        @testset "$(typeof(g))" for g in test_generic_graphs(g5w)
            @test @inferred(density(g)) == 0.8
        end

        @testset "$(typeof(g))" for g in test_generic_graphs(g5wd)
            @test @inferred(density(g)) == 0.4
        end
    end
end
