using Graphs
using Graphs.Parallel
using Base.Threads: @threads, Atomic
@test length(description()) > 1

tests = [
    "centrality/betweenness",
    "centrality/closeness",
    "centrality/pagerank",
    "centrality/radiality",
    "centrality/stress",
    "distance",
    "shortestpaths/bellman-ford",
    "shortestpaths/dijkstra",
    "shortestpaths/floyd-warshall",
    "shortestpaths/johnson",
    "traversals/bfs",
    "traversals/greedy_color",
    "dominatingset/minimal_dom_set",
    "independentset/maximal_ind_set",
    "vertexcover/random_vertex_cover",
    "utils",
]

@testset "Graphs.Parallel" begin
    for t in tests
        tp = joinpath(testdir, "parallel", "$(t).jl")
        include(tp)
    end
end
