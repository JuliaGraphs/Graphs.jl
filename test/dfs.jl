# Test of Depth-first visit

using Graphs, SparseArrays
using Test

mutable struct GraphTest
    graph_edges::Array{Tuple{Int,Int},1}
    dfs_path::Array{Int,1}
    is_cyclic::Bool
    topo_sort::Array{Int,1}

    GraphTest(gedges, dfspath, iscyclic, toposort) =
        new(gedges, dfspath, iscyclic, toposort)
end

global dir_acyclic = GraphTest(
    [(1,2), (1,3), (1,6), (2,4), (2,5), (3,5), (3,6)],
    [1, 2, 4, 5, 3, 6],
    false,
    [1,3,6,2,5,4])
global undir_acyclic = GraphTest(
    [(1,2), (1,3), (1,6), (2,4), (2,5)],
    [],
    false,
    [1,6,3,2,5,4])
global cyclic  = GraphTest(
    [(1,2), (1,3), (1,6), (2,4), (2,5), (3,5), (3,6), (5,1)],
    [1, 2, 4, 5, 3, 6],
    true,
    [])

global testsets = [
    (true, [dir_acyclic, cyclic]),
    (false, [undir_acyclic, cyclic])]

for tset in testsets
    global (is_dir, graphtests) = tset

    for gtest in graphtests

        global g = simple_inclist(6, is_directed = is_dir)
        map((edg) -> add_edge!(g, edg[1], edg[2]), gtest.graph_edges)

        global gEx = graph(ExVertex[], ExEdge{ExVertex}[], is_directed = is_dir)
        map((x) -> add_vertex!(gEx, "edge:" * string(x)), 1:6)
        global VV = vertices(gEx)
        map((edg) -> add_edge!(gEx, VV[edg[1]], VV[edg[2]]), gtest.graph_edges)


        # DFS traversal
        if !isempty(gtest.dfs_path)
            global vs1 = visited_vertices(g, DepthFirst(), 1)
            @assert vs1 == gtest.dfs_path

            global vs2 = visited_vertices(gEx, DepthFirst(), VV[1])
            @assert vs2 == collect(map((x) -> gEx.vertices[x], gtest.dfs_path))
        end

        # Cyclic test
        @assert test_cyclic_by_dfs(g) == gtest.is_cyclic
        @assert test_cyclic_by_dfs(gEx) == gtest.is_cyclic

        # Topological sort
        if gtest.is_cyclic
            @test_throws ArgumentError topological_sort_by_dfs(g)  # g2 contains a loop
            @test_throws ArgumentError topological_sort_by_dfs(gEx)  # g2 contains a loop

        elseif !isempty(gtest.topo_sort)
            ts = topological_sort_by_dfs(g)
            @assert ts == gtest.topo_sort

            ts = topological_sort_by_dfs(gEx)
            @assert [vertex_index(e,gEx) for e in ts] == gtest.topo_sort
        end
    end
end
