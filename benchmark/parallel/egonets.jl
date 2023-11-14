using Graphs
using BenchmarkTools

SUITE["parallel"] = BenchmarkGroup([],
                                   "egonet" => BenchmarkGroup([])
                                   )

SUITE["serial"] = BenchmarkGroup([],
                                   "egonet" => BenchmarkGroup([])
                                   )

function vertex_function(g::Graph, i::Int)
    a = 0
    for u in neighbors(g, i)
        a += degree(g, u)
    end
    return a
end

function twohop(g::Graph, i::Int)
    a = 0
    for u in neighbors(g, i)
        for v in neighbors(g, u)
            a += degree(g, v)
        end
    end
    return a
end

function mapvertices(f, g::Graph)
    n = nv(g)
    a = zeros(Int, n)
    Threads.@threads for i in 1:n
        a[i] = f(g, i)
    end
    return a
end

function mapvertices_single(f, g)
    n = nv(g)
    a = zeros(Int, n)
    for i in 1:n
        a[i] = f(g, i)
    end
    return a
end

let
    nv_ = 10000
    g = SimpleGraph(nv_, 64 * nv_)

    SUITE["parallel"]["egonet"]["vertexfunction"] = @benchmarkable mapvertices($vertex_function, $g)
    SUITE["parallel"]["egonet"]["twohop"] = @benchmarkable mapvertices($twohop, $g)

    SUITE["serial"]["egonet"]["vertexfunction"] = @benchmarkable mapvertices_single($vertex_function, $g)
    SUITE["serial"]["egonet"]["twohop"] = @benchmarkable mapvertices_single($twohop, $g)
end
