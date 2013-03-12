pathname = joinpath("test", "data", "graph1.edgelist")
g = read_edgelist(pathname)
@assert isequal(adjacency_matrix(g), [0 1 1; 0 0 1; 0 0 0;])
