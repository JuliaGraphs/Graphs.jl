# compare performance of graph traversal

using Graphs

# construct graphs

nv = 5000
deg = 100

g_adj = AdjacencyList(nv)
for i = 1 : nv
    js = rand(1:nv, deg)
    for j in js
        add_edge!(g_adj, i, j)
    end
end

g_inc = directed_incidence_list(Edge{Int}, nv)
for i = 1 : nv
    js = rand(1:nv, deg)
    for j in js
        add_edge!(g_inc, Edge(i, j))
    end
end

# test the performance of scanning all neighbors

function neighbor_scan(g::AbstractGraph)
    for v in vertices(g)
        for u in out_neighbors(v, g)
            u
        end
    end
end

function outedge_scan(g::AbstractGraph)
    for v in vertices(g)
        for u in out_edges(v, g)
            e
        end
    end
end

# generic benchmark macro

macro graph_bench(fun, g, repeats)
    quote
        $(fun)($g)  # warming
        et = @elapsed for i = 1 : $repeats
            $(fun)($g)
        end
        @printf("    On %-25s: elapsed = %.4fs\n", string(typeof($g)), et)
    end
end


# benchmarks

println("Benchmark of neighbor scan")
@graph_bench neighbor_scan g_adj 10
@graph_bench neighbor_scan g_inc 10

println("Benchmark of out-edge scan")
@graph_bench outedge_scan g_inc 10



