# compare performance of graph traversal

using Graphs

# construct graphs

nv = 10000
deg = 100

g_adj = directed_adjacency_list(nv)
g_inc = directed_incidence_list(nv)

for i = 1 : nv
    js = rand(1:nv, deg)
    for j in js
        add_edge!(g_adj, i, j)
        add_edge!(g_inc, i, j)
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

macro graph_bench(fun, name, g, repeats)
    quote
        $(fun)($g)  # warming
        et = @elapsed for i = 1 : $repeats
            $(fun)($g)
        end
        @printf("    On %-25s: avg elapsed = %.4f ms\n", $(string(name)), 1000 * et / $repeats)
    end
end


# benchmarks

println("Benchmark on a graph with $(nv) vertices and $(nv * deg) edges")

println("Benchmark of neighbor scan")
@graph_bench neighbor_scan AdjacencyList g_adj 50
@graph_bench neighbor_scan IncidenceList g_inc 50

println("Benchmark of out-edge scan")
@graph_bench outedge_scan IncidenceList g_inc 50



