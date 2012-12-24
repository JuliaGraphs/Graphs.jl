##############################################################################
#
# Basic Edge type definition and constructors
#
##############################################################################

type UndirectedEdge
    out::Vertex
    in::Vertex
    name::UTF8String
    weight::Float64
    # Other metadata...

    # To simplify things, an UndirectedEdge always goes from the lower ID to
    # the higher ID Vertex.
    function UndirectedEdge(out_vertex::Vertex,
                            in_vertex::Vertex,
                            name::UTF8String,
                            weight::Float64)
      if id(out_vertex) > id(in_vertex)
        new(in_vertex, out_vertex, name, weight)
      else
        new(out_vertex, in_vertex, name, weight)
      end
    end
end
function UndirectedEdge(out_v::Vertex, in_v::Vertex)
    UndirectedEdge(out_v,
                   in_v,
                   utf8(""),
                   1.0)
end
function UndirectedEdge(out_id::Real, in_id::Real)
    UndirectedEdge(Vertex(int(out_id), utf8("")),
                   Vertex(int(in_id), utf8("")),
                   utf8(""),
                   1.0)
end

type DirectedEdge
    out::Vertex
    in::Vertex
    name::UTF8String
    weight::Float64
    # Other metadata...
end
function DirectedEdge(out_vertex::Vertex, in_vertex::Vertex)
    DirectedEdge(out_vertex,
                 in_vertex,
                 utf8(""),
                 1.0)
end
function DirectedEdge(out_id::Real, in_id::Real)
    DirectedEdge(Vertex(int(out_id), utf8("")),
                 Vertex(int(in_id), utf8("")),
                 utf8(""),
                 1.0)
end
typealias Edge Union(UndirectedEdge, DirectedEdge)

##############################################################################
#
# Getters
#
##############################################################################

out(e::DirectedEdge) = e.out
in(e::DirectedEdge) = e.in
ends(e::DirectedEdge) = [e.out, e.in]
ends(e::UndirectedEdge) = Set(e.out, e.in)
name(e::Edge) = e.name
weight(e::Edge) = e.weight

##############################################################################
#
# Comparisons
#
##############################################################################

function isequal(e1::Edge, e2::Edge)
    return isequal(e1.out, e2.out) && isequal(e1.in, e2.in) &&
            isequal(e1.name, e2.name) && isequal(e1.weight, e2.weight)
end
