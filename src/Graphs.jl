module Graphs
    using DataStructures
    
    import Base.start, Base.done, Base.next
    import Base.length, Base.isempty, Base.getindex
    
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
        vertex_type, edge_type, source, target, edge, 
        is_directed, is_mutable, vertex_index, edge_index,
        num_vertices, vertices, num_edges, edges, 
        out_degree, out_neighbors, out_edges,
        in_degree, in_neighbors, in_edges,        
        
        # common
        Edge, IndexedEdge, XEdge, IndexedXEdge,
        
        add_edge!, add_vertex!, add_edges!, add_vertices!,
    
        # adjacency_list
        AdjacencyList, adjacency_list, 
        directed_adjacency_list, undirected_adjacency_list,
        
        # incidence_list
        IncidenceList, incidence_list, 
        directed_incidence_list, undirected_incidence_list,
        
        # graph_visit
        AbstractGraphVisitor,
        discover_vertex!, open_vertex!, close_vertex!,
        examine_neighbor!, examine_edge!, 
        visited_vertices, traverse_graph_withlog,
        
        # breadth_first_visit
        BreadthFirst, gdistances, gdistances!, 
        
        # depth_first_visit
        DepthFirst, test_cyclic_by_dfs, topological_sort_by_dfs,
        
        # dijkstra_spath
        DijkstraStates, create_dijkstra_states, AbstractDijkstraVisitor, 
        dijkstra_shortest_paths!, dijkstra_shortest_paths, 
        dijkstra_shortest_paths_withlog
                
        
    include("concepts.jl")
    include("common.jl")
    
    include("adjacency_list.jl")
    include("incidence_list.jl")
    
    include("graph_visit.jl")
    include("breadth_first_visit.jl")
    include("depth_first_visit.jl")
    
    include("dijkstra_spath.jl")
end
