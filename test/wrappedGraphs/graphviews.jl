@testset "Graph Views" begin
    @testset "ReverseView" begin
        gx = DiGraph([
            Edge(1, 1),
            Edge(1, 2),
            Edge(1, 4),
            Edge(2, 1),
            Edge(2, 2),
            Edge(2, 4),
            Edge(3, 1),
            Edge(4, 3)
        ])

        gr = erdos_renyi(20, 0.5; is_directed = true)

        for g in hcat(test_generic_graphs(gx), test_generic_graphs(gr))
            rg = ReverseView(g)
            
            @test nv(rg) == nv(g)
            @test ne(rg) == ne(g)
            @test all((u, v) -> (u == v), zip(inneighbors(rg, 2), outneighbors(g, 2)))
            @test all((u, v) -> (u == v), zip(outneighbors(rg, 2), inneighbors(g, 2)))
            @test indegree(rg, 3) == outdegree(g, 3)
            @test degree(rg, 1) == degree(g, 1)
            @test has_edge(rg, 1, 3) == has_edge(g, 3, 1) 
            @test has_edge(rg, 1, 4) == has_edge(g, 4, 1)

            allocated_rg = reverse(g)

            rg_res = dijkstra_shortest_paths(rg, 3, 2)
            allocated_rg_res = @inferred(dijkstra_shortest_paths(allocated_rg, 3, 2))
            @test rg_res.parents == allocated_rg_res.parents
            @test rg_res.dists == allocated_rg_res.dists

            rg_res = biconnected_components(rg)
            allocated_rg_res = @inferred(biconnected_components(allocated_rg))
            @test rg_res == allocated_rg_res
        end
    end

    @testset "UndirectedView" begin
        gx = DiGraph([
            Edge(1, 1),
            Edge(1, 2),
            Edge(1, 4),
            Edge(2, 1),
            Edge(2, 2),
            Edge(2, 4),
            Edge(3, 1),
            Edge(4, 3)
        ])

        gr = erdos_renyi(20, 0.5; is_directed = true)

        for g in test_generic_graphs(gx)
            ug = UndirectedView(g)
            @test ne(ug) == 7 # one less edge since there was two edges in reverse directions
        end

        for g in hcat(test_generic_graphs(gx), test_generic_graphs(gr))
            ug = UndirectedView(g)
            
            @test nv(ug) == nv(g)
            @test all((u, v) -> (u == v), zip(inneighbors(ug, 2), all_neighbors(g, 2)))
            @test all((u, v) -> (u == v), zip(outneighbors(ug, 2), all_neighbors(g, 2)))
            @test indegree(ug, 3) == length(all_neighbors(g, 3))
            @test degree(ug, 1) == degree(g, 1)
            @test has_edge(ug, 1, 3) == has_edge(g, 1, 3) || has_edge(g, 3, 1)
            @test has_edge(ug, 1, 4) == has_edge(g, 1, 4) || has_edge(g, 4, 1)

            allocated_ug = Graph(g)

            ug_res = dijkstra_shortest_paths(ug, 3, 2)
            allocated_ug_res = @inferred(dijkstra_shortest_paths(allocated_ug, 3, 2))
            @test ug_res.parents == allocated_ug_res.parents
            @test ug_res.dists == allocated_ug_res.dists

            ug_res = biconnected_components(ug)
            allocated_ug_res = @inferred(biconnected_components(allocated_ug))
            @test ug_res == allocated_ug_res
        end
    end
end