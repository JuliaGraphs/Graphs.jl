string(v::Vertex) = "Vertex #$(v.id)"
function repl_show(io::IOStream, v::Vertex)
    print(io, string(v))
end
show(io::IOStream, v::Vertex) = repl_show(io, v)
print(io::IOStream, v::Vertex) = repl_show(io, v)

string(e::Edge) = "$(typeof(e)) :: $(e.out) => $(e.in)"
function repl_show(io::IOStream, e::Edge)
    print(io, string(e))
end
show(io::IOStream, e::Edge) = repl_show(io, e)
print(io::IOStream, e::Edge) = repl_show(io, e)

function string(g::Graph)
    o = ""
    o *= "$(typeof(g))\n"
    o *= " * Order: $(order(g))\n"
    o *= " * Size: $(size(g))"
    return o
end
function repl_show(io::IOStream, g::Graph)
    print(io, string(g))
end
show(io::IOStream, g::Graph) = repl_show(io, g)
print(io::IOStream, g::Graph) = repl_show(io, g)
