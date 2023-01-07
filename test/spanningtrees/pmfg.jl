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

    @test correct_am == Matrix(adjacency_matrix(planar_maximally_filtered_graph(k5; distmx=k5_am)))
end
