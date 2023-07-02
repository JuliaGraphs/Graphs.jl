using Graphs
using Meshes
using Random
using Combinatorics
using SparseArrays
using Makie
using GLMakie
using GraphMakie
using GraphMakie.NetworkLayout
using Plots
using GeometryBasics
using LinearAlgebra


##These functions are just what I was using right now to associate graph/layout pairs with their properties 

function crossinginfo(
    graph::AbstractGraph,
    positions::Vector{GeometryBasics.Point{2,Float32}},
)
    xprops = get_xprops()
    if !haskey(xprops, graph)
        xprops[graph] = Dict()
    end
    layoutassociation_key = positions
    if !haskey(xprops[graph], layoutassociation_key)
        layoutassociation = get_layoutassociation(graph, positions)
        layoutassociation[:graph] = graph
        layoutassociation[:positions] = positions
        xprops[graph][layoutassociation_key] = Dict(copy(layoutassociation))
    end
    layoutassociation = deepcopy(xprops[graph][layoutassociation_key])
    return layoutassociation
end

function get_layoutassociation(
    graph::AbstractGraph,
    pos::Vector{GeometryBasics.Point{2,Float32}},
)
    layoutassociation = Dict{Symbol,Any}()
    # Populate layoutassociation with relevant properties if necessary
    return layoutassociation
end

function get_xprops()
    if !@isdefined(xprops)
        xprops = Dict()
    end
    return xprops
end

####################------------------------------------------------------------------------------------------------------------------------############################

#temp Makie drawing stuff for troubleshooting

function testing_draw_crossings(
    crossings::Dict{
        Tuple{
            Tuple{Graphs.SimpleGraphs.SimpleEdge{Int64},Int64},
            Tuple{Graphs.SimpleGraphs.SimpleEdge{Int64},Int64},
        },
        Meshes.Point2f,
    },
    ax,
)
    xs = Float64[]
    ys = Float64[]
    for ((e1, e2), point) in crossings
        x, y = Meshes.coordinates(point)
        push!(xs, x)
        push!(ys, y)
    end
    return Makie.scatter!(ax, xs, ys; color = :red, markersize = 10)
end


function testing_draw_layout(graph, layout, ax; kwargs...)
    p = graphplot!(ax, graph, layout, node_color = "limegreen", node_size = 20; kwargs...)
    positions = p[:node_pos][]
    rounded_positions = [
        GeometryBasics.Point(round(pos[1], digits = 5), round(pos[2], digits = 5)) for
        pos in positions
    ]
    return rounded_positions
end

###################----------------------------------------------------------------------------------------------------------------------------------------------------##############    
function testing_generate_graph()
    n = rand(5:7)
    max_edges = n * (n - 1) ÷ 2
    e = min(3 * n - 4, max_edges)
    graph = SimpleGraph(n, e)
    return graph
end

function testing_generate_layout(graph::AbstractGraph)
    layout = SFDP(Ptype = Float32, tol = 0.01, C = 0.2, K = 1)
    #layout = Spring()
    positions = layout(graph)
    return positions
end



###################------------------------------------------------------------------------------------------------------------------- ######################################


function find_crossings(graph::SimpleGraph, pos::Vector{GeometryBasics.Point{2,Float32}})
    #For Simple Graphs
    edges_to_segments::Dict = get_edges_to_segments(graph, pos)
    segments_to_edges = Dict(value => key for (key, value) in edges_to_segments)
    segments = values(edges_to_segments)
    intersections = compute_intersections(collect(segments))

    crossings = Dict(
        (segments_to_edges[seg1], segments_to_edges[seg2]) => point for
        ((seg1, seg2), point) in intersections
    )
    return (crossings, segments_to_edges, segments)
end

function compute_intersections(segments::Vector{Segment{2,Float32,Vector{Meshes.Point2f}}})
    intersections = Dict(
        (seg1, seg2) => get(intersection(seg1, seg2)) for
        (seg1, seg2) in combinations(segments, 2) if
        type(intersection(seg1, seg2)) == CrossingSegments &&
        type(intersection(seg1, seg2)) != CornerTouchingSegments
    )
    return intersections
end

function find_crossings(graph::AbstractGraph, pos::Vector{GeometryBasics.Point{2,Float32}})
    edges_to_segments = get_edges_to_segments(graph, pos)
    segments_to_edges = Dict(value => key for (key, value) in edges_to_segments)
    segments = values(edges_to_segments)
    intersections = compute_intersections(collect(segments))
    crossings = Dict(
        (segments_to_edges[seg1], segments_to_edges[seg2]) => point for
        ((seg1, seg2), point) in intersections
    )

    return (crossings, segments_to_edges, segments)
end


function get_edges_to_segments(
    graph::AbstractGraph,
    positions::Vector{GeometryBasics.Point{2,Float32}},
)
    edges_to_segments = Dict(
        (e, i) => Segment(
            Meshes.Point(positions[src(e)][1], positions[src(e)][2]),
            Meshes.Point(positions[dst(e)][1], positions[dst(e)][2]),
        ) for (i, e) in enumerate(edges(graph))
    )
    return edges_to_segments
end


function crossing_create_csc(info::Dict{Symbol,Any})
    edge_to_id = info[:edge_to_id]
    crossings = info[:crossings]

    e = length(edge_to_id)
    rows = Int[]
    cols = Int[]
    data = Int[]

    for (((e1, i1), (e2, i2)), _) in crossings
        push!(rows, edge_to_id[e1])
        push!(cols, edge_to_id[e2])
        push!(data, 1)
    end
    csc_matrix = sparse(rows, cols, data, e, e) + sparse(cols, rows, data, e, e)
    setindex!(info, csc_matrix, :csc_matrix)
    return csc_matrix
end

function get_edge_to_id(graph::AbstractGraph)
    edge_to_id = Dict((e, i) for (i, e) in enumerate(edges(graph)))
    return edge_to_id
end

function crossing_construction(
    G::AbstractGraph,
    positions::Vector{GeometryBasics.Point{2,Float32}},
)
    #Intakes a Graph G and vector of length nv(G) with vertex positions   
    info = crossinginfo(G, positions)
    edge_to_id = get_edge_to_id(G)
    edges_to_segments = get_edges_to_segments(G, positions)
    info[:edge_to_id] = edge_to_id
    info[:edges_to_segments] = edges_to_segments
    crossings, segments_to_edges, segments = find_crossings(G, positions)
    info[:segments_to_edges] = segments_to_edges
    info[:crossings] = crossings
    info[:segments] = segments
    return info
end


function crossing_count(info::Dict{Symbol,Any})
    count = nnz(info[:csc_matrix]) * 0.5
    setindex!(info, count, :count)
    return count
end

function crossing_faces(info::Dict{Symbol,Any})
    #   facecount =     
end

function crossing_graph(
    crossings::Dict{
        Tuple{
            Tuple{Graphs.SimpleGraphs.SimpleEdge{Int64},Int64},
            Tuple{Graphs.SimpleGraphs.SimpleEdge{Int64},Int64},
        },
        Meshes.Point2f,
    },
)
    #Where a vertex in this graph represents a unique crossing pt. And two are connected if their crossings share an edge.
    F = SimpleGraph(length(crossings))
    crossing_to_id = Dict(c => i for (i, c) in enumerate(keys(crossings)))


    for (c1, c2) in combinations(collect(keys(crossings)), 2)

        if !isempty(intersect(c1, c2))
            add_edge!(F, crossing_to_id[c1], crossing_to_id[c2])
        end
    end
    return F
end


function crossing_graph_edge(crossings_matrix::SparseMatrixCSC)
    #Where a vertex represents an edge with a crossing, and two vertices are conencted if as "edges" in old graph they have a crossing together 

    # Find the indices of all non-zero elements
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

    return crossinggraphedge
end



function crossing_cedges(info::Dict{Symbol,Any}, e)
    vec = info[:csc_matrix][:, info[:edge_to_id][e]]
    return vec
end

function crossing_cedges(info::Dict{Symbol,Any})
    vec = info[:csc_matrix][:, info[:edge_to_id]]
    return vec
end

function crossing_cvertices(info::Dict{Symbol,Any})
    incim = incidence_matrix(info[:graph])
    vertexinfo = incim * info[:csc_matrix]
    info[:vinfo] = vertexinfo
    return vertexinfo
end

function crossing_cvertices(info::Dict{Symbol,Any}, v)
    vertexinfo = crossing_cvertices(info)
    deg = vertexinfo[v, :]
    return deg
end

function crossing_planegraph(info::Dict{Symbol,Any})
    #supposed to be "cannonical" planarization where crossings are replaced by a vertex

    # Create a copy of the input graph
    crossings = info[:crossings]
    positions = info[:positions]
    g::AbstractGraph = info[:graph]
    g_planar = copy(g)

    # Create a dictionary to store the positions of the new vertices
    new_positions = copy(positions)

    # Create a mapping from crossing points to new vertex indices
    crossing_to_vertex = Dict()
    next_vertex_index = nv(g) + 1

    # Add new vertices for each unique crossing point
    for (((e1, i1), (e2, i2)), crossing) in crossings
        if !haskey(crossing_to_vertex, crossing)
            add_vertex!(g_planar)
            new_positions = (positions..., crossing)
            crossing_to_vertex[crossing] = next_vertex_index
            next_vertex_index += 1
        end
    end
    # Keep track of the crossings along each edge
    edge_crossings = Dict(e => [] for e in edges(g))
    for (((e1, i1), (e2, i2)), crossing) in crossings
        push!(edge_crossings[e1], crossing_to_vertex[crossing])
        push!(edge_crossings[e2], crossing_to_vertex[crossing])
    end
    # Add new edges for each crossing
    for (e, crossings) in edge_crossings
        if !isempty(crossings)
            # Connect the source vertex to the first crossing along the edge
            add_edge!(g_planar, src(e), crossings[1])
            # Connect the destination vertex to the last crossing along the edge
            add_edge!(g_planar, dst(e), crossings[end])
            # Connect consecutive crossings along the edge
            for i = 1:length(crossings)-1
                add_edge!(g_planar, crossings[i], crossings[i+1])
            end
        end
    end
    return g_planar, new_positions
end


#=



## example Usage (with makie here but not any different with Plots really) ##


fig = Figure()
ax1 = Axis(fig[1, 1])
ax2 = Axis(fig[2, 1])
ax3 = Axis(fig[1, 2])
ax4 = Axis(fig[2, 2])
# Create a graph, a layout, and plot/embedding based on that layout

G = testing_generate_graph()
layout1 = testing_generate_layout(G)
positions1 = testing_draw_layout(G, layout1, ax1)

# Create needed information to analyze the crossings
@time crossingformation1 = crossing_construction(G, positions1)

# Then can access that information with keys
crossings1 = crossingformation1[:crossings]

#Drawing the crossing pts
testing_draw_crossings(crossings1, ax1)


#Matrix representing the edges that cross, an e x e sparse matrix. symetric for simple, will be + or - 1 for directed, where by default +1 in row i of column j means e_i crossed through right side from perspective of e_j
#Functionality for a pair of edges crossing more than once with each other could be represented pretty easily by extending the matrix to rank 3 tensor ig?
#Also easy to add a function to pass as argument for weighted graphs, or for whatever someone wants to pass for creating the crossing matrix

cmatrix1 = crossing_create_csc(crossingformation1)


crossgraphedge1 = crossing_graph_edge(cmatrix1)
cgely = testing_generate_layout(crossgraphedge1)
testing_draw_layout(crossgraphedge1, cgely, ax2, node_color = "blue", node_size = 13)


crossgraph = crossing_graph(crossings1)
crossgraphly = testing_generate_layout(crossgraph)
testing_draw_layout(crossgraph, crossgraphly, ax3, node_color = "red", node_size = 10)



G_planar, positions1_pl = crossing_planegraph(crossingformation1)
testing_draw_layout(G_planar, positions1_pl, ax4, node_color="green", node_size=20)







fig





=#
