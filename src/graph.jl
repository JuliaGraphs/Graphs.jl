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
    vi = vertex_index(v)
    if vi != length(g.vertices) + 1
        throw(ArgumentError("Invalid vertex index."))
    end
    push!(g.vertices, v)
    push!(g.adjlist, Array(V, 0))
    push!(g.inclist, Array(E, 0))
    v
end

add_vertex!{K}(g::GenericGraph{KeyVertex{K}}, key::K) = add_vertex!(g, KeyVertex(length(g.vertices)+1, key))
add_vertex!(g::GenericGraph{ExVertex}, label::String) = add_vertex!(g, ExVertex(length(g.vertices)+1, label))

function add_edge!{V,E}(g::GenericGraph{V,E}, e::E)
    nv::Int = num_vertices(g)   
    
    u::V = source(e)
    v::V = target(e)
    ui::Int = vertex_index(u, g)
    vi::Int = vertex_index(v, g)
    
    if !(ui >= 1 && ui <= nv && vi >= 1 && vi <= nv)
        throw(ArgumentError("u or v is not a valid vertex."))
    end
    ei::Int = length(g.edges) + 1
    
    if edge_index(e) != ei
        throw(ArgumentError("Invalid edge index."))
    end
    
    push!(g.edges, e)
    push!(g.adjlist[ui], v)
    push!(g.inclist[ui], e)
    
    if !g.is_directed
        push!(g.adjlist[vi], u)       
        push!(g.inclist[vi], revedge(e))
    end
    e
end

add_edge!{V}(g::GenericGraph{V,Edge{V}}, u::V, v::V) = add_edge!(g, IEdge(length(g.edges)+1, u, v))
add_edge!{V}(g::GenericGraph{V,ExEdge{V}}, u::V, v::V) = add_edge!(g, ExEdge{V}(length(g.edges)+1, u, v))

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

