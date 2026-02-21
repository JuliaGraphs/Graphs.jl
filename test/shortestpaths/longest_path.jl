@testset "Longest path" begin
    # empty DAG
    g = DiGraph()
    @test dag_longest_path(g) == Int[]

    # unweighted DAG
    g = SimpleDiGraphFromIterator(Edge.([(1, 2), (2, 3), (2, 4), (3, 5), (5, 6), (3, 7)]))
    @test dag_longest_path(g) == [1, 2, 3, 5, 6]

    # weighted DAG
    n = 6
    g = DiGraph(n)
    A = [(1, 2, -5), (2, 3, 1), (3, 4, 1), (4, 5, 0), (3, 5, 4), (1, 6, 2)]
    distmx = fill(NaN, n, n)
    for (i, j, dist) in A
        add_edge!(g, (i, j))
        distmx[i, j] = dist
    end
    @test dag_longest_path(g, distmx) == [2, 3, 5]
end
