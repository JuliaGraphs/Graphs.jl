SUITE["connectivity"] = BenchmarkGroup([],
                               "graphs" => BenchmarkGroup([]), 
                               "digraphs" => BenchmarkGroup([]), 
                               )

SUITE["connectivity"]["digraphs"]["strongly_connected_components"] = @benchmarkable [Graphs.strongly_connected_components(g) for (_, g) in $DIGRAPHS]

SUITE["connectivity"]["graphs"]["connected_components"] = @benchmarkable [Graphs.connected_components(g) for (_, g) in $GRAPHS]
