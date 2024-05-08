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

        gr = erdos_renyi(20, 0.1; is_directed = true)

        for g in hcat(test_generic_graphs(gx), test_generic_graphs(gr))
            rg = ReverseView(g)
            allocated_rg = DiGraph(nv(g))
            for e in edges(g)
                add_edge!(allocated_rg, Edge(dst(e), src(e)))
            end

            @test eltype(rg) == eltype(g)
            @test is_directed(rg) == true
            @test nv(rg) == nv(g) == nv(allocated_rg)
            @test ne(rg) == ne(g) == ne(allocated_rg)
            @test sort(collect(inneighbors(rg, 2))) == sort(collect(inneighbors(allocated_rg, 2)))
            @test sort(collect(outneighbors(rg, 2))) == sort(collect(outneighbors(allocated_rg, 2)))
            @test indegree(rg, 3) == indegree(allocated_rg, 3)
            @test degree(rg, 1) == degree(allocated_rg, 1)
            @test has_edge(rg, 1, 3) == has_edge(allocated_rg, 1, 3) 
            @test has_edge(rg, 1, 4) == has_edge(allocated_rg, 1, 4)

            rg_res = @inferred(dijkstra_shortest_paths(rg, 3))
            allocated_rg_res = dijkstra_shortest_paths(allocated_rg, 3)
            @test rg_res.dists == allocated_rg_res.dists # parents may not be the same

            rg_res = @inferred(strongly_connected_components(rg))
            allocated_rg_res = strongly_connected_components(allocated_rg)
            @test length(rg_res) == length(allocated_rg_res)
            @test sort(length.(rg_res)) == sort(length.(allocated_rg_res))
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

        gr = erdos_renyi(20, 0.05; is_directed = true)

        for g in test_generic_graphs(gx)
            ug = UndirectedView(g)
            @test ne(ug) == 7 # one less edge since there was two edges in reverse directions
        end

        for g in hcat(test_generic_graphs(gx), test_generic_graphs(gr))
            ug = UndirectedView(g)
            allocated_ug = Graph(g)
            
            @test eltype(ug) == eltype(g)
            @test is_directed(ug) == false
            @test nv(ug) == nv(g) == nv(allocated_ug)
            @test ne(ug) == ne(allocated_ug)
            @test sort(collect(inneighbors(ug, 2))) == sort(collect(inneighbors(allocated_ug, 2)))
            @test sort(collect(outneighbors(ug, 2))) == sort(collect(outneighbors(allocated_ug, 2)))
            @test indegree(ug, 3) == indegree(allocated_ug, 3)
            @test degree(ug, 1) == degree(allocated_ug, 1)
            @test has_edge(ug, 1, 3) == has_edge(allocated_ug, 1, 3) 
            @test has_edge(ug, 1, 4) == has_edge(allocated_ug, 1, 4)

            ug_res = @inferred(dijkstra_shortest_paths(ug, 3))
            allocated_ug_res = dijkstra_shortest_paths(allocated_ug, 3)
            @test ug_res.dists == allocated_ug_res.dists # parents may not be the same

            ug_res = @inferred(biconnected_components(ug))
            allocated_ug_res = biconnected_components(allocated_ug)
            @test length(ug_res) == length(allocated_ug_res)
            @test sort(length.(ug_res)) == sort(length.(allocated_ug_res))
        end
    end
end