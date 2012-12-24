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
end
function UndirectedEdge(out_vertex::Vertex, in_vertex::Vertex)
    UndirectedEdge(out_vertex,
                   in_vertex,
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
name(e::DirectedEdge) = e.name
weight(e::DirectedEdge) = e.weight
ends(e::DirectedEdge) = [e.out, e.in]
