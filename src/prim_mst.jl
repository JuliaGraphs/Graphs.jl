# Prim's algorithm on minimum spanning tree

###################################################################
#
#   The type that capsulates the states of Prim's algorithm
#
###################################################################

type PrimStates{V,W,Heap,H}
    parents::Vector{V}
    colormap::Vector{Int}
    weightmap::Vector{W}

    heap::Heap
    hmap::Vector{H}
end

immutable PrimHEntry{V,E,W}
    vertex::V
    edge::E
    weight::W
end

< (e1::PrimHEntry, e2::PrimHEntry) = e1.weight < e2.weight

# create Prim states

function create_prim_states{V,E,W}(g::AbstractGraph{V,E}, ::Type{W})
    n = num_vertices(g)

    parents = Array(V, n)
    colormap = zeros(Int, n)
    weightmap = zeros(W, n)

    heap = mutable_binary_minheap(PrimHEntry{V,E,W})
    hmap = zeros(Int, n)

    PrimStates(parents, colormap, weightmap, heap, hmap)
end


###################################################################
#
#   visitors
#
###################################################################

abstract AbstractPrimVisitor

# invoked when a new vertex is first encountered
discover_vertex!(visitor::AbstractPrimVisitor, v, e, w) = nothing

# invoked when an edge is included into the tree
# it returns whether to continue
include_vertex!(visitor::AbstractPrimVisitor, v, e, w) = true

# invoked when the weight to a vertex is updated
update_vertex!(visitor::AbstractPrimVisitor, v, e, w) = nothing

# invoked when all neighbors of a vertex has been examined
close_vertex!(visitor::AbstractPrimVisitor, v) = nothing


# trivial visitor

type TrivialPrimVisitor <: AbstractPrimVisitor
end

# default visitor

type PrimVisitor{E,W} <: AbstractPrimVisitor
    edges::Vector{E}
    weights::Vector{W}
end

function default_prim_visitor{V,E,W}(g::AbstractGraph{V,E}, ::Type{W})
    edges = Array(E, 0)
    weights = Array(W, 0)
    n = num_vertices(g)
    if n > 1
        sizehint!(edges, n-1)
        sizehint!(weights, n-1)
    end
    PrimVisitor{E,W}(edges, weights)
end

function include_vertex!{V,E,W}(vis::PrimVisitor{E,W}, v::V, e::E, w::W)
    push!(vis.edges, e)
    push!(vis.weights, w)
    true
end


# log visitor

type LogPrimVisitor <: AbstractPrimVisitor
    io::IO
end

function discover_vertex!(visitor::LogPrimVisitor, v, e, w)
    println(visitor.io, "discover vertex $v (edge = $e, w = $w)")
end

function include_vertex!(visitor::LogPrimVisitor, v, e, w)
    println(visitor.io, "include vertex $v (edge = $e, w = $w)")
    true
end

function update_vertex!(visitor::LogPrimVisitor, v, e, w)
    println(visitor.io, "update vertex $v (edge = $e, w = $w)")
end

function close_vertex!(visitor::LogPrimVisitor, v)
    println(visitor.io, "close vertex $v")
end


###################################################################
#
#   core algorithm implementation
#
###################################################################

function process_neighbors!{V,E,W,Heap,H}(
    graph::AbstractGraph{V,E},          # the graph
    edge_weights::AbstractEdgePropertyInspector{W},            # weights associated with edges
    visitor::AbstractPrimVisitor,       # visitor object
    u::V,                               # the vertex whose neighbor to be examined
    state::PrimStates{V,W,Heap,H})      # the states (created)

    parents::Vector{V} = state.parents
    colormap::Vector{Int} = state.colormap
    weightmap::Vector{W} = state.weightmap
    heap::Heap = state.heap
    hmap::Vector{H} = state.hmap

    ew::W = zero(W)

    for e in out_edges(u, graph)
        v = target(e, graph)
        vi = vertex_index(v, graph)
        v_color = colormap[vi]

        if v_color == 0
            ew = edge_property(edge_weights, e, graph)
            colormap[vi] = 1
            weightmap[vi] = ew
            discover_vertex!(visitor, v, e, ew)

            hmap[vi] = push!(heap, PrimHEntry(v, e, ew))

        elseif v_color == 1
            ew = edge_property(edge_weights, e, graph)
            if ew < weightmap[vi]
                weightmap[vi] = ew

                update_vertex!(visitor, v, e, ew)
                update!(heap, hmap[vi], PrimHEntry(v, e, ew))
            end
        end
    end
end


function prim_minimum_spantree!{V,E,W,Heap,H}(
    graph::AbstractGraph{V,E},          # the graph
    edge_weights::AbstractEdgePropertyInspector{W},            # weights associated with edges
    root::V,                            # the root vertex
    visitor::AbstractPrimVisitor,       # visitor object
    state::PrimStates{V,W,Heap,H})        # the states (created)

    @graph_requires graph vertex_map incidence_list

    if is_directed(graph)
        throw(ArgumentError("graph must be undirected."))
    end

    # initialize

    root_idx = vertex_index(root, graph)
    state.parents[root_idx] = root
    state.colormap[root_idx] = 2

    process_neighbors!(graph, edge_weights, visitor, root, state)
    close_vertex!(visitor, root)

    # main loop

    heap::Heap = state.heap

    while !isempty(heap)
        entry = pop!(heap)
        v::V = entry.vertex
        e::E = entry.edge
        w::W = entry.weight

        state.colormap[vertex_index(v, graph)] = 2
        if !include_vertex!(visitor, v, e, w)
            return
        end
        process_neighbors!(graph, edge_weights, visitor, v, state)
        close_vertex!(visitor, v)
    end
end

# convenient functions

function prim_minimum_spantree{V,E,W}(
    graph::AbstractGraph{V,E},
    edge_weight_vec::Vector{W},
    root::V)

    state = create_prim_states(graph, W)
    visitor = default_prim_visitor(graph, W)
    edge_weights = VectorEdgePropertyInspector(edge_weight_vec)
    prim_minimum_spantree!(graph, edge_weights, root, visitor, state)
    return (visitor.edges, visitor.weights)
end


function prim_minimum_spantree{V,E,W}(
    graph::AbstractGraph{V,E},
    edge_weights::AbstractEdgePropertyInspector{W},
    root::V)

    state = create_prim_states(graph, W)
    visitor = default_prim_visitor(graph, W)
    prim_minimum_spantree!(graph, edge_weights, root, visitor, state)
    return (visitor.edges, visitor.weights)
end

function prim_minimum_spantree_withlog{V,E,W}(
    graph::AbstractGraph{V,E},
    edge_weight_vec::Vector{W},
    root::V)

    state = create_prim_states(graph, W)
    visitor = LogPrimVisitor(STDOUT)
    edge_weights = VectorEdgePropertyInspector(edge_weight_vec)
    prim_minimum_spantree!(graph, edge_weights, root, visitor, state)
end
