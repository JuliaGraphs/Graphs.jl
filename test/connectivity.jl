@testset "Connectivity" begin
    g6 = smallgraph(:house)
    gx = path_graph(4)
    add_vertices!(gx, 10)
    add_edge!(gx, 5, 6)
    add_edge!(gx, 6, 7)
    add_edge!(gx, 8, 9)
    add_edge!(gx, 10, 9)

    for g in testgraphs(gx)
        @test @inferred(!is_connected(g))
        cc = @inferred(connected_components(g))
        label = zeros(eltype(g), nv(g))
        @inferred(Graphs.connected_components!(label, g))
        @test label[1:10] == [1, 1, 1, 1, 5, 5, 5, 8, 8, 8]
        import Graphs: components, components_dict
        cclab = @inferred(components_dict(label))
        @test cclab[1] == [1, 2, 3, 4]
        @test cclab[5] == [5, 6, 7]
        @test cclab[8] == [8, 9, 10]
        @test length(cc) >= 3 && sort(cc[3]) == [8, 9, 10]
    end
    for g in testgraphs(g6)
        @test @inferred(is_connected(g))
    end

    g10 = SimpleDiGraph(4)
    add_edge!(g10, 1, 3)
    add_edge!(g10, 2, 4)
    for g in testdigraphs(g10)
        @test @inferred(is_bipartite(g))
    end
    add_edge!(g10, 1, 4)
    for g in testdigraphs(g10)
        @test @inferred(is_bipartite(g))
    end

    g10 = SimpleDiGraph(20)
    for g in testdigraphs(g10)
        for m in 1:50
            i = rand(1:10)
            j = rand(11:20)
            if rand() < 0.5
                i, j = j, i
            end
            if !has_edge(g, i, j)
                add_edge!(g, i, j)
                @test @inferred(is_bipartite(g))
            end
        end
    end

    # graph from https://en.wikipedia.org/wiki/Strongly_connected_component
    h = SimpleDiGraph(8)
    add_edge!(h, 1, 2)
    add_edge!(h, 2, 3)
    add_edge!(h, 2, 5)
    add_edge!(h, 2, 6)
    add_edge!(h, 3, 4)
    add_edge!(h, 3, 7)
    add_edge!(h, 4, 3)
    add_edge!(h, 4, 8)
    add_edge!(h, 5, 1)
    add_edge!(h, 5, 6)
    add_edge!(h, 6, 7)
    add_edge!(h, 7, 6)
    add_edge!(h, 8, 4)
    add_edge!(h, 8, 7)
    for g in testdigraphs(h)
        @test @inferred(is_weakly_connected(g))
        scc = @inferred(strongly_connected_components(g))
        scc_k = @inferred(strongly_connected_components_kosaraju(g))
        wcc = @inferred(weakly_connected_components(g))

        @test length(scc) == 3 && sort(scc[3]) == [1, 2, 5]
        @test length(scc_k) == 3 && sort(scc_k[1]) == [1, 2, 5]
        @test length(wcc) == 1 && length(wcc[1]) == nv(g)
    end

    function scc_ok(graph)
        # Check that all SCC really are strongly connected
        scc = @inferred(strongly_connected_components(graph))
        scc_as_subgraphs = map(i -> graph[i], scc)
        return all(is_strongly_connected, scc_as_subgraphs)
    end

    function scc_k_ok(graph)
        # Check that all SCC really are strongly connected
        scc_k = @inferred(strongly_connected_components_kosaraju(graph))
        scc_k_as_subgraphs = map(i -> graph[i], scc_k)
        return all(is_strongly_connected, scc_k_as_subgraphs)
    end

    # the two graphs below are isomorphic (exchange 2 <--> 4)
    h = SimpleDiGraph(4)
    add_edge!(h, 1, 4)
    add_edge!(h, 4, 2)
    add_edge!(h, 2, 3)
    add_edge!(h, 1, 3)
    for g in testdigraphs(h)
        @test scc_ok(g)
        @test scc_k_ok(g)
    end

    h2 = SimpleDiGraph(4)
    add_edge!(h2, 1, 2)
    add_edge!(h2, 2, 4)
    add_edge!(h2, 4, 3)
    add_edge!(h2, 1, 3)
    for g in testdigraphs(h2)
        @test scc_ok(g)
        @test scc_k_ok(g)
    end

    # Test case for empty graph
    h = SimpleDiGraph(0)
    for g in testdigraphs(h)
        scc = @inferred(strongly_connected_components(g))
        scc_k = @inferred(strongly_connected_components_kosaraju(g))
        @test length(scc) == 0
        @test length(scc_k) == 0
    end

    # Test case for graph with one vertex
    h = SimpleDiGraph(1)
    for g in testdigraphs(h)
        scc = @inferred(strongly_connected_components(g))
        scc_k = @inferred(strongly_connected_components_kosaraju(g))
        @test length(scc) == 1 && scc[1] == [1]
        @test length(scc_k) == 1 && scc[1] == [1]
    end

    # Test case for graph with self loops
    h = SimpleDiGraph(3)
    add_edge!(h, 1, 1)
    add_edge!(h, 2, 2)
    add_edge!(h, 3, 3)
    add_edge!(h, 1, 2)
    add_edge!(h, 2, 3)
    add_edge!(h, 2, 1)

    for g in testdigraphs(h)
        scc = @inferred(strongly_connected_components(g))
        scc_k = @inferred(strongly_connected_components_kosaraju(g))
        @test length(scc) == 2
        @test sort(scc[1]) == [3]
        @test sort(scc[2]) == [1, 2]

        @test length(scc_k) == 2
        @test sort(scc_k[1]) == [1, 2]
        @test sort(scc_k[2]) == [3]
    end

    h = SimpleDiGraph(6)
    add_edge!(h, 1, 3)
    add_edge!(h, 3, 4)
    add_edge!(h, 4, 2)
    add_edge!(h, 2, 1)
    add_edge!(h, 3, 5)
    add_edge!(h, 5, 6)
    add_edge!(h, 6, 4)
    for g in testdigraphs(h)
        scc = @inferred(strongly_connected_components(g))
        scc_k = @inferred(strongly_connected_components_kosaraju(g))
        @test length(scc) == 1 && sort(scc[1]) == [1:6;]
        @test length(scc_k) == 1 && sort(scc_k[1]) == [1:6;]
    end
    # tests from Graphs.jl
    h = SimpleDiGraph(4)
    add_edge!(h, 1, 2)
    add_edge!(h, 2, 3)
    add_edge!(h, 3, 1)
    add_edge!(h, 4, 1)
    for g in testdigraphs(h)
        scc = @inferred(strongly_connected_components(g))
        scc_k = @inferred(strongly_connected_components_kosaraju(g))
        @test length(scc) == 2 && sort(scc[1]) == [1:3;] && sort(scc[2]) == [4]
        @test length(scc_k) == 2 && sort(scc_k[2]) == [1:3;] && sort(scc_k[1]) == [4]
    end

    h = SimpleDiGraph(12)
    add_edge!(h, 1, 2)
    add_edge!(h, 2, 3)
    add_edge!(h, 2, 4)
    add_edge!(h, 2, 5)
    add_edge!(h, 3, 6)
    add_edge!(h, 4, 5)
    add_edge!(h, 4, 7)
    add_edge!(h, 5, 2)
    add_edge!(h, 5, 6)
    add_edge!(h, 5, 7)
    add_edge!(h, 6, 3)
    add_edge!(h, 6, 8)
    add_edge!(h, 7, 8)
    add_edge!(h, 7, 10)
    add_edge!(h, 8, 7)
    add_edge!(h, 9, 7)
    add_edge!(h, 10, 9)
    add_edge!(h, 10, 11)
    add_edge!(h, 11, 12)
    add_edge!(h, 12, 10)

    for g in testdigraphs(h)
        scc = @inferred(strongly_connected_components(g))
        scc_k = @inferred(strongly_connected_components_kosaraju(g))
        @test length(scc) == 4
        @test sort(scc[1]) == [7, 8, 9, 10, 11, 12]
        @test sort(scc[2]) == [3, 6]
        @test sort(scc[3]) == [2, 4, 5]
        @test scc[4] == [1]

        @test length(scc_k) == 4
        @test sort(scc_k[1]) == [1]
        @test sort(scc_k[2]) == [2, 4, 5]
        @test sort(scc_k[3]) == [3, 6]
        @test sort(scc_k[4]) == [7, 8, 9, 10, 11, 12]
    end

    # Test examples with self-loops from
    # Graph-Theoretic Analysis of Finite Markov Chains by J.P. Jarvis & D. R. Shier

    # figure 1 example
    fig1 = spzeros(5, 5)
    fig1[[3, 4, 9, 10, 11, 13, 18, 19, 22, 24]] = [
        0.5, 0.4, 0.1, 1.0, 1.0, 0.2, 0.3, 0.2, 1.0, 0.3
    ]
    fig1 = SimpleDiGraph(fig1)
    scc_fig1 = Vector[[2, 5], [1, 3, 4]]

    # figure 2 example
    fig2 = spzeros(5, 5)
    fig2[[3, 10, 11, 13, 14, 17, 18, 19, 22]] .= 1
    fig2 = SimpleDiGraph(fig2)

    # figure 3 example
    fig3 = spzeros(8, 8)
    fig3[[
        1, 7, 9, 13, 14, 15, 18, 20, 23, 27, 28, 31, 33, 34, 37, 45, 46, 49, 57, 63, 64
    ]] .= 1
    fig3 = SimpleDiGraph(fig3)
    scc_fig3 = Vector[[3, 4], [2, 5, 6], [8], [1, 7]]
    fig3_cond = SimpleDiGraph(4)
    add_edge!(fig3_cond, 4, 3)
    add_edge!(fig3_cond, 2, 1)
    add_edge!(fig3_cond, 4, 1)
    add_edge!(fig3_cond, 4, 2)

    # construct a n-number edge ring graph (period = n)
    n = 10
    n_ring = cycle_digraph(n)
    n_ring_shortcut = copy(n_ring)
    add_edge!(n_ring_shortcut, 1, 4)

    # figure 8 example
    fig8 = spzeros(6, 6)
    fig8[[2, 10, 13, 21, 24, 27, 35]] .= 1
    fig8 = SimpleDiGraph(fig8)

    @test Set(@inferred(strongly_connected_components(fig1))) == Set(scc_fig1)
    @test Set(@inferred(strongly_connected_components(fig3))) == Set(scc_fig3)

    @test @inferred(period(n_ring)) == n
    @test @inferred(period(n_ring_shortcut)) == 2

    @test @inferred(condensation(fig3)) == fig3_cond

    @test @inferred(attracting_components(fig1)) == Vector[[2, 5]]
    @test @inferred(attracting_components(fig3)) == Vector[[3, 4], [8]]

    g10dists = ones(10, 10)
    g10dists[1, 2] = 10.0
    g10 = star_graph(10)
    for g in testgraphs(g10)
        @test @inferred(neighborhood_dists(g, 1, 0)) == [(1, 0)]
        @test length(@inferred(neighborhood(g, 1, 1))) == 10
        @test length(@inferred(neighborhood(g, 1, 1, g10dists))) == 9
        @test length(@inferred(neighborhood(g, 2, 1))) == 2
        @test length(@inferred(neighborhood(g, 1, 2))) == 10
        @test length(@inferred(neighborhood(g, 2, 2))) == 10
        @test length(@inferred(neighborhood(g, 2, -1))) == 0
    end
    g10 = star_digraph(10)
    for g in testdigraphs(g10)
        @test @inferred(neighborhood_dists(g10, 1, 0, dir=:out)) == [(1, 0)]
        @test length(@inferred(neighborhood(g, 1, 1, dir=:out))) == 10
        @test length(@inferred(neighborhood(g, 1, 1, g10dists, dir=:out))) == 9
        @test length(@inferred(neighborhood(g, 2, 1, dir=:out))) == 1
        @test length(@inferred(neighborhood(g, 1, 2, dir=:out))) == 10
        @test length(@inferred(neighborhood(g, 2, 2, dir=:out))) == 1
        @test @inferred(neighborhood_dists(g, 1, 0, dir=:in)) == [(1, 0)]
        @test length(@inferred(neighborhood(g, 1, 1, dir=:in))) == 1
        @test length(@inferred(neighborhood(g, 2, 1, dir=:in))) == 2
        @test length(@inferred(neighborhood(g, 2, 1, g10dists, dir=:in))) == 2
        @test length(@inferred(neighborhood(g, 1, 2, dir=:in))) == 1
        @test length(@inferred(neighborhood(g, 2, 2, dir=:in))) == 2
    end
    @test @inferred(!isgraphical([1, 1, 1]))
    @test @inferred(isgraphical([2, 2, 2]))
    @test @inferred(isgraphical(fill(3, 10)))
    # 1116
    gc = cycle_graph(4)
    for g in testgraphs(gc)
        z = @inferred(neighborhood(g, 3, 3))
        @test (z == [3, 2, 4, 1] || z == [3, 4, 2, 1])
    end

    gd = SimpleDiGraph([0 1 1 0; 0 0 0 1; 0 0 0 1; 0 0 0 0])
    add_edge!(gd, 1, 4)
    for g in testdigraphs(gd)
        z = @inferred(neighborhood_dists(g, 1, 4))
        @test (4, 1) ∈ z
        @test (4, 2) ∉ z
    end
end
