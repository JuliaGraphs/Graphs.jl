##############################################################################
#
# Basic Edge type definition and constructors
#
##############################################################################

type UndirectedEdge
    a::Vertex
    b::Vertex
    label::UTF8String
    weight::Float64
    attributes::Dict{UTF8String, Any}

    # To simplify things, an UndirectedEdge always goes from the
    #  lower ID Vertex towards the higher ID Vertex.
    function UndirectedEdge(a_vertex::Vertex,
                            b_vertex::Vertex,
                            label::UTF8String,
                            weight::Float64,
                            attributes::Dict{UTF8String, Any})
      if id(a_vertex) > id(b_vertex)
        new(b_vertex, a_vertex, label, weight, attributes)
      else
        new(a_vertex, b_vertex, label, weight, attributes)
      end
    end
end
function UndirectedEdge(a::Vertex, b::Vertex)
    UndirectedEdge(a,
                   b,
                   utf8(""),
                   1.0,
                   Dict{UTF8String, Any}())
end
function UndirectedEdge(out_id::Real, in_id::Real)
    UndirectedEdge(Vertex(int(out_id), utf8("")),
                   Vertex(int(in_id), utf8("")),
                   utf8(""),
                   1.0,
                   Dict{UTF8String, Any}())
end

type DirectedEdge
    out::Vertex
    in::Vertex
    label::UTF8String
    weight::Float64
    attributes::Dict{UTF8String, Any}
end
function DirectedEdge(out_vertex::Vertex, in_vertex::Vertex)
    DirectedEdge(out_vertex,
                 in_vertex,
                 utf8(""),
                 1.0,
                 Dict{UTF8String, Any}())
end
function DirectedEdge(out_id::Real, in_id::Real)
    DirectedEdge(Vertex(int(out_id), utf8(""), Dict{UTF8String, Any}()),
                 Vertex(int(in_id), utf8(""), Dict{UTF8String, Any}()),
                 utf8(""),
                 1.0,
                 Dict{UTF8String, Any}())
end
typealias Edge Union(UndirectedEdge, DirectedEdge)

##############################################################################
#
# Getters
#
##############################################################################

ends(e::DirectedEdge) = [e.out, e.in]
ends(e::UndirectedEdge) = Set(e.a, e.b)
out(e::DirectedEdge) = e.out
in(e::DirectedEdge) = e.in
label(e::Edge) = e.label
weight(e::Edge) = e.weight
attributes(e::Edge) = e.attributes

##############################################################################
#
# Comparisons
#
##############################################################################

function isequal(e1::UndirectedEdge, e2::UndirectedEdge)
    return isequal(e1.a, e2.a) && isequal(e1.b, e2.b) &&
            isequal(e1.label, e2.label) && isequal(e1.weight, e2.weight)
end

function isequal(e1::DirectedEdge, e2::DirectedEdge)
    return isequal(e1.out, e2.out) && isequal(e1.in, e2.in) &&
            isequal(e1.label, e2.label) && isequal(e1.weight, e2.weight)
end

##############################################################################
#
# Hashing
#
##############################################################################

function hash(e::Edge)
  s = ""
  for v in ends(e)
    s *= string(hash(v))
  end
  hash(string(s, hash(label), hash(string(weight)), hash(attributes)))
end
