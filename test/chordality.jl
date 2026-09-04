@testset "Chordality" begin
    rng = StableRNG(737362)

    # Chordal: 4-cycle with a chord
    c4_chorded = cycle_graph(4)
    add_edge!(c4_chorded, 1, 3)

    # Chordal: Figure 2 from Tarjan and Yannakakis (1984) (cited in `src/chordality.jl`)
    fig2_ty84 = SimpleGraph(10)
    for (u, v) in [
        (1, 2),
        (1, 5),
        (2, 4),
        (2, 5),
        (2, 6),
        (3, 4),
        (3, 5),
        (3, 7),
        (4, 5),
        (4, 6),
        (4, 7),
        (5, 6),
        (7, 8),
        (7, 9),
        (8, 9),
        (8, 10),
        (9, 10),
    ]
        add_edge!(fig2_ty84, u, v)
    end

    # Non-chordal: Figure 1 from Tarjan and Yannakakis (1984) (cited in `src/chordality.jl`)
    fig1_ty84 = SimpleGraph(9)
    for (u, v) in [
        (1, 2),
        (1, 3),
        (1, 9),
        (2, 3),
        (2, 4),
        (3, 5),
        (3, 8),
        (4, 5),
        (4, 6),
        (5, 6),
        (5, 8),
        (6, 7),
        (7, 8),
        (8, 9),
    ]
        add_edge!(fig1_ty84, u, v)
    end

    @testset "chordal" begin
        @testset "$(typeof(g))" for g in test_generic_graphs(
            SimpleGraph(0), # Empty graph
            SimpleGraph(1), # Singleton graph
            path_graph(2),
            cycle_graph(3),
            path_graph(10),
            star_graph(6),
            complete_graph(5),
            blockdiag(cycle_graph(3), cycle_graph(3)), # Disconnected case
            c4_chorded,
            fig2_ty84,
        )
            @test @inferred(is_chordal(g))
        end
    end

    @testset "non-chordal" begin
        @testset "$(typeof(g))" for g in test_generic_graphs(
            cycle_graph(4),
            cycle_graph(5),
            cycle_graph(6),
            cycle_graph(10),
            smallgraph(:petersen),
            complete_bipartite_graph(2, 3),
            grid([2, 3]),
            blockdiag(cycle_graph(3), cycle_graph(4)), # Disconnected case
            fig1_ty84,
        )
            @test @inferred(!is_chordal(g))
        end
    end

    #= The probability of a random labelled graph on `n ∈ {5, 6, 7, 8}` vertices being
    chordal is, depending on the `n`, between 11.5% and 80.3% (OEIS A058862 vs. A006125).
    Therefore, even in the "worst" case, we can be confident that at least a few of the 20
    test cases for each `n` are chordal (and since we use a random seed, we can confirm
    that this is indeed the case). =#
    @testset "random" begin
        for n in 5:8, _ in 1:20
            #= The Erdős–Rényi distribution with edge probability 0.5 is precisely the
            uniform distribution of all labelled graphs on `n` vertices, so this is
            equivalent to sampling a random labelled graph. =#
            g = erdos_renyi(n, 0.5; rng=rng)
            # `LibIGraph.is_chordal` returns a tuple, not a boolean, so we need `first`
            expected = first(
                LibIGraph.is_chordal(IGraph(g), IGNull(), IGNull(), IGNull(), IGNull())
            )

            for gg in test_generic_graphs(g)
                @test @inferred(is_chordal(gg)) == expected
            end
        end
    end

    #= `is_chordal` is not implemented for directed graphs (a `MethodError` is thrown) or
    for graphs with self-loops (an `ArgumentError` is thrown). =#
    @testset "errors" begin
        g_loop = copy(cycle_graph(4))
        add_edge!(g_loop, 1, 1)

        @testset "$(typeof(g))" for g in test_generic_graphs(g_loop)
            @test_throws ArgumentError is_chordal(g)
        end

        @test_throws MethodError is_chordal(cycle_digraph(4))
    end
end
