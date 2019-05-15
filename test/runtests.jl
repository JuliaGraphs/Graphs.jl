

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
    "issue_related_tests",
    "inclist_dict_delete" ]


for t in tests
    tp = joinpath(dirname(@__FILE__), "$(t).jl")
    println("running $(tp) ...")
    include(tp)
end
