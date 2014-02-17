# A versatile graph type
#
# It implements edge_list, adjacency_list and incidence_list
#

type GenericGraph{V,E,VList,EList,AdjList,IncList} <: AbstractGraph{V,E}
    is_directed::Bool
    vertices::VList     # an indexable container of vertices
    edges::EList        # an indexable container of edges
    adjlist::AdjList    # adjlist[i] is a list of neighbor vertices
    inclist::IncList    # inclist[i] is a list of out-going edges
end

@graph_implements GenericGraph vertex_list edge_list vertex_map edge_map adjacency_list incidence_list

# SimpleGraph:
#   V:          Int
#   E:          IEdge
#   VList:      Range1{Int}
#   EList:      Vector{IEdge}
#   AdjList:    Vector{Vector{Int}}
#   IncList:    Vector{Vector{IEdge}}
#
typealias SimpleGraph GenericGraph{Int,IEdge,Range1{Int},Vector{IEdge},Vector{Vector{Int}},Vector{Vector{IEdge}}}

# required interfaces

is_directed(g::GenericGraph) = g.is_directed

num_vertices(g::GenericGraph) = length(g.vertices)
vertices(g::GenericGraph) = g.vertices

num_edges(g::GenericGraph) = length(g.edges)
edges(g::GenericGraph) = g.edges

vertex_index(v, g::GenericGraph) = vertex_index(v)
edge_index(e, g::GenericGraph) = edge_index(e)

out_degree(v, g::GenericGraph) = length(g.adjlist[vertex_index(v)])
out_neighbors(v, g::GenericGraph) = g.adjlist[vertex_index(v)]
out_edges(v, g::GenericGraph) = g.inclist[vertex_index(v)]

# mutation

function add_vertex!{V,E}(g::GenericGraph{V,E}, v::V)
    @assert vertex_index(v) == num_vertices(g) + 1
    push!(g.vertices, v)
    push!(g.adjlist, Array(V, 0))
    push!(g.inclist, Array(E, 0))
    v
end
add_vertex!(g::GenericGraph, x) = add_vertex!(g, make_vertex(g, x))

function add_edge!{V,E}(g::GenericGraph{V,E}, u::V, v::V, e::E)
    # add an edge e between u and v
    @assert edge_index(e) == num_edges(g) + 1
    ui = vertex_index(u, g)::Int
    push!(g.edges, e)
    push!(g.adjlist[ui], v)
    push!(g.inclist[ui], e)
    if !g.is_directed
        vi = vertex_index(v, g)::Int
        push!(g.adjlist[vi], u)
        push!(g.inclist[vi], revedge(e))
    end
    e
end

add_edge!{V,E}(g::GenericGraph{V,E}, e::E) = add_edge!(g, source(e, g), target(e, g), e)
add_edge!{V,E}(g::GenericGraph{V,E}, u::V, v::V) = add_edge!(g, u, v, make_edge(g, u, v))

# construction

function simple_graph(n::Int; is_directed::Bool=true)
    vertices = 1:n
    edges = Array(IEdge, 0)
    adjlist = Array(Vector{Int}, n)
    inclist = Array(Vector{IEdge}, n)
    for i = 1 : n
        adjlist[i] = Array(Int, 0)
        inclist[i] = Array(IEdge, 0)
    end
    SimpleGraph(is_directed, vertices, edges, adjlist, inclist)
end

function graph{V,E}(vty::Type{V}, ety::Type{E}; is_directed::Bool=true)
    vertices = Array(V, 0)
    edges = Array(E, 0)
    adjlist = Array(Vector{V}, 0)
    inclist = Array(Vector{E}, 0)
    GenericGraph{V,E,Vector{V},Vector{E},Vector{Vector{V}},Vector{Vector{E}}}(
        is_directed, vertices, edges, adjlist, inclist)    
end

