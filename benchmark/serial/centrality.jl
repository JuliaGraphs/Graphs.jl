SUITE["centrality"] = BenchmarkGroup([],
                               "graphs" => BenchmarkGroup([]), 
                               "digraphs" => BenchmarkGroup([]), 
                               )

# graphs
SUITE["centrality"]["graphs"]["degree_centrality"] = @benchmarkable [Graphs.degree_centrality(g) for (_, g) in $GRAPHS]
SUITE["centrality"]["graphs"]["closeness_centrality"] = @benchmarkable [Graphs.closeness_centrality(g) for (_, g) in $GRAPHS]
# if nv(g) < 1000 is needed ?
SUITE["centrality"]["graphs"]["betweenness_centrality"] = @benchmarkable [Graphs.betweenness_centrality(g) for (_, g) in $GRAPHS]
SUITE["centrality"]["graphs"]["katz_centrality"] = @benchmarkable [Graphs.katz_centrality(g) for (_, g) in $GRAPHS]

#digraphs
SUITE["centrality"]["digraphs"]["degree_centrality"] = @benchmarkable [Graphs.degree_centrality(g) for (_, g) in $DIGRAPHS]
SUITE["centrality"]["digraphs"]["closeness_centrality"] = @benchmarkable [Graphs.closeness_centrality(g) for (_, g) in $DIGRAPHS]
# if nv(g) < 1000 is needed ?
SUITE["centrality"]["digraphs"]["betweenness_centrality"] = @benchmarkable [Graphs.betweenness_centrality(g) for (_, g) in $DIGRAPHS]
SUITE["centrality"]["digraphs"]["katz_centrality"] = @benchmarkable [Graphs.katz_centrality(g) for (_, g) in $DIGRAPHS]
# if nv(g) < 500 is needed ?
SUITE["centrality"]["digraphs"]["pagerank"] = @benchmarkable [Graphs.pagerank(g) for (_, g) in $DIGRAPHS]
