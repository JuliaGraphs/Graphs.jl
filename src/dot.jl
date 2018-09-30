# Functions for representing graphs in GraphViz's dot format
# http://www.graphviz.org/
# http://www.graphviz.org/Documentation/dotguide.pdf
# http://www.graphviz.org/pub/scm/graphviz2/doc/info/lang.html

# Write the dot representation of a graph to a file by name.
function to_dot(graph::AbstractGraph, filename::AbstractString, attrs::AttributeDict=AttributeDict())
    open(filename,"w") do f
        to_dot(graph, f, attrs)
    end
end

# Get the dot representation of a graph as a string.
function to_dot(graph::AbstractGraph, attrs::AttributeDict=AttributeDict())
    str = IOBuffer()
    to_dot(graph, str, attrs)
    String(take!(str)) #takebuf_string(str)
end

# Write the dot representation of a graph to a stream.
function to_dot(graph::G, stream::IO,attrs::AttributeDict=AttributeDict()) where {G<:AbstractGraph}
    has_vertex_attrs = hasmethod(attributes, (vertex_type(graph), G))
    has_edge_attrs = hasmethod(attributes, (edge_type(graph), G))

    write(stream, "$(graph_type_string(graph)) graphname {\n")
    write(stream, "$(to_dot_graph(attrs))")
    if implements_edge_list(graph) && implements_vertex_map(graph)
        for vtx in  vertices(graph)
            attrs = has_vertex_attrs ?  "\t$(to_dot(attributes(vtx,graph)))" : ""
            write(stream,"$(vertex_index(vtx,graph))$attrs\n")
        end
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
#write node attributes example: [shape=box, style=filled]
function to_dot(attrs::AttributeDict)
    if isempty(attrs)
        ""
    else
        string("[",join(map(a -> to_dot(a[1], a[2]), collect(attrs)),","),"]")
    end
end
# write a graph wide attributes example: size = "4,4";
function to_dot_graph(attrs::AttributeDict)
    if isempty(attrs)
        ""
    else
        string(join(map(a -> to_dot(a[1], a[2]), collect(attrs)),";\n"),";\n")
    end
end

to_dot(attr::AbstractString, value) = "\"$attr\"=\"$value\""

to_dot(attr_tuple::Tuple{String, Any}) = "\"$(attr_tuple[1])\"=\"$(attr_tuple[2])\""

function graph_type_string(graph::AbstractGraph)
    is_directed(graph) ? "digraph" : "graph"
end

function edge_op(graph::AbstractGraph)
    is_directed(graph) ? "->" : "--"
end

function plot(g::AbstractGraph;gviz_args="")
    if !isequal(gviz_args,"")
        # Provide the command line code for GraphViz directly
        cla_list = split(gviz_args)
        arg = `$cla_list`
    else
        # Default uses x11 window
        arg = `neato -Tx11`
    end
    stdin, proc = open(arg, "w")
    to_dot(g, stdin)
    close(stdin)
end
