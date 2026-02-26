using Graphs
using GeometryBasics
using Test

include("../src/Crossings.jl")

@testset "Graph functions tests" begin
    
    @testset "get_edge_to_id" begin
        g = Graph(4)
        add_edge!(g, 1, 2)
        add_edge!(g, 3, 4)
        edge_to_id = get_edge_to_id(g)
        @test edge_to_id[Edge(1, 2)] == 1
        @test edge_to_id[Edge(3, 4)] == 2
    end

    @testset "crossing_construction test" begin
        # Adjusted graph creation method
        G = Graph(5)
        add_edge!(G, 1, 2)
        add_edge!(G, 2, 3)
        add_edge!(G, 3, 4)
        add_edge!(G, 4, 5)
        add_edge!(G, 5, 1)
        add_edge!(G, 2, 4)
        add_edge!(G, 1, 4)
        add_edge!(G, 1, 3)
        add_edge!(G, 5, 3) 
        add_edge!(G, 5, 2)

        # Using GeometryBasics.Point
        positions = [
            GeometryBasics.Point(0f0, 0f0),
            GeometryBasics.Point(1f0, 0f0),
            GeometryBasics.Point(1f0, 1f0),
            GeometryBasics.Point(0f0, 1f0),
            GeometryBasics.Point(0.5f0, 0.5f0)  # Added position for vertex 5
        ]

        info, crossings = crossing_construction(G, positions)

      
        @test length(crossings) == 1  
    end


    @testset "crossing_ccount" begin
        g = Graph(6)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        add_edge!(g, 3, 4)
        add_edge!(g, 4, 5)
        add_edge!(g, 5, 6)
        add_edge!(g, 6, 1)
        
        add_edge!(g, 1, 4)
        add_edge!(g, 2, 5)
        add_edge!(g, 3, 6)
        
        edge_to_id = get_edge_to_id(g)
        positions = [
            GeometryBasics.Point(0f0, 0f0),
            GeometryBasics.Point(0f0, 1f0),
            GeometryBasics.Point(1f0, 1f0),
            GeometryBasics.Point(2f0, 1f0),
            GeometryBasics.Point(2f0, 0f0),
            GeometryBasics.Point(1f0, 0f0)
        ]
        
        info, crossings = crossing_construction(g, positions)
        count = crossing_ccount(crossings)
        @test count == 3
    end

    @testset "crossing_pcount" begin
       g = Graph(6)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        add_edge!(g, 3, 4)
        add_edge!(g, 4, 5)
        add_edge!(g, 5, 6)
        add_edge!(g, 6, 1)
        
        add_edge!(g, 1, 4)
        add_edge!(g, 2, 5)
        add_edge!(g, 3, 6)
        
        positions = [
            GeometryBasics.Point(0f0, 0f0),
            GeometryBasics.Point(0f0, 1f0),
            GeometryBasics.Point(1f0, 1f0),
            GeometryBasics.Point(2f0, 1f0),
            GeometryBasics.Point(2f0, 0f0),
            GeometryBasics.Point(1f0, 0f0)
        ]
        info, crossings = crossing_construction(g, positions)
        pcount = crossing_pcount(info)
        @test pcount == 1
    end

    
    
 
    # Mock Data
    g = Graph(4)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 4, 1)
    positions = [
     GeometryBasics.Point(0f0, 0f0),
            GeometryBasics.Point(0f0, 1f0),
            GeometryBasics.Point(1f0, 1f0),
            GeometryBasics.Point(2f0, 1f0),
            GeometryBasics.Point(1f0, 0f0)
    ]


    # Tests for get_edges_to_segments
    @testset "get_edges_to_segments" begin
        result = get_edges_to_segments(g, positions)
        @test length(result) == 4
    end

    
    # Tests for get_rightsidecrossing
    @testset "get_rightsidecrossing tests" begin
        # Create some segments for testing
        seg1 = Segment{2,Float32,Vector{Meshes.Point2f}}(Meshes.Point2f(0.0f0, 0.0f0), Meshes.Point2f(0.0f0, 1.0f0))
        seg2 = Segment{2,Float32,Vector{Meshes.Point2f}}(Meshes.Point2f(0.0f0, 0.0f0), Meshes.Point2f(1.0f0, 0.0f0))

        # Points for testing
        pt1 = GeometryBasics.Point{2,Float32}(0.5f0, 0.5f0)  # to the right of seg1
        pt2 = GeometryBasics.Point{2,Float32}(0.5f0, -0.5f0)  # to the left of seg1 and left seg2
        pt3 = GeometryBasics.Point{2,Float32}(0.5f0, 0.5f0)  # to the right of seg2

        # Convert points to Meshes.Point
        mpt1 = Meshes.Point(pt1)
        mpt2 = Meshes.Point(pt2)
        mpt3 = Meshes.Point(pt3)

        # Tests
        @test get_rightsidecrossing(seg1, mpt1) == true
        @test get_rightsidecrossing(seg1, mpt2) == true
        @test get_rightsidecrossing(seg2, mpt3) == false
        @test get_rightsidecrossing(seg2, mpt2) == true
    end


    
    # Tests for compute_intersections
    @testset "compute_intersections" begin
        # Assuming positions is a Dict or Array of Meshes.Point2f and edges(g) yields pairs of keys/indices
        segments = [Segment{2, Float32, Vector{Meshes.Point2f}}(Meshes.Point2f(positions[src(e)]...), Meshes.Point2f(positions[dst(e)]...)) for e in edges(g)]


        result = compute_intersections(segments)

        @test isempty(result) == true
    end


    
    # Tests for find_crossings
    @testset "find_crossings" begin
        crossings, segments_to_edges = find_crossings(g, positions)
        @test isempty(crossings) == true
    end

    
    # Tests for crossing_create_csc
    @testset "crossing_create_csc" begin
        info = Dict(
            :graph => g,
            :edge_to_id => Dict(e => i for (i, e) in enumerate(edges(g))),
            :crossings => Dict()
        )
        result = crossing_create_csc(info)
        @test issparse(result) == true
        @test size(result) == (4, 4)
    end    

    @testset "crossinginfo" begin
        # Create a dummy graph and positions
        g = SimpleGraph(3)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        positions = [
            GeometryBasics.Point(0f0, 0f0),
            GeometryBasics.Point(0f0, 1f0),
            GeometryBasics.Point(1f0, 1f0),
       
    ]
        # Call crossinginfo
        info = crossinginfo(g, positions)

        # Check some properties of the returned layout
        @test info[:graph] == g
        @test info[:positions] == positions

        # Further checks can be added as per the behaviour of get_layoutassociation and other intricacies
    end    
    
    
    
    @testset "crossing_graph" begin
    c_graph = Graph(4)
    add_edge!(c_graph, 1, 2)
    add_edge!(c_graph, 2, 3)
    add_edge!(c_graph, 3, 4)
    add_edge!(c_graph, 4, 1)
    add_edge!(c_graph, 1, 3)
    add_edge!(c_graph, 2, 4)
    
    g_graph_positions = [
            GeometryBasics.Point(0f0, 0f0),
            GeometryBasics.Point(1f0, 0f0),
            GeometryBasics.Point(1f0, 1f0),
            GeometryBasics.Point(0f0, 1f0),
    ]
    edge_list = collect(edges(g))
    
    key = ((edge_list[1], 1), (edge_list[2], 1)) 
    value = Meshes.Point2f(0.5f0, 0.5f0)
    
    crossings = Dict(key => value)
    
    cg = crossing_graph(crossings)
    @test nv(cg) == length(crossings)
    @test ne(cg) == 0
    end
    
    @testset "crossing_graph_edge" begin
         # Find the indices of all non-zero elements
    # Non-zero elements
    rows = [5, 6]
    cols = [6, 5]
    vals = [1, 1]

    # Create the sparse matrix
    crossings_matrix = sparse(rows, cols, vals, 6, 6)    
        
    rows, cols, _ = findnz(crossings_matrix)

    # Find the unique indices of all non-isolated vertices
    non_isolated_vertices = unique(vcat(cols))

    # Create a mapping from old vertex indices to new vertex indices
    index_map = Dict(non_isolated_vertices .=> 1:length(non_isolated_vertices))

    # Create a new matrix with the size of the non-isolated vertices
    new_matrix = spzeros(length(non_isolated_vertices), length(non_isolated_vertices))

    # Iterate over the non-zero elements
    for (row, col) in zip(rows, cols)
        # Set the corresponding element in the new matrix to 1
        new_matrix[index_map[row], index_map[col]] = 1
        new_matrix[index_map[col], index_map[row]] = 1
    end

    # Create a SimpleGraph from the new matrix
    crossinggraphedge = SimpleGraph(new_matrix)
    @test nv(crossinggraphedge) == 2
    @test ne(crossinggraphedge) == 1
    end
    
    
end








