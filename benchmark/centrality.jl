
@benchgroup "centrality" begin
  @benchgroup "graphs" begin
    for (name, g) in GRAPHS
      @bench "$(name): degree" Graphs.degree_centrality($g)
      @bench "$(name): closeness" Graphs.closeness_centrality($g)
      if nv(g) < 1000
        @bench "$(name): betweenness" Graphs.betweenness_centrality($g)
        @bench "$(name): katz" Graphs.katz_centrality($g)
      end
    end
  end #graphs
  @benchgroup "digraphs" begin
    for (name, g) in DIGRAPHS
      @bench "$(name): degree" Graphs.degree_centrality($g)
      @bench "$(name): closeness" Graphs.closeness_centrality($g)
      if nv(g) < 1000
        @bench "$(name): betweenness" Graphs.betweenness_centrality($g)
        @bench "$(name): katz" Graphs.katz_centrality($g)
      end
      if nv(g) < 500
        @bench "$(name): pagerank"  Graphs.pagerank($g)
      end
    end
  end # digraphs
end # centrality
