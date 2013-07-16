module Graphs
    using DataStructures
    
    import Base.start, Base.done, Base.next, Base.show
    import Base.length, Base.isempty, Base.getindex, Base.isless
    
    export
        AbstractGraph,
    
        # concept checking
        implements_vertex_list,
        implements_edge_list,
        implements_vertex_map,
        implements_edge_map,
        implements_adjacency_list,
        implements_incidence_list,
        implements_bidirectional_adjacency_list,
        implements_bidirectional_incidence_list,
        implements_adjacency_matrix,
        @graph_implements, @graph_requires,
    
        # common interfaces
        vertex_type, edge_type, source, target, edge, revedge,
        is_directed, is_mutable, vertex_index, edge_index,
        num_vertices, vertices, num_edges, edges, 
        out_degree, out_neighbors, out_edges,
        in_degree, in_neighbors, in_edges,   
        attributes,     
        
        # common
        KeyVertex, Edge, WeightedEdge, ExVertex, ExEdge, AttributeDict,
        collect_edges, collect_weighted_edges,
        
        add_edge!, add_vertex!, add_edges!, add_vertices!,
    
        # adjacency_list
        GenericAdjacencyList, SimpleAdjacencyList, AdjacencyList, 
        simple_adjlist, adjlist,
        
        # incidence_list
        GenericIncidenceList, SimpleIncidenceList, IncidenceList, 
        simple_inclist, inclist,
        
        # graph
        GenericGraph, SimpleGraph, simple_graph, graph,
        
        # gmatrix
        adjacency_matrix, weight_matrix, laplacian_matrix,
        sparse2adjacencylist,
        
        # graph_visit
        AbstractGraphVisitor, TrivialGraphVisitor, LogGraphVisitor,
        discover_vertex!, open_vertex!, close_vertex!,
        examine_neighbor!, examine_edge!, 
        visited_vertices, traverse_graph, traverse_graph_withlog,
        
        # breadth_first_visit
        BreadthFirst, gdistances, gdistances!, 
        
        # depth_first_visit
        DepthFirst, test_cyclic_by_dfs, topological_sort_by_dfs,
        
        # connected_components
        connected_components, strongly_connected_components,
        
        # dijkstra_spath
        DijkstraStates, create_dijkstra_states, AbstractDijkstraVisitor, 
        dijkstra_shortest_paths!, dijkstra_shortest_paths, 
        dijkstra_shortest_paths_withlog, 
        
        # prim_mst
        PrimStates, create_prim_states, AbstractPrimVisitor,
        prim_minimum_spantree!, prim_minimum_spantree, prim_minimum_spantree_withlog,
        
        # kruskal_mst
        kruskal_select, kruskal_minimum_spantree,
        
        # floyd_warshall
        floyd_warshall!, floyd_warshall,
                
        # Graphviz 
        to_dot, plot,
        
        # Random Graph Generation
        erdos_renyi_graph, watts_strogatz_graph
        
    include("concepts.jl")
    include("common.jl")
    
    include("adjacency_list.jl")
    include("incidence_list.jl")
    include("graph.jl")
    include("show.jl")
    include("gmatrix.jl")
    
    include("graph_visit.jl")
    include("breadth_first_visit.jl")
    include("depth_first_visit.jl")
    
    include("connected_components.jl")
    include("dijkstra_spath.jl")
    include("prim_mst.jl")
    include("kruskal_mst.jl")
    include("floyd_warshall.jl")

    include("dot.jl")

    include("random.jl")
end

