SUITE["core"] = BenchmarkGroup([],
                               "nv" => BenchmarkGroup([]), 
                               "edges" => BenchmarkGroup([]), 
                               "has_edge" => BenchmarkGroup([]), 
                               )

# nv
SUITE["core"]["nv"]["graphs"] = @benchmarkable [nv(g) for (_, g) in $GRAPHS]
SUITE["core"]["nv"]["digraphs"] = @benchmarkable [nv(g) for (_, g) in $DIGRAPHS]

# iterate edges
function iter_edges(g::AbstractGraph)
    i = 0
    for e in edges(g)
        i += 1
    end
    return i
end

SUITE["core"]["edges"]["graphs"] = @benchmarkable [iter_edges(g) for (_, g) in $GRAPHS]
SUITE["core"]["edges"]["digraphs"] = @benchmarkable [iter_edges(g) for (_, g) in $DIGRAPHS]

# has edge
function all_has_edge(g::AbstractGraph)
    nvg = nv(g)
    srcs = rand([1:nvg;], cld(nvg, 4))
    dsts = rand([1:nvg;], cld(nvg, 4))
    i = 0
    for (s, d) in zip(srcs, dsts)
        if has_edge(g, s, d)
            i += 1
        end
    end
    return i
end

SUITE["core"]["has_edge"]["graphs"] = @benchmarkable [all_has_edge(g) for (_, g) in $GRAPHS]
SUITE["core"]["has_edge"]["digraphs"] = @benchmarkable [all_has_edge(g) for (_, g) in $DIGRAPHS]
