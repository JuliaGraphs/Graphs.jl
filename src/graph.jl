# A versatile graph type
#
# It implements edge_list, adjacency_list and incidence_list
#

mutable struct GenericGraph{V,E,VList,EList,IncList} <: AbstractGraph{V,E}
    is_directed::Bool
    vertices::VList     # an indexable container of vertices
    edges::EList        # an indexable container of edges
    finclist::IncList   # forward incidence list
    binclist::IncList   # backward incidence list
    indexof::Dict{V,Int}   # dictionary storing index for each vertex
end

@graph_implements GenericGraph vertex_list edge_list vertex_map edge_map
@graph_implements GenericGraph bidirectional_adjacency_list bidirectional_incidence_list

# SimpleGraph:
#   V:          Int
#   E:          IEdge
#   VList:      UnitRange{Int}
#   EList:      Vector{IEdge}
#   AdjList:    Vector{Vector{Int}}
#   IncList:    Vector{Vector{IEdge}}
#
const SimpleGraph = GenericGraph{Int,IEdge,UnitRange{Int},Vector{IEdge},Vector{Vector{IEdge}}}

const Graph{V,E} = GenericGraph{V,E,Vector{V},Vector{E},Vector{Vector{E}}}

# construction

simple_graph(n::Integer; is_directed::Bool=true) =
    SimpleGraph(is_directed,
                intrange(n),  # vertices
                IEdge[],   # edges
                multivecs(IEdge, n), # finclist
                multivecs(IEdge, n), # binclist
                Dict{Int, Int}()) # indices (not used for simple graph)

function graph(vs::Vector{V}, es::Vector{E}; is_directed::Bool=true) where {V,E}
    n = length(vs)
    g = Graph{V,E}(is_directed, V[], E[], multivecs(E, n), multivecs(E, n), Dict{V,Int}())
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

vertex_index(v::Integer, g::SimpleGraph) = (v <= g.vertices[end] ? v : 0)
# If V is either ExVertex or KeyVertex call vertex_index on v
# vertex_index{V<:ProvidedVertexType}(v::V, g::GenericGraph{V}) = vertex_index(v) # not quite sure what's going on here
# Else return index given by dictionary
vertex_index(v::V, g::GenericGraph{V}) where {V<:ProvidedVertexType} = try g.indexof[v] catch e 0; end

edge_index(e::E, g::GenericGraph{V,E}) where {V,E} = edge_index(e)

out_edges(v::V, g::GenericGraph{V}) where {V} = g.finclist[vertex_index(v, g)]
out_degree(v::V, g::GenericGraph{V}) where {V} = length(out_edges(v, g))
out_neighbors(v::V, g::GenericGraph{V}) where {V} = TargetIterator(g, out_edges(v, g))

in_edges(v::V, g::GenericGraph{V}) where {V} = g.binclist[vertex_index(v, g)]
in_degree(v::V, g::GenericGraph{V}) where {V} = length(in_edges(v, g))
in_neighbors(v::V, g::GenericGraph{V}) where {V} = SourceIterator(g, in_edges(v, g))


# mutation

function add_vertex!(g::SimpleGraph)
    # ensure SimpleGraph indices are consecutive, allowing O(1) indexing
    v = length(g.vertices)+1
    g.vertices = 1:v
    push!(g.finclist, Int[])
    push!(g.binclist, Int[])
    v
end

@deprecate add_vertex!(g::SimpleGraph,v) add_vertex!(g::SimpleGraph)

function add_vertex!(g::GenericGraph{V}, v::V) where {V}
    push!(g.vertices, v)
    push!(g.finclist, Int[])
    push!(g.binclist, Int[])
    g.indexof[v] = length(g.vertices)
    v
end
add_vertex!(g::GenericGraph{V}, x) where {V} = add_vertex!(g, make_vertex(g, x))

function add_edge!(g::GenericGraph{V,E}, u::V, v::V, e::E) where {V,E}
    # add an edge e between u and v
    ui = vertex_index(u, g)::Int
    vi = vertex_index(v, g)::Int

    push!(g.finclist[ui], e)
    push!(g.binclist[vi], e)
    push!(g.edges, e)

    if !g.is_directed
        rev_e = revedge(e)
        push!(g.finclist[vi], rev_e)
        push!(g.binclist[ui], rev_e)
    end
    e
end

add_edge!(g::GenericGraph{V,E}, e::E) where {V,E} = add_edge!(g, source(e, g), target(e, g), e)
add_edge!(g::GenericGraph{V,E}, u::V, v::V) where {V,E} = add_edge!(g, u, v, make_edge(g, u, v))
