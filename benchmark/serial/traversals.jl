SUITE["traversals"] = BenchmarkGroup([],
                               "graphs" => BenchmarkGroup([]), 
                               "digraphs" => BenchmarkGroup([]), 
                               )

SUITE["traversals"]["graphs"]["bfs_tree"] = @benchmarkable [Graphs.bfs_tree(g, 1) for (_, g) in $GRAPHS]
SUITE["traversals"]["graphs"]["dfs_tree"] = @benchmarkable [Graphs.dfs_tree(g, 1) for (_, g) in $GRAPHS]

SUITE["traversals"]["digraphs"]["bfs_tree"] = @benchmarkable [Graphs.bfs_tree(g, 1) for (_, g) in $DIGRAPHS]
SUITE["traversals"]["digraphs"]["dfs_tree"] = @benchmarkable [Graphs.dfs_tree(g, 1) for (_, g) in $DIGRAPHS]

