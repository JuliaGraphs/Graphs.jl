@benchgroup "connectivity" begin
  @benchgroup "digraphs" begin
    for (name, g) in DIGRAPHS
      @bench "$(name): strongly_connected_components" Graphs.strongly_connected_components($g)
    end
  end # digraphs
  @benchgroup "graphs" begin
    for (name, g) in GRAPHS
        @bench "$(name): connected_components" Graphs.connected_components($g)
    end
  end # graphs
end # connectivity
