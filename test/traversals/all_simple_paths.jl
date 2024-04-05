@testset "All simple paths" begin
    # single path
    g = path_graph(4)
    paths = all_simple_paths(g, 1, 4)
    @test Set(paths) == Set(collect(paths)) == Set([[1, 2, 3, 4]])

    # printing
    @test sprint(show, paths) == "SimplePathIterator{SimpleGraph{Int64}}(1 → 4)"

    # complete graph with cutoff
    g = complete_graph(4)
    @test Set(all_simple_paths(g, 1, 4; cutoff=2)) == Set([[1, 2, 4], [1, 3, 4], [1, 4]])

    # two paths
    g = path_graph(4)
    add_vertex!(g)
    add_edge!(g, 3, 5)
    paths = all_simple_paths(g, 1, [4, 5])
    @test Set(paths) == Set([[1, 2, 3, 4], [1, 2, 3, 5]])
    @test Set(collect(paths)) == Set([[1, 2, 3, 4], [1, 2, 3, 5]]) # check `collect` also

    # two paths, with one beyond a cut-off
    g = path_graph(4)
    add_vertex!(g)
    add_edge!(g, 3, 5)
    add_vertex!(g)
    add_edge!(g, 5, 6)
    paths = all_simple_paths(g, 1, [4, 6])
    @test Set(paths) == Set([[1, 2, 3, 4], [1, 2, 3, 5, 6]])
    paths = all_simple_paths(g, 1, [4, 6]; cutoff=3)
    @test Set(paths) == Set([[1, 2, 3, 4]])

    # two targets in line emits two paths
    g = path_graph(4)
    add_vertex!(g)
    paths = all_simple_paths(g, 1, [3, 4])
    @test Set(paths) == Set([[1, 2, 3], [1, 2, 3, 4]])

    # two paths digraph
    g = SimpleDiGraph(5)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 3, 5)
    paths = all_simple_paths(g, 1, [4, 5])
    @test Set(paths) == Set([[1, 2, 3, 4], [1, 2, 3, 5]])

    # two paths digraph with cutoff
    g = SimpleDiGraph(5)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 3, 5)
    paths = all_simple_paths(g, 1, [4, 5]; cutoff=3)
    @test Set(paths) == Set([[1, 2, 3, 4], [1, 2, 3, 5]])

    # digraph with a cycle
    g = SimpleDiGraph(4)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 1)
    add_edge!(g, 2, 4)
    paths = all_simple_paths(g, 1, 4)
    @test Set(paths) == Set([[1, 2, 4]])

    # digraph with a cycle; paths with two targets share a node in the cycle
    g = SimpleDiGraph(4)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 1)
    add_edge!(g, 2, 4)
    paths = all_simple_paths(g, 1, [3, 4])
    @test Set(paths) == Set([[1, 2, 3], [1, 2, 4]])

    # another digraph with a cycle; check cycles are excluded, regardless of cutoff
    g = SimpleDiGraph(6)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 4, 5)
    add_edge!(g, 5, 2)
    add_edge!(g, 5, 6)
    paths = all_simple_paths(g, 1, 6)
    paths′ = all_simple_paths(g, 1, 6; cutoff=typemax(Int))
    @test Set(paths) == Set(paths′) == Set([[1, 2, 3, 4, 5, 6]])

    # same source and target vertex
    g = path_graph(4)
    @test Set(all_simple_paths(g, 1, 1)) == Set([[1]])
    @test Set(all_simple_paths(g, 3, 3)) == Set([[3]])
    @test Set(all_simple_paths(g, 1, [1, 1])) == Set([[1]])
    @test Set(all_simple_paths(g, 1, [1, 4])) == Set([[1], [1, 2, 3, 4]])

    # cutoff prunes paths (note: maximum path length below is `nv(g) - 1`)
    g = complete_graph(4)
    paths = all_simple_paths(g, 1, 2; cutoff=1)
    @test Set(paths) == Set([[1, 2]])

    paths = all_simple_paths(g, 1, 2; cutoff=2)
    @test Set(paths) == Set([[1, 2], [1, 3, 2], [1, 4, 2]])

    # nontrivial graph
    g = SimpleDiGraph(6)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 4, 5)

    add_edge!(g, 1, 6)
    add_edge!(g, 2, 6)
    add_edge!(g, 2, 4)
    add_edge!(g, 6, 5)
    add_edge!(g, 5, 3)
    add_edge!(g, 5, 4)

    paths = all_simple_paths(g, 2, [3, 4])
    @test Set(paths) == Set([
        [2, 3], [2, 4, 5, 3], [2, 6, 5, 3], [2, 4], [2, 3, 4], [2, 6, 5, 4], [2, 6, 5, 3, 4]
    ])

    paths = all_simple_paths(g, 2, [3, 4]; cutoff=3)
    @test Set(paths) ==
        Set([[2, 3], [2, 4, 5, 3], [2, 6, 5, 3], [2, 4], [2, 3, 4], [2, 6, 5, 4]])

    paths = all_simple_paths(g, 2, [3, 4]; cutoff=2)
    @test Set(paths) == Set([[2, 3], [2, 4], [2, 3, 4]])
end
