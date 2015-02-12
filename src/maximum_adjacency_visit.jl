# Maximum adjacency visit / traversal


#################################################
#
#  Maximum adjacency visit
#
#################################################

type MaximumAdjacency <: AbstractGraphVisitAlgorithm
end

function maximum_adjacency_visit_impl!{V,E,W}(
	graph::AbstractGraph{V,E},	                      # the graph
	pq::Collections.PriorityQueue{V,W},               # priority queue
	visitor::AbstractGraphVisitor,                    # the visitor
  edge_weights::AbstractEdgePropertyInspector{W},   # edge weights
  colormap::Vector{Int})                            # traversal status
	
	while !isempty(pq)
    u = Collections.dequeue!(pq)
    discover_vertex!(visitor, u)
    for e in out_edges(u, graph)
      examine_edge!(visitor, e, 0)
      v = e.target

      if haskey(pq,v)
        pq[v] += edge_property(edge_weights, e, graph)
      end
    end
    close_vertex!(visitor, u)
	end
	
end

function traverse_graph{V,E,W}(
	graph::AbstractGraph{V,E},
	alg::MaximumAdjacency,
	s::V,
	visitor::AbstractGraphVisitor,
  edge_weights::AbstractEdgePropertyInspector{W},
  colormap::Vector{Int} )
	
 	pq = Collections.PriorityQueue{V,W}(Base.Order.Reverse)

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
	maximum_adjacency_visit_impl!(graph, pq, visitor, edge_weights, colormap)	
end

#################################################
#
#  Minimum Cut Visitor
#
#################################################

type MinCutVisitor{G<:AbstractGraph,W} <: AbstractGraphVisitor
  graph::G
  parities::Vector{Bool}
  colormap::Vector{Int}
  bestweight::W
  cutweight::W
  visited::Integer
  edge_weights::AbstractEdgePropertyInspector{W}
end

function MinCutVisitor{V,E,W}(graph::AbstractGraph{V,E}, weights::AbstractEdgePropertyInspector{W})
  n = num_vertices(graph)
  parities = falses(n)
  MinCutVisitor{typeof(graph),W}(graph, parities, zeros(n), Inf, 0, 0, weights)
end

function discover_vertex!(vis::MinCutVisitor, v)
  vi = vertex_index(v,vis.graph)
  vis.parities[vi] = false
  vis.colormap[vi] = 1
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

function min_cut{V,E,W}(
  graph::AbstractGraph{V,E},
  edge_weights::AbstractEdgePropertyInspector{W})
  
  @graph_requires graph incidence_list vertex_list
  visitor = MinCutVisitor(graph, edge_weights)
  colormap = zeros(Int, num_vertices(graph))
  
  traverse_graph(graph, MaximumAdjacency(), first( vertices(graph) ), visitor, edge_weights, colormap)

  return( visitor.parities, visitor.bestweight)
end

function min_cut{V,E,W}(
  graph::AbstractGraph{V,E},
  edge_weight_vec::Vector{W})
  
  @graph_requires graph incidence_list vertex_list

  edge_weights = VectorEdgePropertyInspector(edge_weight_vec)
  visitor = MinCutVisitor(graph, edge_weights)
  colormap = zeros(Int, num_vertices(graph))
  
  traverse_graph(graph, MaximumAdjacency(), first( vertices(graph) ), visitor, edge_weights, colormap)

  return( visitor.parities, visitor.bestweight)
end
