@testset "Randgraphs" begin
    rng = StableRNG(1)

    @testset "(Int, Int)" begin
        r1 = SimpleGraph(10, 20; rng=rng)
        r2 = SimpleDiGraph(5, 10; rng=rng)
        @test nv(r1) == 10
        @test ne(r1) == 20
        @test nv(r2) == 5
        @test ne(r2) == 10
        @test eltype(r1) == Int
        @test eltype(r2) == Int

        @test SimpleGraph(10, 20; rng=StableRNG(3)) == SimpleGraph(10, 20; rng=StableRNG(3))
        @test SimpleGraph(10, 40; rng=StableRNG(3)) == SimpleGraph(10, 40; rng=StableRNG(3))
        @test SimpleDiGraph(10, 20; rng=StableRNG(3)) ==
            SimpleDiGraph(10, 20; rng=StableRNG(3))
        @test SimpleDiGraph(10, 80; rng=StableRNG(3)) ==
            SimpleDiGraph(10, 80; rng=StableRNG(3))
        @test SimpleGraph(10, 20; rng=StableRNG(3)) ==
            erdos_renyi(10, 20; rng=rng = StableRNG(3))
        @test ne(Graph(10, 40; rng=StableRNG(3))) == 40
        @test ne(DiGraph(10, 80; rng=StableRNG(3))) == 80
    end

    @testset "(UInt8, Mixed) eltype" begin
        @test eltype(Graph(0x5, 0x2; rng=rng)) == eltype(Graph(0x5, 2; rng=rng)) == UInt8
    end

    @testset "(Graph{$T}(Int, Int) eltype" for T in [
        UInt8, Int8, UInt16, Int16, UInt32, Int32, UInt, Int
    ]
        @test eltype(Graph{T}(5, 2; rng=rng)) == T
        @test eltype(DiGraph{T}(5, 2; rng=rng)) == T
        @test eltype(Graph{T}(5, 8; rng=rng)) == T
        @test eltype(DiGraph{T}(5, 8; rng=rng)) == T
    end

    @testset "Erdös-Renyí" begin
        er = erdos_renyi(10, 0.5; rng=rng)
        @test nv(er) == 10
        @test is_directed(er) == false
        er = erdos_renyi(10, 0.5; is_directed=true, rng=rng)
        @test nv(er) == 10
        @test is_directed(er) == true

        er = erdos_renyi(10, 0.5; rng=StableRNG(17))
        @test nv(er) == 10
        @test is_directed(er) == false

        @test erdos_renyi(5, 1.0; rng=rng) == complete_graph(5)
        @test erdos_renyi(5, 1.0; is_directed=true, rng=rng) == complete_digraph(5)
        @test erdos_renyi(5, 2.1; rng=rng) == complete_graph(5)
        @test erdos_renyi(5, 2.1; is_directed=true, rng=rng) == complete_digraph(5)

        # issue #173
        er = erdos_renyi(4, 6; seed=1)
        @test nv(er) == 4
        @test ne(er) == 6
    end

    @testset "expected degree" begin
        cl = expected_degree_graph(zeros(10); rng=StableRNG(17))
        @test nv(cl) == 10
        @test ne(cl) == 0
        @test is_directed(cl) == false

        cl = expected_degree_graph([3, 2, 1, 2]; rng=StableRNG(17))
        @test nv(cl) == 4
        @test is_directed(cl) == false

        cl = expected_degree_graph(fill(99, 100); rng=StableRNG(17))
        @test nv(cl) == 100
        @test all(degree(cl) .> 90)
    end

    @testset "Watts-Strogatz" begin
        ws = watts_strogatz(10, 4, 0.2; rng=rng)
        @test nv(ws) == 10
        @test ne(ws) == 20
        @test is_directed(ws) == false

        ws = watts_strogatz(10, 4, 0.2; is_directed=true, rng=rng)
        @test nv(ws) == 10
        @test ne(ws) == 20
        @test is_directed(ws) == true
    end

    @testset "Newman-Watts-Strogatz" begin
        # Each iteration creates, on average, n*k/2*(1+β) edges (if the network is large enough).
        # As such, we need to average to check if the function works.
        nsamp = 100
        n = 1000
        β = 0.2
        k = 4
        mean_num_edges = n * k / 2 * (1 + β)
        nes = 0
        for i in 1:nsamp
            nws = newman_watts_strogatz(n, k, β; rng=rng)
            nes += ne(nws)
            @test nv(nws) == n
            @test is_directed(nws) == false
        end
        @test abs(sum(nes) / nsamp - mean_num_edges) / mean_num_edges < 0.01

        nes = 0
        for i in 1:nsamp
            nws = newman_watts_strogatz(n, k, β; is_directed=true, rng=rng)
            nes += ne(nws)
            @test nv(nws) == n
            @test is_directed(nws) == true
        end
        @test abs(sum(nes) / nsamp - mean_num_edges) / mean_num_edges < 0.01
    end

    @testset "Barabasi-Albert" begin
        ba = barabasi_albert(10, 2; rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 16
        @test is_directed(ba) == false

        ba = barabasi_albert(10, 2, 2; rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 16
        @test is_directed(ba) == false

        ba = barabasi_albert(10, 4, 2; rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 12
        @test is_directed(ba) == false

        ba = barabasi_albert(10, 2; complete=true, rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 17
        @test is_directed(ba) == false

        ba = barabasi_albert(10, 2, 2; complete=true, rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 17
        @test is_directed(ba) == false

        ba = barabasi_albert(10, 4, 2; complete=true, rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 18
        @test is_directed(ba) == false

        ba = barabasi_albert(10, 2; is_directed=true, rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 16
        @test is_directed(ba) == true

        ba = barabasi_albert(10, 2, 2; is_directed=true, rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 16
        @test is_directed(ba) == true

        ba = barabasi_albert(10, 4, 2; is_directed=true, rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 12
        @test is_directed(ba) == true

        ba = barabasi_albert(10, 2; is_directed=true, complete=true, rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 18
        @test is_directed(ba) == true

        ba = barabasi_albert(10, 2, 2; is_directed=true, complete=true, rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 18
        @test is_directed(ba) == true

        ba = barabasi_albert(10, 4, 2; is_directed=true, complete=true, rng=rng)
        @test nv(ba) == 10
        @test ne(ba) == 24
        @test is_directed(ba) == true
    end

    @testset "static fitness" begin
        fm = static_fitness_model(20, rand(10); rng=rng)
        @test nv(fm) == 10
        @test ne(fm) == 20
        @test is_directed(fm) == false

        fm = static_fitness_model(20, rand(10), rand(10); rng=rng)
        @test nv(fm) == 10
        @test ne(fm) == 20
        @test is_directed(fm) == true
    end

    @testset "static scale-free" begin
        sf = static_scale_free(10, 20, 2.0; rng=rng)
        @test nv(sf) == 10
        @test ne(sf) == 20
        @test is_directed(sf) == false

        sf = static_scale_free(10, 20, 2.0, 2.0; rng=rng)
        @test nv(sf) == 10
        @test ne(sf) == 20
        @test is_directed(sf) == true
    end

    @testset "random regular" begin
        rr = random_regular_graph(5, 0; rng=rng)
        @test nv(rr) == 5
        @test ne(rr) == 0
        @test is_directed(rr) == false

        rd = random_regular_digraph(10, 0; rng=rng)
        @test nv(rd) == 10
        @test ne(rd) == 0
        @test is_directed(rd)

        rr = random_regular_graph(10, 8; rng=StableRNG(4))
        @test nv(rr) == 10
        @test ne(rr) == 40
        @test is_directed(rr) == false
        for v in vertices(rr)
            @test degree(rr, v) == 8
        end

        rr = random_regular_graph(1000, 50; rng=rng)
        @test nv(rr) == 1000
        @test ne(rr) == 25000
        @test is_directed(rr) == false
        for v in vertices(rr)
            @test degree(rr, v) == 50
        end
        rd = random_regular_digraph(1000, 4; rng=rng)
        @test nv(rd) == 1000
        @test ne(rd) == 4000
        @test is_directed(rd)
        outdegree_rd = @inferred(outdegree(rd))
        @test all(outdegree_rd .== outdegree_rd[1])

        rd = random_regular_digraph(1000, 4; dir=:in, rng=rng)
        @test nv(rd) == 1000
        @test ne(rd) == 4000
        @test is_directed(rd)
        indegree_rd = @inferred(indegree(rd))
        @test all(indegree_rd .== indegree_rd[1])

        rd = random_regular_digraph(10, 8; dir=:out, rng=StableRNG(4))
        @test nv(rd) == 10
        @test ne(rd) == 80
        @test is_directed(rd)
    end

    @testset "uniform trees" begin
        t = uniform_tree(50; rng=rng)
        @test nv(t) == 50
        @test ne(t) == 49
        @test is_tree(t)

        t2 = uniform_tree(50; rng=StableRNG(4))
        @test nv(t2) == 50
        @test ne(t2) == 49
        @test is_tree(t2)
    end

    @testset "random configuration model" begin
        rr = random_configuration_model(10, repeat([2, 4], 5); rng=StableRNG(3))
        @test nv(rr) == 10
        @test ne(rr) == 15
        @test is_directed(rr) == false
        num2 = 0
        num4 = 0
        for v in vertices(rr)
            d = degree(rr, v)
            @test d == 2 || d == 4
            d == 2 ? num2 += 1 : num4 += 1
        end
        @test num4 == 5
        @test num2 == 5

        rr = random_configuration_model(1000, zeros(Int, 1000); rng=rng)
        @test nv(rr) == 1000
        @test ne(rr) == 0
        @test is_directed(rr) == false

        rr = random_configuration_model(3, [2, 2, 2]; check_graphical=true, rng=rng)
        @test nv(rr) == 3
        @test ne(rr) == 3
        @test is_directed(rr) == false
    end

    @testset "random tournament" begin
        rt = random_tournament_digraph(10; rng=rng)
        @test nv(rt) == 10
        @test ne(rt) == 45
        @test is_directed(rt)
        @test all(degree(rt) .== 9)
        Edges = edges(rt)
        for i in 1:10, j in 1:10
            if i != j
                edge = Edge(i, j)
                @test xor(edge ∈ Edges, reverse(edge) ∈ Edges)
            end
        end
    end

    @testset "SBM" begin
        g = stochastic_block_model(2.0, 3.0, [100, 100]; rng=rng)
        @test 4.0 < mean(degree(g)) < 6.0
        g = stochastic_block_model(3.0, 4.0, [100, 100, 100]; rng=rng)
        @test 10.0 < mean(degree(g)) < 12.0

        function generate_nbp_sbm(numedges, sizes)
            density = 1
            between = density * 0.90
            intra = density * -0.005
            noise = density * 0.00501
            sbm = nearbipartiteSBM(sizes, between, intra, noise)
            edgestream = make_edgestream(sbm; rng=rng)
            g = SimpleGraph(sum(sizes), numedges, edgestream)
            return sbm, g
        end

        function test_sbm(sbm, bp)
            @test sum(sbm.affinities) != NaN
            @test all(sbm.affinities .> 0)
            @test sum(sbm.affinities) != 0
            @test all(bp .>= 0)
            @test all(bp .!= NaN)
        end

        numedges = 100
        sizes = [10, 10, 10, 10]

        n = sum(sizes)
        sbm, g = generate_nbp_sbm(numedges, sizes)
        @test ne(g) >= 0.9numedges
        bc = blockcounts(sbm, g)
        bp = blockfractions(sbm, g) ./ (sizes * sizes')
        ratios = bp ./ (sbm.affinities ./ sum(sbm.affinities))
        test_sbm(sbm, bp)
        @test norm(collect(ratios)) < 0.25

        sizes = [200, 200, 100]
        internaldeg = 15
        externaldeg = 6
        internalp = Float64[internaldeg / i for i in sizes]
        externalp = externaldeg / sum(sizes)
        numedges = internaldeg + externaldeg #+ sum(externaldeg.*sizes[2:end])
        numedges *= div(sum(sizes), 2)
        sbm = StochasticBlockModel(internalp, externalp, sizes)

        g = SimpleGraph(sum(sizes), numedges, sbm; rng=rng)
        @test ne(g) >= 0.9numedges
        @test ne(g) <= numedges
        @test nv(g) == sum(sizes)
        bc = blockcounts(sbm, g)
        bp = blockfractions(sbm, g) ./ (sizes * sizes')
        test_sbm(sbm, bp)
        ratios = bp ./ (sbm.affinities ./ sum(sbm.affinities))
        @test norm(collect(ratios)) < 0.25

        # check that average degree is not too high
        # factor of two is cushion for random process
        @test mean(degree(g)) <= 4//2 * numedges / sum(sizes)
        # check that the internal degrees are higher than the external degrees
        # 5//4 is cushion for random process.
        @test all(sum(bc - diagm(0 => diag(bc)); dims=1) .<= 5//4 .* diag(bc))

        sbm2 = StochasticBlockModel(0.5 * ones(4), 0.3, 10 * ones(Int, 4))
        sbm = StochasticBlockModel(0.5, 0.3, 10, 4)
        @test sbm == sbm2
        sbm.affinities[1, 1] = 0
        @test sbm != sbm2
    end

    @testset "Kronecker" begin
        kg = @inferred kronecker(5, 5, rng=rng)
        @test nv(kg) == 32
        @test is_directed(kg)
    end

    @testset "Dorogovtsev-Mendes" begin
        g = @inferred(dorogovtsev_mendes(10, rng=rng))
        @test nv(g) == 10 && ne(g) == 17
        g = dorogovtsev_mendes(11; rng=rng)
        @test nv(g) == 11 && ne(g) == 19
        @test δ(g) == 2
        g = dorogovtsev_mendes(3; rng=rng)
        @test nv(g) == 3 && ne(g) == 3
        @test δ(g) == 2 && Δ(g) == 2

        # Testing that n=4 graph is one on the possible graphs
        g = dorogovtsev_mendes(4; rng=rng)
        @test has_edge(g, 1, 2) &&
            has_edge(g, 1, 3) &&
            has_edge(g, 2, 3) &&
            (
                has_edge(g, 1, 4) && has_edge(g, 2, 4) ||
                has_edge(g, 2, 4) && has_edge(g, 3, 4) ||
                has_edge(g, 1, 4) && has_edge(g, 3, 4)
            )

        # testing domain errors
        @test_throws DomainError dorogovtsev_mendes(2, rng=rng)
        @test_throws DomainError dorogovtsev_mendes(-1, rng=rng)
    end

    @testset "random orientation DAG" begin
        # testing if returned graph is acyclic and valid SimpleGraph
        rog = random_orientation_dag(SimpleGraph(5, 10; rng=rng); rng=rng)
        @test isvalid_simplegraph(rog)
        @test !is_cyclic(rog)

        # testing if returned graph is acyclic and valid ComplexGraph
        rog2 = random_orientation_dag(complete_graph(5); rng=rng)
        @test isvalid_simplegraph(rog2)
        @test !is_cyclic(rog2)

        # testing with abstract RNG
        rog3 = random_orientation_dag(SimpleGraph(10, 15; rng=rng); rng=rng)
        @test isvalid_simplegraph(rog3)
        @test !is_cyclic(rog3)
    end

    @testset "randbn" begin
        for i in 0:10
            @test Graphs.SimpleGraphs.randbn(i, 0.0; rng=rng) == 0
            @test Graphs.SimpleGraphs.randbn(i, 1.0; rng=rng) == i
        end
        N = 30
        s1 = zeros(N)
        s2 = zeros(N)
        for i in 1:N
            s1[i] = Graphs.SimpleGraphs.randbn(5, 0.3)
            s2[i] = Graphs.SimpleGraphs.randbn(3, 0.7)
        end
        μ1 = mean(s1)
        μ2 = mean(s2)
        sv1 = std(s1)
        sv2 = std(s2)
        @test μ1 - sv1 <= 0.3 * 5 <= μ1 + sv1 # since the stdev of μ1 is around sv1/sqrt(N), this should rarely fail
        @test μ2 - sv2 <= 0.7 * 3 <= μ2 + sv2
    end
end
