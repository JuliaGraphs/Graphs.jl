@testset "Iterators" begin
    g = path_graph(7)
    add_edge!(g,6,3)
    add_edge!(g,3,1)
    add_edge!(g,4,7)

    @testset "DFS" begin
        for g in testgraphs(g)
            nodes_visited = fill(0, nv(g))
            for (i, node) in enumerate(DFS(g, 6))
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
    end

    @testset "BFS" begin
        for g in testgraphs(g)
            nodes_visited = fill(0, nv(g))
            for (i, node) in enumerate(BFS(g, 6))
                nodes_visited[i] = node
            end
            @test nodes_visited[1] == 6
            @test any(nodes_visited[2] .== [3, 5, 7])
            if nodes_visited[2] == 3
                @test nodes_visited[3:4] == [5,7] || nodes_visited[3:4] == [7,5]
            elseif nodes_visited[2] == 5
                @test nodes_visited[3:4] == [3,7] || nodes_visited[3:4] == [7,3]
            else
                @test nodes_visited[3:4] == [3,5] || nodes_visited[3:4] == [5,3]
            end
            @test any(nodes_visited[5] .== [1,2,4])
            if nodes_visited[5] == 1
                @test nodes_visited[6:7] == [2,4] || nodes_visited[6:7] == [4,2]
            elseif nodes_visited[5] == 2
                @test nodes_visited[6:7] == [1,4] || nodes_visited[6:7] == [4,1]
            else
                @test nodes_visited[6:7] == [1,2] || nodes_visited[6:7] == [2,1]
            end
        end
    end
