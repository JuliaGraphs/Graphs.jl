function strip_quotes(s::String)
    replace(s, r"['\"]", "")
end

function read_edgelist(pathname::String)
    io = open(pathname, "r")
    lines = readlines(io)
    close(io)

    N = length(lines)
    edges = Array(UTF8String, N, 2)

    for i in 1:N
        line = lines[i]
        fields = split(chomp(line), r"[\s,]+")
        fields[1], fields[2] = strip_quotes(fields[1]), strip_quotes(fields[2])
        if length(fields) != 2
            error("Invalid edge in edgelist:\n $(line)")
        end
        edges[i, 1], edges[i, 2] = fields[1], fields[2]
    end

    return DirectedGraph(edges)
end

read_tgf(pathname::String) = error("Not yet implemented")
read_graphml(pathname::String) = error("Not yet implemented")
