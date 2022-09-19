@testset "DFS" begin
  gnodes_directed=SimpleDiGraph(4)
  gnodes_undirected=SimpleGraph(4)
  gself_loop=SimpleDiGraph(1)
  add_edge!(gself_loop, 1, 1);
  g5 = SimpleDiGraph(4)
  add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
  gx = cycle_digraph(3)
  gcyclic = SimpleGraph([0 1 1 0 0; 1 0 1 0 0; 1 1 0 0 0; 0 0 0 0 1; 0 0 0 1 0])
  gtree = SimpleGraph([0 1 1 1 0 0 0; 1 0 0 0 0 0 0; 1 0 0 0 0 0 0; 1 0 0 0 1 1 1; 0 0 0 1 0 0 0; 0 0 0 1 0 0 0; 0 0 0 1 0 0 0])
  @testset "dfs_tree" begin
    for g in testdigraphs(g5)
      z = @inferred(dfs_tree(g, 1))
      @test ne(z) == 3 && nv(z) == 4
      @test !has_edge(z, 1, 3)
      @test !is_cyclic(g)
    end
  end

  @testset "topological_sort_by_dfs" begin
    for g in testdigraphs(g5)
      @test @inferred(topological_sort_by_dfs(g)) == [1, 2, 3, 4]
    end

    for g in testdigraphs(gx)
      @test @inferred(is_cyclic(g))
      @test_throws ErrorException topological_sort_by_dfs(g)      
    end
  end

  @testset "is_cyclic" begin
    for g in testgraphs(path_graph(2))
      @test !@inferred(is_cyclic(g))
      @test !@inferred(is_cyclic(zero(g)))
    end
    for g in testgraphs(gcyclic)
      @test @inferred(is_cyclic(g))
    end
    for g in testgraphs(gtree)
      @test !@inferred(is_cyclic(g))
    end
    for g in testgraphs(g5)
      @test !@inferred(is_cyclic(g))
    end
    for g in testgraphs(gnodes_directed)
      @test !@inferred(is_cyclic(g))
    end
    for g in testgraphs(gnodes_undirected)
      @test !@inferred(is_cyclic(g))
    end
    for g in testgraphs(gself_loop)
      @test @inferred(is_cyclic(g))
    end
  end

end
