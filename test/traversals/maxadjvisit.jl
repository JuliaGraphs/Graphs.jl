
@testset "Max adj visit" begin
    gx = SimpleGraph(8)

    # Test of Min-Cut and maximum adjacency visit
    # Original example by Stoer

    wedges = [
        (1, 2, 2.0),
        (1, 5, 3.0),
        (2, 3, 3.0),
        (2, 5, 2.0),
        (2, 6, 2.0),
        (3, 4, 4.0),
        (3, 7, 2.0),
        (4, 7, 2.0),
        (4, 8, 2.0),
        (5, 6, 3.0),
        (6, 7, 1.0),
        (7, 8, 3.0),
    ]

    m = length(wedges)
    eweights = spzeros(nv(gx), nv(gx))

    for (s, d, w) in wedges
        add_edge!(gx, s, d)
        eweights[s, d] = w
        eweights[d, s] = w
    end
    for g in testgraphs(gx)
        @test nv(g) == 8
        @test ne(g) == m

        parity, bestcut = @inferred(mincut(g, eweights))
        if parity[1] == 2
            parity .= 3 .- parity
        end

        @test length(parity) == 8
        @test parity == [1, 1, 2, 2, 1, 1, 2, 2]
        @test bestcut == 4.0

        parity, bestcut = @inferred(mincut(g))

        @test length(parity) == 8
        @test bestcut == 2.0

        v = @inferred(maximum_adjacency_visit(g))
        @test v == Vector{Int64}([1, 2, 5, 6, 3, 7, 4, 8])
    end

    g1 = SimpleGraph(1)
    for g in testgraphs(g1)
        @test @inferred(maximum_adjacency_visit(g)) == collect(vertices(g))
        @test @inferred(mincut(g)) == ([1], zero(eltype(g)))
    end
    @test maximum_adjacency_visit(gx, 1) == [1, 2, 5, 6, 3, 7, 4, 8]
    @test maximum_adjacency_visit(gx, 3) == [3, 2, 7, 4, 6, 8, 5, 1]

    # non regression test for #64
    g = clique_graph(4, 2)
    w = zeros(Int, 8, 8)
    for e in edges(g)
        if src(e) in [1, 5] || dst(e) in [1, 5]
            w[src(e), dst(e)] = 3
        else
            w[src(e), dst(e)] = 2
        end
        w[dst(e), src(e)] = w[src(e), dst(e)]
    end
    w[1, 5] = 6
    w[5, 1] = 6
    parity, bestcut = @inferred(mincut(g, w))
    if parity[1] == 2
        parity .= 3 .- parity
    end
    @test parity == [1, 1, 1, 1, 2, 2, 2, 2]
    @test bestcut == 6

    w[6, 7] = -1
    @test_throws DomainError mincut(g, w)
end
