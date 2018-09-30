# Maximum adjacency visit / traversal


#################################################
#
#  Maximum adjacency visit
#
#################################################

mutable struct MaximumAdjacency <: AbstractGraphVisitAlgorithm
end

abstract type AbstractMASVisitor <: AbstractGraphVisitor end
# @static if VERSION > v"0.6-"
#   abstract type AbstractMASVisitor <: AbstractGraphVisitor end
# else
#   abstract AbstractMASVisitor <: AbstractGraphVisitor
#   import Base.Collections.PriorityQueue
# end

function maximum_adjacency_visit_impl!(
  graph::AbstractGraph{V,E},	                      # the graph
  pq::PriorityQueue{V,W},                           # priority queue
  visitor::AbstractMASVisitor,                      # the visitor
  colormap::Vector{Int}) where {V,E,W}              # traversal status

  while !isempty(pq)
    u = DataStructures.dequeue!(pq)
    # u = VERSION > v"0.6-" ? DataStructures.dequeue!(pq) : Collections.dequeue!(pq)
    discover_vertex!(visitor, u)
    for e in out_edges(u, graph)
      examine_edge!(visitor, e, 0)
      v = e.target

      if haskey(pq,v)
        pq[v] += edge_property(visitor.edge_weights, e, graph)
      end
    end
    close_vertex!(visitor, u)
  end

end

function traverse_graph(
  graph::AbstractGraph{V,E},
  alg::MaximumAdjacency,
  s::V,
  visitor::AbstractMASVisitor,
  colormap::Vector{Int},
  ::Type{W}) where {V,E,W}

  # @show Base.Order.Reverse
  # @show Base.Order.ReverseOrdering
  # PriorityQueue{K, V}(::Type{K}, ::Type{V}, o::Ordering) is deprecated, use PriorityQueue{K, V, typeof(o)}(o)
  # pq = DataStructures.PriorityQueue(V,W,Base.Order.Reverse)
  # pq = DataStructures.PriorityQueue(V,W,Base.Order.Reverse)
  # @show pq
  pq = DataStructures.PriorityQueue{V,W}(Base.Order.Reverse)
  # @show pq
  # pq = DataStructures.PriorityQueue{V,W,Base.Order.Reverse}()

  # Set number of visited neighbours for all vertices to 0
  for v in vertices(graph)
    pq[v] = zero(W)
  end

  @graph_requires graph incidence_list vertex_list
  @assert haskey(pq,s)
  @assert num_vertices(graph) >= 2

  #Give the starting vertex high priority
  pq[s] = one(W)

  #start traversing the graph
  maximum_adjacency_visit_impl!(graph, pq, visitor, colormap)
end


#################################################
#
#  Visitors
#
#################################################


#################################################
#
#  Minimum Cut Visitor
#
#################################################

mutable struct MinCutVisitor{G<:AbstractGraph,V,W} <: AbstractMASVisitor
  graph::G
  parities::Vector{Bool}
  colormap::Vector{Int}
  bestweight::W
  cutweight::W
  visited::Integer
  edge_weights::AbstractEdgePropertyInspector{W}
  vertices::Vector{V}
end

function MinCutVisitor(graph::AbstractGraph{V,E}, edge_weights::AbstractEdgePropertyInspector{W}) where {V,E,W}
  n = num_vertices(graph)
  parities = falses(n)
  MinCutVisitor{typeof(graph),V,W}(graph, parities, zeros(n), Inf, 0, 0, edge_weights, V[])
end

function discover_vertex!(vis::MinCutVisitor, v)
  vi = vertex_index(v,vis.graph)
  vis.parities[vi] = false
  vis.colormap[vi] = 1
  push!(vis.vertices,v)
  true
end

function examine_edge!(vis::MinCutVisitor, e, color::Int)
  vi = vertex_index(e.target,vis.graph)
  ew = edge_property(vis.edge_weights, e, vis.graph)

  # if the target of e is already marked then decrease cutweight
  # otherwise, increase it

  if vis.colormap[vi] != color # here color is 0
    vis.cutweight -= ew
  else
    vis.cutweight += ew
  end
end

function close_vertex!(vis::MinCutVisitor, v)
  vi = vertex_index(v,vis.graph)
  vis.colormap[vi] = 2
  vis.visited += 1

  if vis.cutweight < vis.bestweight && vis.visited < num_vertices(vis.graph)
    vis.bestweight = vis.cutweight
    for u in vertices(vis.graph)
      ui = vertex_index(u, vis.graph)
      vis.parities[ui] = ( vis.colormap[ui] == 2)
    end
  end
end

#################################################
#
#  MAS Visitor
#
#################################################

mutable struct MASVisitor{V,W} <: AbstractMASVisitor
  io::IO
  vertices::Vector{V}
  edge_weights::AbstractEdgePropertyInspector{W}
  log::Bool
end

function discover_vertex!(visitor::MASVisitor, v)
  push!(visitor.vertices,v)
  visitor.log ? println(visitor.io, "discover vertex: $v") : nothing
end

function examine_edge!(visitor::MASVisitor, e, color::Int)
  visitor.log ? println(visitor.io, " -- examine edge: $e") : nothing
end

function close_vertex!(visitor::MASVisitor, v)
  visitor.log ? println(visitor.io, "close vertex: $v") : nothing
end

#################################################
#
#  Minimum Cut
#
#################################################

function min_cut(
  graph::AbstractGraph{V,E},
  edge_weights::AbstractEdgePropertyInspector{W}) where {V,E,W}

  @graph_requires graph incidence_list vertex_list
  visitor = MinCutVisitor(graph, edge_weights)
  colormap = zeros(Int, num_vertices(graph))

  traverse_graph(graph, MaximumAdjacency(), first( vertices(graph) ), visitor, colormap, W)

  return( visitor.parities, visitor.bestweight)
end

function min_cut(
  graph::AbstractGraph{V,E},
  edge_weight_vec::Vector{W}) where {V,E,W}

  @graph_requires graph incidence_list vertex_list

  edge_weights = VectorEdgePropertyInspector(edge_weight_vec)
  visitor = MinCutVisitor(graph, edge_weights)
  colormap = zeros(Int, num_vertices(graph))

  traverse_graph(graph, MaximumAdjacency(), first( vertices(graph) ), visitor, colormap, W)

  return( visitor.parities, visitor.bestweight)
end

function min_cut(graph::AbstractGraph{V,E}) where {V,E}
  m = num_edges(graph)
  min_cut(graph,ones(m))
end

function maximum_adjacency_visit(graph::AbstractGraph{V,E}, edge_weights::AbstractEdgePropertyInspector{W}; log::Bool=false, io::IO=stdout) where {V,E,W}
  visitor = MASVisitor(io, V[],edge_weights,log)
  traverse_graph(graph, MaximumAdjacency(), first(vertices(graph)), visitor, zeros(Int, num_vertices(graph)), W)
  visitor.vertices
end

function maximum_adjacency_visit(graph::AbstractGraph{V,E}, edge_weight_vec::Vector{W}; log::Bool=false, io::IO=stdout) where {V,E,W}
  edge_weights = VectorEdgePropertyInspector(edge_weight_vec)
  visitor = MASVisitor(io, V[],edge_weights,log)
  traverse_graph(graph, MaximumAdjacency(), first(vertices(graph)), visitor, zeros(Int, num_vertices(graph)), W)
  visitor.vertices
end

function maximum_adjacency_visit(graph::AbstractGraph{V,E}; log::Bool=false, io::IO=stdout) where {V,E}
  m = num_edges(graph)
  maximum_adjacency_visit(graph,ones(m); log=log, io=io)
end
