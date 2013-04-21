
###########################################################
#
#   GenericIncidenceList{V, E, VList, IncList}
#
#   V :         vertex type
#   E :         edge type
#   VList :     the type of vertex list
#   IncList:    the incidence list
#
###########################################################

type GenericIncidenceList{V, E, VList, IncList} <: AbstractGraph{V, E}
    is_directed::Bool    
    vertices::VList
    nedges::Int
    inclist::IncList
end

typealias SimpleIncidenceList GenericIncidenceList{Int, IEdge, Range1{Int}, Vector{Vector{IEdge}}}
typealias IncidenceList{V} GenericIncidenceList{V, Edge{V}, Vector{V}, Vector{Vector{Edge{V}}}}

@graph_implements GenericIncidenceList vertex_list vertex_map edge_map adjacency_list incidence_list

# required interfaces

is_directed(g::GenericIncidenceList) = g.is_directed

num_vertices(g::GenericIncidenceList) = length(g.vertices)
vertices(g::GenericIncidenceList) = g.vertices

num_edges(g::GenericIncidenceList) = g.nedges

vertex_index(v, g::GenericIncidenceList) = vertex_index(v)
edge_index(e, g::GenericIncidenceList) = edge_index(e)

out_degree(v, g::GenericIncidenceList) = length(g.inclist[vertex_index(v)])
out_edges(v, g::GenericIncidenceList) = g.inclist[vertex_index(v)]

out_neighbors(v, g::GenericIncidenceList) = out_neighbors_proxy(g.inclist[vertex_index(v)])

# mutation

function add_vertex!{V}(g::IncidenceList{V}, v::V)
    nv::Int = num_vertices(g)
    iv::Int = vertex_index(v)
    if iv != nv + 1
        throw(ArgumentError("Invalid vertex index."))
    end        
    
    push!(g.vertices, v)
    push!(g.inclist, Array(Edge{V},0))
    v
end

function add_vertex!{K}(g::IncidenceList{KeyVertex{K}}, key::K)
    nv::Int = num_vertices(g)
    v = KeyVertex(nv+1, key)
    push!(g.vertices, v)
    push!(g.inclist, Array(Edge{KeyVertex{K}},0))
    v
end


function add_edge!{V}(g::GenericIncidenceList{V, Edge{V}}, u::V, v::V)
    nv::Int = num_vertices(g)
    ui::Int = vertex_index(u)
    vi::Int = vertex_index(v)
    
    if !(ui >= 1 && ui <= nv && vi >= 1 && vi <= nv)
        throw(ArgumentError("u or v is not a valid vertex."))
    end
    ei::Int = (g.nedges += 1)
    push!(g.inclist[ui], Edge(ei, u, v))
    
    if !g.is_directed
        push!(g.inclist[vi], Edge(ei, v, u))
    end
end

# mutation

function simple_inclist(nv::Int; is_directed::Bool = true)
    inclist = Array(Vector{Edge{Int}}, nv)    
    for i = 1 : nv
        inclist[i] = Array(Edge{Int}, 0)
    end
    SimpleIncidenceList(is_directed, 1:nv, 0, inclist)
end

function inclist{V}(vty::Type{V}; is_directed::Bool = true)
    inclist = Array(Vector{Edge{V}}, 0)
    IncidenceList{V}(is_directed, Array(V, 0), 0, inclist)
end




