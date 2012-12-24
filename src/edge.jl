type Edge
	out_node::Node
	in_node::Node
	name::UTF8String
	# Other metadata...
end
Edge(out_node::Node, in_node::Node) = Edge(out_node, in_node, utf8(""))
Edge(out_id::Real, in::id::Real) = Edge(Node(int(out_id), utf8("")),
	                                    Node(int(in_id), utf8("")),
	                                    utf8(""))
# TODO: out(Edge), in(Edge), name(Edge)
