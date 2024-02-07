@testset "Edit distance" begin
    rng = StableRNG(1)
    gtri = random_regular_graph(3, 2; rng=rng)
    gquad = random_regular_graph(4, 2; rng=rng)
    gpent = random_regular_graph(5, 2; rng=rng)

    g1 = star_graph(4)
    g2 = cycle_graph(3)

    vertex_insert_cost = v -> 1.0
    vertex_delete_cost = v -> 2.0
    vertex_subst_cost = (u, v) -> 3.0
    edge_insert_cost = e -> 4.0
    edge_delete_cost = e -> 5.0
    edge_subst_cost = (e1, e2) -> 6.0

    @testset "undirected edit_distance" for G1 in test_generic_graphs(g1),
        G2 in test_generic_graphs(g2)

        d, λ = @inferred(edit_distance(G1, G2))
        @test d == 2.0
        d, λ = @inferred(
            edit_distance(
                G1,
                G2,
                vertex_insert_cost=vertex_insert_cost,
                vertex_delete_cost=vertex_delete_cost,
                vertex_subst_cost=vertex_subst_cost,
                edge_insert_cost=edge_insert_cost,
                edge_delete_cost=edge_delete_cost,
                edge_subst_cost=edge_subst_cost,
            )
        )
        # 1 vertex deletion, 3 vertex substitution, 1 edge insertio n, 1 edge deletion, 2 edge substitution
        @test d == 32.0
    end

    g1 = DiGraph(4)
    edges = [(1, 2), (1, 4), (2, 3), (3, 1), (3, 4), (4, 1), (1, 1), (4, 4)]
    for e in edges
        add_edge!(g1, e)
    end
    g2 = DiGraph(4)
    edges = [(2, 1), (2, 3), (3, 1), (3, 2), (4, 1), (4, 2), (2, 2), (3, 3)]
    for e in edges
        add_edge!(g2, e)
    end

    @testset "directed edit_distance" for G1 in test_generic_graphs(g1),
        G2 in test_generic_graphs(g2)

        d, λ = @inferred(edit_distance(G1, G2))
        @test d == 4.0
    end
end
