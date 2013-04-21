##############################################################################
#
# Basic Vertex type definition and constructors
#
##############################################################################

type Vertex
    id::Int
    label::UTF8String
    attributes::Dict{UTF8String, Any}
end
Vertex(id::Real, label::String) = Vertex(int(id), utf8(label), Dict{UTF8String, Any}())
Vertex(id::Real) = Vertex(int(id), utf8(""), Dict{UTF8String, Any}())

##############################################################################
#
# Getters
#
##############################################################################

id(v::Vertex) = v.id
label(v::Vertex) = v.label
attributes(v::Vertex) = v.attributes

##############################################################################
#
# Comparisons
#
##############################################################################

function isequal(v1::Vertex, v2::Vertex)
  return isequal(v1.id, v2.id) &&
          isequal(v1.label, v2.label) &&
          isequal(v1.attributes, v2.attributes)
end

##############################################################################
#
# Hashing
#
##############################################################################

function hash(v::Vertex)
	hash(string(hash(string(v.id)), hash(v.label), hash(v.attributes)))
end
