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
    "generators" ]


for t in tests
    tp = joinpath(Pkg.dir("Graphs"),"test","$(t).jl")
    println("running $(tp) ...")
    include(tp)
end
