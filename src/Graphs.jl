isdefined(Base, :__precompile__) && __precompile__()

module Graphs
using DataStructures
using SparseArrays

import Base: show, ==, <
import Base: length, isempty, size, getindex, isless

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

    # common
    make_vertex, make_edge,
    vertex_type, edge_type, source, target, revedge,
    is_directed, is_mutable, vertex_index, edge_index,
    num_vertices, vertices, num_edges, edges,
    out_degree, out_neighbors, out_edges,
    in_degree, in_neighbors, in_edges,
    attributes,

    KeyVertex, Edge, WeightedEdge, ExVertex, ExEdge, AttributeDict,
    collect_edges, collect_weighted_edges,

    add_edge!, add_vertex!,
    delete_vertex!,

    AbstractEdgePropertyInspector, VectorEdgePropertyInspector,
    ConstantEdgePropertyInspector, AttributeEdgePropertyInspector,
    edge_property, edge_property_requirement,

    # edge_list
    GenericEdgeList, EdgeList, simple_edgelist, edgelist,

    # adjacency_list
    GenericAdjacencyList, SimpleAdjacencyList, AdjacencyList,
    simple_adjlist, adjlist,

    # incidence_list
    GenericIncidenceList, SimpleIncidenceList, VectorIncidenceList, IncidenceList,
    simple_inclist, inclist,

    # dict based graphs
    IncidenceDict, incdict,

    # graph
    GenericGraph, SimpleGraph, Graph, simple_graph, graph,

    # gmatrix
    adjacency_matrix, weight_matrix, distance_matrix, laplacian_matrix,
    adjacency_matrix_sparse, weight_matrix_sparse, laplacian_matrix_sparse,
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

    # maximum_adjacency_visit
    MaximumAdjacency, AbstractMASVisitor, min_cut, maximum_adjacency_visit,

    # connected_components
    connected_components, strongly_connected_components,

    # cliques
    maximal_cliques,

    # dijkstra_spath
    DijkstraStates, create_dijkstra_states, AbstractDijkstraVisitor,
    dijkstra_shortest_paths!, dijkstra_shortest_paths,
    dijkstra_shortest_paths_withlog,
    enumerate_paths, enumerate_indices,

    # bellmanford
    BellmanFordStates, create_bellman_ford_states, NegativeCycleError,
    bellman_ford_shortest_paths!, bellman_ford_shortest_paths,
    has_negative_edge_cycle,

    # a_star_spath
    shortest_path,

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
    erdos_renyi_graph, watts_strogatz_graph,

    # Static Graph Generation
    simple_complete_graph, simple_star_graph, simple_path_graph,
    simple_wheel_graph, simple_diamond_graph, simple_bull_graph,
    simple_chvatal_graph, simple_cubical_graph, simple_desargues_graph,
    simple_dodecahedral_graph, simple_frucht_graph, simple_heawood_graph,
    simple_house_graph, simple_house_x_graph, simple_icosahedral_graph,
    simple_krackhardt_kite_graph, moebius_kantor_graph, simple_octahedral_graph,
    simple_pappus_graph, simple_petersen_graph, simple_sedgewick_maze_graph,
    simple_tetrahedral_graph, simple_truncated_cube_graph,
    simple_truncated_tetrahedron_graph, simple_tutte_graph


## source files

include("concepts.jl")
include("common.jl")

include("edge_list.jl")
include("adjacency_list.jl")
include("incidence_list.jl")
include("graph.jl")
include("show.jl")
include("gmatrix.jl")

include("graph_visit.jl")
include("breadth_first_visit.jl")
include("depth_first_visit.jl")
include("maximum_adjacency_visit.jl")

include("connected_components.jl")
include("dijkstra_spath.jl")
include("bellmanford.jl")
include("a_star_spath.jl")
include("prim_mst.jl")
include("kruskal_mst.jl")
include("floyd_warshall.jl")
include("cliques.jl")

include("dot.jl")

include("random.jl")
include("generators.jl")
end
