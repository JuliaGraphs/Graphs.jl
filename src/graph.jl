# A versatile graph type
#
# It implements edge_list, adjacency_list and incidence_list
#

type GenericGraph{V,E,VList,EList,IncList,VDict} <: AbstractGraph{V,E}
    is_directed::Bool
    vertices::VList     # an indexable container of vertices
    edges::EList        # an indexable container of edges
    finclist::IncList   # forward incidence list
    binclist::IncList   # backward incidence list
    indexof::VDict   # dictionary storing index for each vertex
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
typealias SimpleGraph GenericGraph{Int,IEdge,Range1{Int},Vector{IEdge},Vector{Vector{IEdge}},Dict{Int,Int}}

typealias Graph{V,E} GenericGraph{V,E,Vector{V},Vector{E},Vector{Vector{E}},Dict{V,Int}}

# construction

simple_graph(n::Integer; is_directed::Bool=true) =
    SimpleGraph(is_directed,
                1:int(n),  # vertices
                IEdge[],   # edges
                multivecs(IEdge, n), # finclist
                multivecs(IEdge, n), # binclist
                (Int => Int)[]) # indices (not used for simple graph)

function graph{V,E}(vs::Vector{V}, es::Vector{E}; is_directed::Bool=true)
    n = length(vs)
    g = Graph{V,E}(is_directed, V[], E[], multivecs(E, n), multivecs(E, n), (V =>Int)[])
    for v in vs
        add_vertex!(g,v)
    end
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
# If V is either ExVertex or KeyVertex call vertex_index on v
vertex_index{V<:ProvidedVertexType}(v::V, g::GenericGraph{V}) = vertex_index(v)
# Else return index given by dictionary
vertex_index{V}(v::V,g::GenericGraph{V}) = try g.indexof[v] catch 0 end

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
    g.indexof[v] = length(g.vertices)
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
