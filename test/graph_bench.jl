# compare performance of graph traversal

using Graphs

# construct graphs

nv = 10000
deg = 100

g_adj = simple_adjlist(nv)
g_inc = simple_inclist(nv)


shuff = [1:nv]

for u = 1 : nv                
    for j in 1 :  deg
        
        v = u
        
        while v == u
            k = rand(j+1:nv)
            shuff[j], shuff[k] = shuff[k], shuff[j]
            v = shuff[j]
        end        
        add_edge!(g_adj, u, v)
        add_edge!(g_inc, u, v)
    end
end

eweights = rand(num_edges(g_inc))

# test tasks

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

function bf_traverse(g::AbstractGraph)
    traverse_graph(g, BreadthFirst(), 1, TrivialGraphVisitor())
end

function df_traverse(g::AbstractGraph)
    traverse_graph(g, DepthFirst(), 1, TrivialGraphVisitor())
end

function run_dijkstra(g::AbstractGraph)
    dijkstra_shortest_paths(g, eweights, 1)
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
@graph_bench neighbor_scan SimpleAdjacencyList g_adj 50
@graph_bench neighbor_scan SimpleIncidenceList g_inc 50

println("Benchmark of out-edge scan")
@graph_bench outedge_scan SimpleIncidenceList g_inc 50

println("Benchmark of breadth-first traversal")
@graph_bench bf_traverse SimpleAdjacencyList g_adj 10
@graph_bench bf_traverse SimpleIncidenceList g_inc 10

println("Benchmark of depth-first traversal")
@graph_bench df_traverse SimpleAdjacencyList g_adj 5
@graph_bench df_traverse SimpleIncidenceList g_inc 2

println("Benchmark of Dijkstra shortest paths")
@graph_bench run_dijkstra SimpleIncidenceList g_inc 1

