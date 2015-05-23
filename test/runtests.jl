using Compat

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
    "random",
    "generators",
    "maximum_adjacency_visit" ]


for t in tests
    tp = joinpath(dirname(@__FILE__), "$(t).jl")
    println("running $(tp) ...")
    include(tp)
end
