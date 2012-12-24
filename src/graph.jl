# TODO: Enforce integrity constraint that min ID is 1, max ID = length(nodes)
type Graph
	nodes::Vector{Node}
	edges::Vector{Edge}
end
# TODO: nodes(Graph), edges(Graph)
# TODO: DirectedGraph, Digraph, Graph, UndirectedGraph
# Every row is an edge
# Assume OutID, InID format

function Graph(numeric_edges::Matrix{Int}, node_names::Vector{UTF8String})
	N_NODES = length(node_names)
	N_EDGES = size(numeric_edges, 1)
	nodes = Array(Node, N_NODES)
	for i in 1:N_NODES
		nodes[i] = Node(i, node_names[i])
	end
	edges = Array(Edge, N_EDGES)
	for i in 1:N_EDGES
		edges[i] = Edge(nodes[numeric_edges[i, 1]],
						nodes[numeric_edges[i, 2]],
						utf8(""))
	end
	Graph(nodes, edges)
end

const DEFAULT_MAX_NODES = 1_000
function Graph{T <: String}(edges::Matrix{T})
	node_names = Array(UTF8String, DEFAULT_MAX_NODES)
	node_ids = Dict{UTF8String, Int}()
	next_node_id = 1
	numeric_edges = Array(Int, size(edges))
	for i in 1:size(edges, 1)
		if length(node_names) - 1 <= next_node_id
			grow(node_names, 2 * length(node_names))
		end
		out_node_name, in_node_name = edges[i, 1], edges[i, 2]
		out_node_id = get(node_ids, out_node_name, 0)
		if out_node_id == 0
			out_node_id = next_node_id
			node_ids[out_node_name] = out_node_id
			node_names[out_node_id] = out_node_name
			next_node_id += 1
		end
		in_node_id = get(node_ids, in_node_name, 0)
		if in_node_id == 0
			in_node_id = next_node_id
			node_ids[in_node_name] = in_node_id
			node_names[in_node_id] = in_node_name
			next_node_id += 1
		end
		numeric_edges[i, 1], numeric_edges[i, 2] = out_node_id, in_node_id
	end
	Graph(numeric_edges, node_names[1:(next_node_id - 1)])
end

function adjacency_matrix(g::Graph)
	N = length(g.nodes) # TODO: Make this length(nodes(g))
	a = zeros(Int, N, N)
	for i in 1:length(g.edges)
		edge = g.edges[i]
		a[edge.out_node.id, edge.in_node.id] = 1
	end
	return a
end
