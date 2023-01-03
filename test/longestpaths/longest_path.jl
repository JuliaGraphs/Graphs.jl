@testset "Longest path" begin
    # empty DAG
    g::DiGraph = DiGraph()
    @test dag_longest_path(g) == Vector{Int}()

    # unweighted DAG
    g = DiGraph()
    V::Vector{Int} = Vector{Int}(1:7)
    A = Vector{Tuple{Int, Int}}([(1, 2), (2, 3), (2, 4), (3, 5), (5, 6), (3, 7)])
    [add_vertex!(g) for _ in V]
    [add_edge!(g, edge) for edge in A]
    @test dag_longest_path(g) == Vector{Int}([1, 2, 3, 5, 6])

    # weighted DAG
    g = DiGraph()
    V = Vector{Int}(1:6)
    A = Vector{Tuple{Int, Int, Float64}}([(1, 2, -5), (2, 3, 1), (3, 4, 1), (4, 5, 0), (3, 5, 4), (1, 6, 2)])
    n::Int = length(V)
    distmx::Matrix{Float64} = Matrix{Float64}(undef, n, n)
    [(distmx[i, j] = dist) for (i, j, dist) in A]
    [add_vertex!(g) for _ in V]
    [add_edge!(g, (i, j)) for (i, j, _) in A]
    @test dag_longest_path(g; distmx = distmx) == Vector{Int}([2, 3, 5])
end
