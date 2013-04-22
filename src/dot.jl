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
    if implements_edge_list(graph)
        for edge in edges(graph)
            write(stream,"$(vertex_index(source(edge))) $(edge_op(graph)) $(vertex_index(target(edge)))\n")
        end
    elseif implements_vertex_list(graph) && (implements_incidence_list(graph) || implements_adjacency_list(graph))
        for vertex in vertices(graph)
            for n in out_neighbors(vertex, graph)
                write(stream,"$(vertex_index(vertex)) $(edge_op(graph)) $(vertex_index(n))\n")
            end
        end
    else
        throw(ArgumentError("More graph Concepts needed: dot serialization requires iteration over edges or iteration over vertices and neighbors."))
    end
    write(stream, "}\n")
    stream
end

function graph_type_string(graph::AbstractGraph)
    is_directed(graph) ? "digraph" : "graph"
end

function edge_op(graph::AbstractGraph)
    is_directed(graph) ? "->" : "--"
end

function plot(g::AbstractGraph)
    stdin, proc = writesto(`neato -Tx11`)
    to_dot(g, stdin)
    close(stdin)
end
