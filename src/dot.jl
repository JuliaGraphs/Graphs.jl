# Functions for representing graphs in GraphViz's dot format
# http://www.graphviz.org/
# http://www.graphviz.org/Documentation/dotguide.pdf
# http://www.graphviz.org/pub/scm/graphviz2/doc/info/lang.html

# Write the dot representation of a graph to a file by name.
function to_dot(graph::AbstractGraph, filename::String)
    open(filename,"w") do f
        to_dot(graph, f)
    end
end

# Get the dot representation of a graph as a string.
function to_dot(graph::AbstractGraph)
    str = IOBuffer()
    to_dot(graph, str)
    takebuf_string(str)
end

# Write the dot representation of a graph to a stream.
function to_dot{G<:AbstractGraph}(graph::G, stream::IO)
    has_vertex_attrs = method_exists(attributes, (vertex_type(graph), G))
    has_edge_attrs = method_exists(attributes, (edge_type(graph), G))

    write(stream, "$(graph_type_string(graph)) graphname {\n")
    if implements_edge_list(graph) && implements_vertex_map(graph)
        for edge in edges(graph)
            write(stream,"$(vertex_index(source(edge), graph)) $(edge_op(graph)) $(vertex_index(target(edge), graph))\n")
        end
    elseif implements_vertex_list(graph) && (implements_incidence_list(graph) || implements_adjacency_list(graph))
        for vertex in vertices(graph)
            if has_vertex_attrs && !isempty(attributes(vertex, graph))
                write(stream, "$(vertex_index(vertex, graph)) $(to_dot(attributes(vertex, graph)))\n")
            end
            if implements_incidence_list(graph)
                for e in out_edges(vertex, graph)
                    n = target(e, graph)
                    if is_directed(graph) || vertex_index(n, graph) > vertex_index(vertex, graph)
                        write(stream,"$(vertex_index(vertex, graph)) $(edge_op(graph)) $(vertex_index(n, graph))$(has_edge_attrs ? string(" ", to_dot(attributes(e, graph))) : "")\n")
                    end
                end
            else # implements_adjacency_list
                for n in out_neighbors(vertex, graph)
                    if is_directed(graph) || vertex_index(n, graph) > vertex_index(vertex, graph)
                        write(stream,"$(vertex_index(vertex, graph)) $(edge_op(graph)) $(vertex_index(n,graph))\n")
                    end
                end
            end
        end
    else
        throw(ArgumentError("More graph Concepts needed: dot serialization requires iteration over edges or iteration over vertices and neighbors."))
    end
    write(stream, "}\n")
    stream
end

function to_dot(attrs::AttributeDict)
    if isempty(attrs)
        ""
    else
        string("[",join(map(to_dot,collect(attrs)),","),"]")
    end
end

to_dot(attr_tuple::(UTF8String, Any)) = "\"$(attr_tuple[1])\"=\"$(attr_tuple[2])\""

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
