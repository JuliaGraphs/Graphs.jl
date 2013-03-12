module Graphs
    
    export
    
        # common interfaces
        vertex_type, edge_type, source, target, edge, 
        is_directed, is_mutable,
        num_vertices, vertices, num_edges, edges, 
        out_degree, out_neighbors, out_edges,
        in_degree, in_neighbors, in_edges,
        
        add_edge!, add_vertex!, add_edges!, add_vertices!,
    
        # adjacency_list
        SimpleAdjacencyList
        
    include("concepts.jl")
    include("adjacency_list.jl")
end
