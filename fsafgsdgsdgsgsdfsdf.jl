    g4 = path_digraph(5)
    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    adjmx3 = [0 1 0; 0 0 0; 0 0 0]
    a1 = SimpleGraph(adjmx1)
    a2 = SimpleDiGraph(adjmx2)
    a3 = SimpleDiGraph(adjmx3)
    a4 = blockdiag(complete_graph(5), complete_graph(5));
    add_edge!(a4, 1, 6)
    distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
    distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]

for g in test_generic_graphs(a4)
            @test @inferred(diameter(g)) == 3
end

        g_di = SimpleDiGraph(3)
        add_edge!(g_di, 1, 2)
        add_edge!(g_di, 2, 3)
        add_edge!(g_di, 3, 1)
        distmx_di = [Inf 1.5 Inf; Inf Inf 2.5; Inf Inf Inf]
        diameter(g_di, distmx_di)