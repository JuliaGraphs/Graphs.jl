using Compat
# import Compat.String

tests = [
    "edgelist",
    "adjlist",
    "bellman_test",
    "inclist",
    "graph",
    "gmatrix",
    "bfs",
    "dfs",
    "conn_comp",
    "dijkstra",
    "a_star_spath",
    "mst",
    "floyd",
    "dot",
    "dot2",
    "cliques",
    "random",
    "generators",
    "maximum_adjacency_visit",
    "issue_related_tests" ]


for t in tests[5:6]
    @show t
    tp = joinpath(dirname(@__FILE__), "$(t).jl")
    println("running $(tp) ...")
    include(tp)
end
