# Functions for representing graphs in GraphViz's dot format
# http://www.graphviz.org/
# http://www.graphviz.org/Documentation/dotguide.pdf
# http://www.graphviz.org/pub/scm/graphviz2/doc/info/lang.html

# Write the dot representation of a graph to a file by name.
function to_dot(graph::AbstractGraph, filename::String)
    f = open(filename,"w")
        to_dot(graph, f)
    close(f)

end

# Get the dot representation of a graph as a string.
function to_dot(graph::AbstractGraph)
    str = IOString()
    to_dot(graph, str)
    takebuf_string(str)
end

# Write the dot representation of a graph to a stream.
function to_dot(graph::AbstractGraph, stream::IO)
    write(stream, "$(graph_type_string(graph)) graphname {\n")
    for edge in edges(graph)
        write(stream, to_dot(edge))
    end

    for vertex in vertices(graph)
        write(stream, to_dot(vertex))
    end
    write(stream, "}\n")
    stream
end

function graph_type_string(graph::DirectedGraph)
    "digraph"
end

function graph_type_string(graph::UndirectedGraph)
    "graph"
end

# The dot representation of an edge.
function to_dot(edge::Edge)
    en = ends(edge)
    state = start(en)
    first, state = next(en,state)
    second, state = next(en, state)
    "$(id(first)) $(edge_op(edge)) $(id(second)) $(to_dot(attributes(edge)))\n"
end

function edge_op(edge::UndirectedEdge)
    "--"
end

function edge_op(edge::DirectedEdge)
    "->"
end

function to_dot(attrs::Dict{UTF8String,Any})
    if isempty(attrs)
        ""
    else
        f = (t::Tuple) -> "\"$(t[1])\"=\"$(t[2])\""
        string("[",join(map(f,collect(attrs)),","),"]")
    end
end

function to_dot(Vertex)
    ""
end
