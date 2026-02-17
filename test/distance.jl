@testset "Distance" begin
    g4 = path_digraph(5)
    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    adjmx3 = [0 1 0; 0 0 0; 0 0 0]
    a1 = SimpleGraph(adjmx1)
    a2 = SimpleDiGraph(adjmx2)
    a3 = SimpleDiGraph(adjmx3)
    a4 = blockdiag(complete_graph(5), complete_graph(5));
    add_edge!(a4, 1, 6)
    distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
    distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]

    @testset "$(typeof(g))" for g in test_generic_graphs(a1)
        z = @inferred(eccentricity(g, distmx1))
        @testset "eccentricity" begin
            @test z == [6.2, 4.2, 6.2]
        end
        @testset "diameter" begin
            @test @inferred(diameter(z)) == diameter(g, distmx1) == 6.2
        end
        @testset "periphery" begin
            @test @inferred(periphery(z)) == periphery(g, distmx1) == [1, 3]
        end
        @testset "radius" begin
            @test @inferred(radius(z)) == radius(g, distmx1) == 4.2
        end
        @testset "center" begin
            @test @inferred(center(z)) == center(g, distmx1) == [2]
        end
    end

    @testset "$(typeof(g))" for g in test_generic_graphs(a2)
        z = @inferred(eccentricity(g, distmx2))
        @testset "eccentricity" begin
            @test z == [6.2, 4.2, 6.1]
        end
        @testset "diameter" begin
            @test @inferred(diameter(z)) == diameter(g, distmx2) == 6.2
        end
        @testset "periphery" begin
            @test @inferred(periphery(z)) == periphery(g, distmx2) == [1]
        end
        @testset "radius" begin
            @test @inferred(radius(z)) == radius(g, distmx2) == 4.2
        end
        @testset "center" begin
            @test @inferred(center(z)) == center(g, distmx2) == [2]
        end
    end

    @testset "Disconnected graph diameter" for g in test_generic_graphs(a3)
        @test @inferred(diameter(g)) == typemax(Int)
    end

    @testset "simplegraph diameter" for g in test_generic_graphs(a4)
        @test @inferred(diameter(g)) == 3
    end

    @testset "Empty graph diameter" begin
        @test @inferred(diameter(SimpleGraph(0))) == 0
        @test @inferred(diameter(SimpleDiGraph(0))) == 0
    end

    @testset "iFUB diameter" begin
        # 1. Comparing against large graphs with known diameters  
        n_large = 5000
        g_path = path_graph(n_large)
        @test diameter(g_path) == n_large - 1

        g_cycle = cycle_graph(n_large)
        @test diameter(g_cycle) == floor(Int, n_large / 2)

        g_star = star_graph(n_large)
        @test diameter(g_star) == 2

        # 2. Comparing against the original implementation for random graphs
        function diameter_naive(g)
            return maximum(eccentricity(g))
        end

        NUM_SAMPLES = 50

        for i in 1:NUM_SAMPLES
            # Random unweighted Graphs
            n = rand(10:1000) # Small to Medium size graphs
            p = rand() * 0.1 + 0.005 # Sparse to medium density

            # Undirected Graphs
            g = erdos_renyi(n, p)
            @test diameter(g) == diameter_naive(g)

            ccs = connected_components(g)
            largest_component = ccs[argmax(length.(ccs))]
            g_lscc, _ = induced_subgraph(g, largest_component)

            if nv(g_lscc) > 1
                d_new = @inferred diameter(g_lscc)
                d_ref = diameter_naive(g_lscc)
                @test d_new == d_ref
            end

            # Directed Graphs
            g_dir = erdos_renyi(n, p, is_directed=true)
            @test diameter(g_dir) == diameter_naive(g_dir)

            sccs = strongly_connected_components(g_dir)
            largest_component_directed = sccs[argmax(length.(sccs))]
            g_dir_lscc, _ = induced_subgraph(g_dir, largest_component_directed)

            if nv(g_dir_lscc) > 1
                d_new_dir = @inferred diameter(g_dir_lscc)
                d_ref_dir = diameter_naive(g_dir_lscc)
                @test d_new_dir == d_ref_dir
            end
        end
    end

    @testset "DefaultDistance" begin
        @test size(Graphs.DefaultDistance()) == (typemax(Int), typemax(Int))
        d = @inferred(Graphs.DefaultDistance(3))
        @test size(d) == (3, 3)
        @test d[1, 1] == getindex(d, 1, 1) == 1
        @test d[1:2, 1:2] == Graphs.DefaultDistance(2)
        @test d == transpose(d) == adjoint(d)
        @test sprint(show, d) ==
            stringmime("text/plain", d) ==
            "$(d.nv) × $(d.nv) default distance matrix (value = 1)"
    end

    @testset "warnings and errors" begin
        # ensures that eccentricity only throws an error if there is more than one component
        g1 = GenericGraph(SimpleGraph(2))
        @test_logs (:warn, "Infinite path length detected for vertex 1") match_mode = :any eccentricity(
            g1
        )
        @test_logs (:warn, "Infinite path length detected for vertex 2") match_mode = :any eccentricity(
            g1
        )
        g2 = GenericGraph(path_graph(2))
        @test_logs eccentricity(g2)
    end

    @testset "Weighted Diameter Benchmarks" begin
        n_bench = 3000
        
        function symmetric_weights(n)
            W = rand(n, n)
            return (W + W') / 2
        end

        @testset "Erdős-Rényi (ER) Model" begin
            p = 10 / n_bench
            g = erdos_renyi(n_bench, p)
            while !is_connected(g)
                g = erdos_renyi(n_bench, p)
            end
            
            distmx = symmetric_weights(n_bench)
            
            t_opt = @elapsed d_opt = diameter(g, distmx)
            t_naive = @elapsed d_naive = maximum(eccentricity(g, vertices(g), distmx))
            
            @test d_opt ≈ d_naive
            @info "ER Speedup: $(round(t_naive/t_opt, digits=1))x"
        end

        @testset "Barabási-Albert (BA) Model" begin
            g = barabasi_albert(n_bench, 5)
            while !is_connected(g)
                g = barabasi_albert(n_bench, 5)
            end
            
            distmx = symmetric_weights(n_bench)
            
            t_opt = @elapsed d_opt = diameter(g, distmx)
            t_naive = @elapsed d_naive = maximum(eccentricity(g, vertices(g), distmx))
            
            @test d_opt ≈ d_naive
            @info "BA Speedup: $(round(t_naive/t_opt, digits=3))x"
        end
    end
end