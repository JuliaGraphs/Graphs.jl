@testset "Greedy modularity: karate club" begin
    g = smallgraph(:karate)

    expected_c = [1, 2, 2, 2, 1, 1, 1, 2, 3, 2, 1, 1, 2, 2, 3, 3, 1, 2, 3, 1, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]
    expected_q = 0.3806706114398422

    c = community_detection_greedy_modularity(g)

    @test c == expected_c

    @test modularity(g, c) ≈ expected_q

end