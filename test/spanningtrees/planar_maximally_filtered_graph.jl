@testset "PMFG tests" begin
    k5 = complete_graph(5)
    k5_am = Matrix{Float64}(adjacency_matrix(k5))

    #random weights
    for i in CartesianIndices(k5_am)
        if k5_am[i] == 1
            k5_am[i] = rand()
        end
    end

    #let's make 1->5 very distant 
    k5_am[1, 5] = 10.0
    k5_am[5, 1] = 10.0

    #correct result of PMFG
    correct_am = [
        0 1 1 1 0
        1 0 1 1 1
        1 1 0 1 1
        1 1 1 0 1
        0 1 1 1 0
    ]

    @test correct_am == adjacency_matrix(planar_maximally_filtered_graph(k5, k5_am))

    #type test 
    N = 10
    g = SimpleGraph{Int16}(N)
    X = rand(N, N)
    C = X' * X
    p = planar_maximally_filtered_graph(g, C)
    @test typeof(p) == SimpleGraph{eltype(g)}

    #Test that MST is a subset of the PMFG 
    N = 50
    X = rand(N, N); D = X'*X
    c = complete_graph(N)
    p = planar_maximally_filtered_graph(c, D)
    mst_edges = kruskal_mst(c, D)
    is_subgraph = true 
    for mst_edge in mst_edges
        if mst_edge ∉ edges(p)
            is_subgraph = false
        end
    end
    @test is_subgraph
end