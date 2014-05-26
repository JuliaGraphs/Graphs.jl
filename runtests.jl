
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
    "cliques",
    "random" ]


for t in tests
    tp = joinpath("test", "$(t).jl")
    println("running $(tp) ...")
    include(tp)
end

