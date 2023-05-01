using Graphs
using BenchmarkTools
@show Threads.nthreads()

@benchgroup "parallel" begin
    @benchgroup "egonet" begin
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

        function comparison(f, g)
            println("Mulithreaded on $(Threads.nthreads())")
            b1 = @benchmarkable mapvertices($f, $g)
            println(b1)

            println("singlethreaded")
            b2 = @benchmarkable mapvertices_single($f, $g)
            println(b2)
            return println("done")
        end

        nv_ = 10000
        g = SimpleGraph(nv_, 64 * nv_)
        f = vertex_function
        println(g)

        comparison(vertex_function, g)
        comparison(twohop, g)
    end
end
