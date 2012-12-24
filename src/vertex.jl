##############################################################################
#
# Basic Vertex type definition and constructors
#
##############################################################################

type Vertex
    id::Int
    name::UTF8String
    # Other metadata...
end
Vertex(id::Real, name::String) = Vertex(int(id), utf8(name))
Vertex(id::Real) = Vertex(int(id), utf8(""))

##############################################################################
#
# Getters
#
##############################################################################

id(v::Vertex) = v.id
name(v::Vertex) = v.name
