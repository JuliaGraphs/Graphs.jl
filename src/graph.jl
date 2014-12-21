# A versatile graph type
#
# It implements edge_list, adjacency_list and incidence_list
#

type GenericGraph{V,E,VList,EList,IncList} <: AbstractGraph{V,E}
    is_directed::Bool
    vertices::VList     # an indexable container of vertices
    edges::EList        # an indexable container of edges
    finclist::IncList   # forward incidence list
    binclist::IncList   # backward incidence list
end

@graph_implements GenericGraph vertex_list edge_list vertex_map edge_map
@graph_implements GenericGraph bidirectional_adjacency_list bidirectional_incidence_list

# SimpleGraph:
#   V:          Int
#   E:          IEdge
#   VList:      Range1{Int}
#   EList:      Vector{IEdge}
#   AdjList:    Vector{Vector{Int}}
#   IncList:    Vector{Vector{IEdge}}
#
typealias SimpleGraph GenericGraph{Int,IEdge,Range1{Int},Vector{IEdge},Vector{Vector{IEdge}}}

typealias Graph{V,E} GenericGraph{V,E,Vector{V},Vector{E},Vector{Vector{E}}}

# construction

simple_graph(n::Integer; is_directed::Bool=true) =
    SimpleGraph(is_directed,
                1:int(n),  # vertices
                IEdge[],   # edges
                multivecs(IEdge, n), # finclist
                multivecs(IEdge, n)) # binclist

function graph{V,E}(vs::Vector{V}, es::Vector{E}; is_directed::Bool=true)
    n = length(vs)
    g = Graph{V,E}(is_directed, vs, E[], multivecs(E, n), multivecs(E, n))
    for e in es
        add_edge!(g, e)
    end
    return g
end


# required interfaces

is_directed(g::GenericGraph) = g.is_directed

num_vertices(g::GenericGraph) = length(g.vertices)
vertices(g::GenericGraph) = g.vertices

num_edges(g::GenericGraph) = length(g.edges)
edges(g::GenericGraph) = g.edges

vertex_index(v::Integer, g::SimpleGraph) = (v <= g.vertices[end]? v: 0)

edge_index{V,E}(e::E, g::GenericGraph{V,E}) = edge_index(e)

out_edges{V}(v::V, g::GenericGraph{V}) = g.finclist[vertex_index(v, g)]
out_degree{V}(v::V, g::GenericGraph{V}) = length(out_edges(v, g))
out_neighbors{V}(v::V, g::GenericGraph{V}) = TargetIterator(g, out_edges(v, g))

in_edges{V}(v::V, g::GenericGraph{V}) = g.binclist[vertex_index(v, g)]
in_degree{V}(v::V, g::GenericGraph{V}) = length(in_edges(v, g))
in_neighbors{V}(v::V, g::GenericGraph{V}) = SourceIterator(g, in_edges(v, g))


# mutation

function add_vertex!(g::SimpleGraph)
    # ensure SimpleGraph indices are consecutive, allowing O(1) indexing
    v = g.vertices[end] + 1
    g.vertices = 1:v
    push!(g.finclist, Int[])
    push!(g.binclist, Int[])
    v
end

@deprecate add_vertex!(g::SimpleGraph,v) add_vertex!(g::SimpleGraph)

function add_vertex!{V}(g::GenericGraph{V}, v::V)
    push!(g.vertices, v)
    push!(g.finclist, Int[])
    push!(g.binclist, Int[])
    v
end
add_vertex!{V}(g::GenericGraph{V}, x) = add_vertex!(g, make_vertex(g, x))

function add_edge!{V,E}(g::GenericGraph{V,E}, u::V, v::V, e::E)
    # add an edge e between u and v
    ui = vertex_index(u, g)::Int
    vi = vertex_index(v, g)::Int

    push!(g.edges, e)
    push!(g.finclist[ui], e)
    push!(g.binclist[vi], e)

    if !g.is_directed
        rev_e = revedge(e)
        push!(g.finclist[vi], rev_e)
        push!(g.binclist[ui], rev_e)
    end
    e
end

add_edge!{V,E}(g::GenericGraph{V,E}, e::E) = add_edge!(g, source(e, g), target(e, g), e)
add_edge!{V,E}(g::GenericGraph{V,E}, u::V, v::V) = add_edge!(g, u, v, make_edge(g, u, v))
