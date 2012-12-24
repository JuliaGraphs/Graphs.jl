type Node
	id::Int
	name::UTF8String
	# Other metadata...
end
Node(id::Real, name::String) = Node(int(id), utf8(name))
Node(id::Real) = Node(int(id), utf8(""))
# TODO: id(Node), name(Node)
