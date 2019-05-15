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

mutable struct GenericIncidenceList{V, E, VList, IncList} <: AbstractGraph{V, E}
    is_directed::Bool
    vertices::VList
    nedges::Int
    inclist::IncList
end

const SimpleIncidenceList = GenericIncidenceList{Int, IEdge, UnitRange{Int}, Vector{Vector{IEdge}}}
const IncidenceList{V,E} = GenericIncidenceList{V, E, Vector{V}, Vector{Vector{E}}}

@graph_implements GenericIncidenceList vertex_list vertex_map edge_map adjacency_list incidence_list

# construction

simple_inclist(nv::Integer; is_directed::Bool=true) =
    SimpleIncidenceList(is_directed, intrange(nv), 0, multivecs(IEdge, nv))

inclist(vs::Vector{V}, ::Type{E}; is_directed::Bool = true) where {V,E} =
    IncidenceList{V,E}(is_directed, vs, 0, multivecs(E, length(vs)))

inclist(::Type{V}, ::Type{E}; is_directed::Bool = true) where {V,E} = inclist(V[], E; is_directed=is_directed)
inclist(vs::Vector{V}; is_directed::Bool = true) where {V} = inclist(vs, Edge{V}; is_directed=is_directed)
inclist(::Type{V}; is_directed::Bool = true) where {V} = inclist(V[], Edge{V}; is_directed=is_directed)

# First constructors on Dict Inc List version (reusing GenericIncidenceList container and functions, few dispatch changes required)
const IncidenceDict{V,E} = GenericIncidenceList{V, E, Dict{Int,V}, Dict{Int,Vector{E}}}
incdict(vs::Dict{Int,V}, ::Type{E}; is_directed::Bool = true) where {V,E} =
    IncidenceDict{V,E}(is_directed, vs, 0, Dict{Int, E}())
incdict(::Type{V}; is_directed::Bool = true) where {V} = incdict(Dict{Int,V}(), Edge{V}; is_directed=is_directed)


# required interfaces

is_directed(g::GenericIncidenceList) = g.is_directed

num_vertices(g::GenericIncidenceList) = length(g.vertices)
# vertices(g::GenericIncidenceList) = g.vertices

# dictionary enables version
vertices_specific(a::UnitRange{Int}) = a
vertices_specific(a::Vector{V}) where {V} = a
vertices_specific(d::Dict{Int,V}) where {V} = collect(values(d))
vertices(g::GenericIncidenceList) = vertices_specific(g.vertices)

num_edges(g::GenericIncidenceList) = g.nedges

edge_index(e::E, g::GenericIncidenceList{V,E}) where {V,E} = edge_index(e)

out_edges(v::V, g::GenericIncidenceList{V}) where {V} = g.inclist[vertex_index(v, g)]
out_degree(v::V, g::GenericIncidenceList{V}) where {V} = length(out_edges(v, g))
out_neighbors(v::V, g::GenericIncidenceList{V}) where {V} = TargetIterator(g, g.inclist[vertex_index(v, g)])

"""
Find neighbors connected by directed edge towards `vert`.
"""
function in_neighbors(vert::V, gr::GenericIncidenceList{V, Edge{V}, Vector{V}}) where {V}
  inclist = gr.inclist
  targid = vert.index
  inlist = V[]
  for edgelist in inclist
    for ed in edgelist
      if ed.target.index == targid
        push!(inlist, ed.source)
      end
    end
  end
  return inlist
end
function in_neighbors(vert::V, gr::GenericIncidenceList{V, Edge{V}, Dict{Int, V}}) where {V}
  inclist = gr.inclist
  targid = vert.index
  inlist = V[]
  for (key,edgelist) in inclist
    for ed in edgelist
      if ed.target.index == targid
        push!(inlist, ed.source)
      end
    end
  end
  return inlist
end

# mutation

function add_vertex!(vertices::Vector{V}, inclist::Vector{E}, v::V) where {V,E}
    push!(vertices, v)
    push!(inclist, Array{E}(undef, 0))
    v
end
function add_vertex!(vertices::Dict{Int, V}, inclist::Dict{Int,E}, v::V) where {V,E}
  if haskey(vertices, v.index)
    error("Already have index $(v.index) in g")
  end
  vertices[v.index] = v
  inclist[v.index] = Array{E}(undef, 0)
  v
end
function add_vertex!(g::GenericIncidenceList{V,E}, v::V) where {V,E}
  add_vertex!(g.vertices, g.inclist, v)
end

function delete_vertex!(vertices::Dict{Int, V}, inclist::Dict{Int, E}, v::V, outnei) where {V,E}
  nedges = 0
  # delete all connected edges
  for vid in union(map(x->x.index, outnei), v.index)
    count = 0
    keeplist = E()
    for ed in inclist[vid]
      count += 1
      # want to delete any source or dest edge pointing to v (not whole inclist)
      if ed.source.index == v.index || ed.target.index == v.index
        # this edge must be deleted from Array
        nedges += 1
      else
        push!(keeplist, ed)
      end
    end
    inclist[vid] = keeplist
  end
  delete!(inclist, v.index)
  delete!(vertices, v.index)
  return nedges
end

function delete_vertex!(v::V, g::GenericIncidenceList{V,E}) where {V,E}
  # find list of vertices that may have edges to v
  possv = collect(out_neighbors(v, g))

  # delete the vertex
  ned = delete_vertex!(g.vertices, g.inclist, v, possv)

  g.nedges -= (is_directed(g) ? ned : round(Int,ned/2))

  return nothing
end


add_vertex!(g::GenericIncidenceList, x) = add_vertex!(g, make_vertex(g, x))

function add_edge!(g::GenericIncidenceList{V,E}, u::V, v::V, e::E) where {V,E}
    # add an edge between (u, v)
    ui::Int = vertex_index(u, g)
    push!(g.inclist[ui], e)
    g.nedges += 1

    if !g.is_directed
        vi::Int = vertex_index(v, g)
        push!(g.inclist[vi], revedge(e))
    end
end

add_edge!(g::GenericIncidenceList{V,E}, e::E) where {V,E} = add_edge!(g, source(e, g), target(e, g), e)
add_edge!(g::GenericIncidenceList{V, E}, u::V, v::V) where {V,E} = add_edge!(g, u, v, make_edge(g, u, v))
