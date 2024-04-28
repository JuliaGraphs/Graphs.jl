@testset "DFSIterator" begin
    g = Graph()
    error_exc = ErrorException("Some source nodes for the iterator are not in the graph")
    @test_throws error_exc DFSIterator(g, 3)
    g = path_graph(7)
    add_edge!(g, 6, 3)
    add_edge!(g, 3, 1)
    add_edge!(g, 4, 7)
    g2 = deepcopy(g)
    add_vertex!(g2)
    add_vertex!(g2)
    add_edge!(g2, 8, 9)

    for g in testgraphs(g)
        nodes_visited = fill(0, nv(g))
        for (i, node) in enumerate(DFSIterator(g, 6))
            nodes_visited[i] = node
        end
        @test nodes_visited[1:2] == [6, 3]
        @test any(nodes_visited[3] .== [1, 4])
        if nodes_visited[3] == 1
            @test nodes_visited[4] == 2
            @test nodes_visited[5] == 4
            @test any(nodes_visited[6] .== [5, 7])
            if nodes_visited[6] == 5
                @test nodes_visited[7] == 7
            end
        else
            @test any(nodes_visited[4] .== [5, 7])
            if nodes_visited[4] == 5
                @test nodes_visited[5] == 7
            end
            @test nodes_visited[6] == 1
            @test nodes_visited[7] == 2
        end
    end
    nodes_visited = collect(DFSIterator(g2, [1, 6]))
    @test nodes_visited == [1, 2, 3, 4, 5, 6, 7]
    nodes_visited = collect(DFSIterator(g2, [8, 1, 6]))
    @test nodes_visited == [8, 9, 1, 2, 3, 4, 5, 6, 7]
end
