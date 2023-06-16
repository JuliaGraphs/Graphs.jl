@testset "Label propagation" begin
    rng = StableRNG(1)
    n = 10
    g10 = complete_graph(n)
    for g in testgraphs(g10)
        z = copy(g)
        for k in 2:5
            z = blockdiag(z, g)
            add_edge!(z, (k - 1) * n, k * n)
            c, ch = @inferred(label_propagation(z; rng=rng))
            a = collect(n:n:(k * n))
            a = Int[div(i - 1, n) + 1 for i in 1:(k * n)]
            # check the number of communities
            @test length(unique(a)) == length(unique(c))
            # check the partition
            @test a == c
        end
    end
end
