##############################################################################
#
# Basic Vertex type definition and constructors
#
##############################################################################

type Vertex
    id::Int
    label::UTF8String
    # Other metadata...
end
Vertex(id::Real, label::String) = Vertex(int(id), utf8(label))
Vertex(id::Real) = Vertex(int(id), utf8(""))

##############################################################################
#
# Getters
#
##############################################################################

id(v::Vertex) = v.id
label(v::Vertex) = v.label

##############################################################################
#
# Comparisons
#
##############################################################################

function isequal(v1::Vertex, v2::Vertex)
  return isequal(v1.id, v2.id) && isequal(v1.label, v2.label)
end
