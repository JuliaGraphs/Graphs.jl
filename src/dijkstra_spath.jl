# Dijkstra's algorithm for single-source shortest path

###################################################################
#
#   The type that capsulates the states of Dijkstra algorithm
#
###################################################################

mutable struct DijkstraStates{V,D<:Number,Heap,H}
    parents::Vector{V}
    parent_indices::Vector{Int}
    dists::Vector{D}
    colormap::Vector{Int}
    heap::Heap
    hmap::Vector{H}
end

struct DijkstraHEntry{V,D}
    vertex::V
    dist::D
end

<(e1::DijkstraHEntry, e2::DijkstraHEntry) = e1.dist < e2.dist

# create Dijkstra states

function create_dijkstra_states(g::AbstractGraph{V}, ::Type{D}) where {V,D<:Number}
    n = num_vertices(g)
    parents = Array{V}(undef, n)
    parent_indices = zeros(Int, n)
    dists = fill(typemax(D), n)
    colormap = zeros(Int, n)
    heap = mutable_binary_minheap(DijkstraHEntry{V,D})
    hmap = zeros(Int, n)

    DijkstraStates(parents, parent_indices, dists, colormap, heap, hmap)
end

###################################################################
#
#   visitors
#
###################################################################

abstract type AbstractDijkstraVisitor end

# invoked when a new vertex is first encountered
discover_vertex!(visitor::AbstractDijkstraVisitor, u, v, d) = nothing

# invoked when the distance of a vertex is determined
# (for each source vertex at the beginning, and when a vertex is popped from the heap)
# returns whether the algorithm should continue
include_vertex!(visitor::AbstractDijkstraVisitor, u, v, d) = true

# invoked when the distance to a vertex is updated (decreased)
update_vertex!(visitor::AbstractDijkstraVisitor, u, v, d) = nothing

# invoked when all neighbors of a vertex has been examined
close_vertex!(visitor::AbstractDijkstraVisitor, v) = nothing


# trivial visitor

mutable struct TrivialDijkstraVisitor <: AbstractDijkstraVisitor
end


# log visitor

mutable struct LogDijkstraVisitor <: AbstractDijkstraVisitor
    io::IO
end

function discover_vertex!(visitor::LogDijkstraVisitor, u, v, d)
    println(visitor.io, "discover vertex $v (parent = $u, dist = $d)")
end

function include_vertex!(visitor::LogDijkstraVisitor, u, v, d)
    println(visitor.io, "include vertex $v (parent = $u, dist = $d)")
    true
end

function update_vertex!(visitor::LogDijkstraVisitor, u, v, d)
    println(visitor.io, "update distance $v (parent = $u, dist = $d)")
end

function close_vertex!(visitor::LogDijkstraVisitor, v)
    println(visitor.io, "close vertex $v")
end


###################################################################
#
#   core algorithm implementation
#
###################################################################

function set_source!(state::DijkstraStates{V,D}, g::AbstractGraph{V}, s::V) where {V,D}
    i = vertex_index(s, g)
    state.parents[i] = s
    state.parent_indices[i] = i
    state.dists[i] = 0
    state.colormap[i] = 2
end

function process_neighbors!(
    state::DijkstraStates{V,D,Heap,H},
    graph::AbstractGraph{V},
    edge_dists::AbstractEdgePropertyInspector{D},
    u::V, du::D, visitor::AbstractDijkstraVisitor) where {V,D,Heap,H}

    dists::Vector{D} = state.dists
    parents::Vector{V} = state.parents
    parent_indices::Vector{Int} = state.parent_indices
    colormap::Vector{Int} = state.colormap
    heap::Heap = state.heap
    hmap::Vector{H} = state.hmap
    dv::D = zero(D)

    for e in out_edges(u, graph)
        v::V = target(e, graph)
        iv::Int = vertex_index(v, graph)
        v_color::Int = colormap[iv]

        if v_color == 0
            dists[iv] = dv = du + edge_property(edge_dists, e, graph)
            parents[iv] = u
            parent_indices[iv] = vertex_index(u, graph)
            colormap[iv] = 1
            discover_vertex!(visitor, u, v, dv)

            # push new vertex to the heap
            hmap[iv] = push!(heap, DijkstraHEntry(v, dv))

        elseif v_color == 1
            dv = du + edge_property(edge_dists, e, graph)
            if dv < dists[iv]
                dists[iv] = dv
                parents[iv] = u
                parent_indices[iv] = vertex_index(u, graph)

                # update the value on the heap
                update_vertex!(visitor, u, v, dv)
                update!(heap, hmap[iv], DijkstraHEntry(v, dv))
            end
        end
    end
end


function dijkstra_shortest_paths!(
    graph::AbstractGraph{V},                # the graph
    edge_dists::AbstractEdgePropertyInspector{D}, # distances associated with edges
    sources::AbstractVector{V},             # the sources
    visitor::AbstractDijkstraVisitor,       # visitor object
    state::DijkstraStates{V,D,Heap,H}) where {V, D, Heap, H}     # the states

    @graph_requires graph incidence_list vertex_map vertex_list
    edge_property_requirement(edge_dists, graph)

    # get state fields

    parents::Vector{V} = state.parents
    dists::Vector{D} = state.dists
    colormap::Vector{Int} = state.colormap
    heap::Heap = state.heap
    hmap::Vector{H} = state.hmap

    # initialize for sources

    d0 = zero(D)

    for s in sources
        set_source!(state, graph, s)
        if !include_vertex!(visitor, s, s, d0)
            return state
        end
    end

    # process direct neighbors of all sources

    for s in sources
        process_neighbors!(state, graph, edge_dists, s, d0, visitor)
        close_vertex!(visitor, s)
    end

    # main loop

    while !isempty(heap)

        # pick next vertex to include
        entry = pop!(heap)
        u::V = entry.vertex
        du::D = entry.dist

        ui = vertex_index(u, graph)
        colormap[ui] = 2
        if !include_vertex!(visitor, parents[ui], u, du)
            return state
        end

        # process u's neighbors

        process_neighbors!(state, graph, edge_dists, u, du, visitor)
        close_vertex!(visitor, u)
    end

    state
end


function dijkstra_shortest_paths(
    graph::AbstractGraph{V},                # the graph
    edge_len::AbstractEdgePropertyInspector{D}, # distances associated with edges
    sources::AbstractVector{V};
    visitor::AbstractDijkstraVisitor=TrivialDijkstraVisitor()) where {V, D}
    #
    state = create_dijkstra_states(graph, D)
    dijkstra_shortest_paths!(graph, edge_len, sources, visitor, state)
end


# Convenient functions

function dijkstra_shortest_paths(
    graph::AbstractGraph{V}, edge_dists::Vector{D}, s::V;
    visitor::AbstractDijkstraVisitor=TrivialDijkstraVisitor()) where {V,D}

    edge_len::AbstractEdgePropertyInspector{D} = VectorEdgePropertyInspector(edge_dists)
    state = create_dijkstra_states(graph, D)
    dijkstra_shortest_paths!(graph, edge_len, [s], visitor, state)
end

function dijkstra_shortest_paths(
    graph::AbstractGraph{V}, edge_dists::Vector{D}, sources::AbstractVector{V};
    visitor::AbstractDijkstraVisitor=TrivialDijkstraVisitor()) where {V,D}

    edge_len::AbstractEdgePropertyInspector{D} = VectorEdgePropertyInspector(edge_dists)
    state = create_dijkstra_states(graph, D)
    dijkstra_shortest_paths!(graph, edge_len, sources, visitor, state)
end

function dijkstra_shortest_paths_withlog(
    graph::AbstractGraph{V}, edge_dists::Vector{D}, s::V) where {V,D}
    #
    dijkstra_shortest_paths(graph, edge_dists, s, visitor=LogDijkstraVisitor(STDOUT))
end


function dijkstra_shortest_paths_withlog(
    graph::AbstractGraph{V}, edge_dists::Vector{D}, sources::AbstractVector{V}) where {V,D}
    #
    dijkstra_shortest_paths(graph, edge_dists, sources, visitor=LogDijkstraVisitor(STDOUT))
end

dijkstra_shortest_paths(
    graph::AbstractGraph{V}, s::V
) where {V} = dijkstra_shortest_paths(graph, ones(num_edges(graph)), s)

function enumerate_indices(parent_indices::Vector{Int}, dest_indices::Vector{Int})
    num_dest = length(dest_indices)
    all_paths = Array{Vector{Int}}(undef, num_dest)
    for i=1:num_dest
        all_paths[i] = Int[]
        index = dest_indices[i]
        if parent_indices[index] != 0
            while parent_indices[index] != index
                push!(all_paths[i], index)
                index = parent_indices[index]
            end
            push!(all_paths[i], index)
            reverse!(all_paths[i])
        end
    end
    all_paths
end

enumerate_indices(parent_indices::Vector{Int}, dest_index::Int) = enumerate_indices(parent_indices, Int[dest_index])[1]
enumerate_indices(parent_indices::Vector{Int}) = enumerate_indices(parent_indices, collect(1:length(parent_indices)))
enumerate_paths(vertices, parent_indices::Vector{Int}, dest_indices::Vector{Int}) = [vertices[i] for i in enumerate_indices(parent_indices, dest_indices)]
enumerate_paths(vertices, parent_indices::Vector{Int}, dest_index::Int) = enumerate_paths(vertices, parent_indices, [dest_index])[1]
enumerate_paths(vertices, parent_indices::Vector{Int}) = enumerate_paths(vertices, parent_indices, collect(1:length(parent_indices)))
