string(v::Vertex) = "#$(v.id)"
function repl_show(io::IOStream, v::Vertex)
    print(io, string(v))
end
show(io::IOStream, v::Vertex) = repl_show(io, v)
print(io::IOStream, v::Vertex) = repl_show(io, v)

string(e::UndirectedEdge) = "$(e.a) -- $(e.b)"
string(e::DirectedEdge) = "$(e.out) -> $(e.in)"
function repl_show(io::IOStream, e::Edge)
    print(io, string(e))
end
show(io::IOStream, e::Edge) = repl_show(io, e)
print(io::IOStream, e::Edge) = repl_show(io, e)

function string(g::AbstractGraph)
    o = ""
    o *= "$(typeof(g))\n"
    o *= " * Order: $(order(g))\n"
    o *= " * Size: $(size(g))\n\n"
    o *= "Edges:\n"
    i = 0
    max_i = min(10, size(g))
    total_i = size(g)
    for edge in edges(g)
        i += 1
        if i > max_i
            o *= "..."
            break
        end
        if i == total_i
            o *= string(edge)
        else
            o *= string(string(edge), "\n")
        end
    end
    return o
end
function repl_show(io::IOStream, g::AbstractGraph)
    print(io, string(g))
end
show(io::IOStream, g::AbstractGraph) = repl_show(io, g)
print(io::IOStream, g::AbstractGraph) = repl_show(io, g)
