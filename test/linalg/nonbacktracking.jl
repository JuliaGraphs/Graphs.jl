using SparseArrays

@testset "nonbacktracking" begin
    # Case: simple undirected
    ug = path_graph(5)
    B, edgemap = non_backtracking_matrix(ug)
    #      | 1->2 | 2->3 | 3->4 | 4->5 | 2->1 | 3->2 | 4->3 | 5->4
    # -------------------------------------------------------------
    # 1->2 |    0 |    1 |    0 |    0 |    0 |    0 |    0 |    0
    # 2->3 |    0 |    0 |    1 |    0 |    0 |    0 |    0 |    0
    # 3->4 |    0 |    0 |    0 |    1 |    0 |    0 |    0 |    0
    # 4->5 |    0 |    0 |    0 |    0 |    0 |    0 |    0 |    0
    # 2->1 |    0 |    0 |    0 |    0 |    0 |    0 |    0 |    0
    # 3->2 |    0 |    0 |    0 |    0 |    1 |    0 |    0 |    0
    # 4->3 |    0 |    0 |    0 |    0 |    0 |    1 |    0 |    0
    # 5->4 |    0 |    0 |    0 |    0 |    0 |    0 |    1 |    0
    B_ = [
        0 1 0 0 0 0 0 0
        0 0 1 0 0 0 0 0
        0 0 0 1 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 1 0 0 0
        0 0 0 0 0 1 0 0
        0 0 0 0 0 0 1 0
    ]
    egs = Edge.([(1, 2), (2, 3), (3, 4), (4, 5), (2, 1), (3, 2), (4, 3), (5, 4)])
    indices = getindex.(Ref(edgemap), egs)
    @test typeof(B) <: SparseMatrixCSC
    @test all(B[indices, indices] .== B_)

    # Case: simple directed
    dg = SimpleDiGraph(5)
    add_edge!(dg, 1, 2)
    add_edge!(dg, 2, 3)
    add_edge!(dg, 1, 3)
    add_edge!(dg, 3, 4)
    add_edge!(dg, 3, 5)
    add_edge!(dg, 4, 3)
    B, edgemap = non_backtracking_matrix(dg)
    #      | 1->2 | 1->3 | 2->3 | 3->4 | 3->5 | 4->3
    # -----------------------------------------------
    # 1->2 |    0 |    0 |    1 |    0 |    0 |    0
    # 1->3 |    0 |    0 |    0 |    1 |    1 |    0
    # 2->3 |    0 |    0 |    0 |    1 |    1 |    0
    # 3->4 |    0 |    0 |    0 |    0 |    0 |    0
    # 3->5 |    0 |    0 |    0 |    0 |    0 |    0
    # 4->3 |    0 |    0 |    0 |    0 |    1 |    0
    B_ = [
        0 0 1 0 0 0
        0 0 0 1 1 0
        0 0 0 1 1 0
        0 0 0 0 0 0
        0 0 0 0 0 0
        0 0 0 0 1 0
    ]
    egs = Edge.([(1, 2), (1, 3), (2, 3), (3, 4), (3, 5), (4, 3)])
    indices = getindex.(Ref(edgemap), egs)
    @test typeof(B) <: SparseMatrixCSC
    @test all(B[indices, indices] .== B_)
end
