@testset "BFSIterator" begin
    g = Graph()
    error_exc = ErrorException("Some source nodes for the iterator are not in the graph")
    @test_throws error_exc BFSIterator(g, 3)
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
        for (i, node) in enumerate(BFSIterator(g, 6))
            nodes_visited[i] = node
        end
        @test nodes_visited[1] == 6
        @test any(nodes_visited[2] .== [3, 5, 7])
        if nodes_visited[2] == 3
            @test nodes_visited[3:4] == [5, 7] || nodes_visited[3:4] == [7, 5]
        elseif nodes_visited[2] == 5
            @test nodes_visited[3:4] == [3, 7] || nodes_visited[3:4] == [7, 3]
        else
            @test nodes_visited[3:4] == [3, 5] || nodes_visited[3:4] == [5, 3]
        end
        @test any(nodes_visited[5] .== [1, 2, 4])
        if nodes_visited[5] == 1
            @test nodes_visited[6:7] == [2, 4] || nodes_visited[6:7] == [4, 2]
        elseif nodes_visited[5] == 2
            @test nodes_visited[6:7] == [1, 4] || nodes_visited[6:7] == [4, 1]
        else
            @test nodes_visited[6:7] == [1, 2] || nodes_visited[6:7] == [2, 1]
        end
    end
    nodes_visited = collect(BFSIterator(g2, [1, 6]))
    @test nodes_visited == [1, 2, 3, 6, 5, 7, 4]
    nodes_visited = collect(BFSIterator(g2, [8, 1, 6]))
    @test nodes_visited == [8, 9, 1, 2, 3, 6, 5, 7, 4]
end
