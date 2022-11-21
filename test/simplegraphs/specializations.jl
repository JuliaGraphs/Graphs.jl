
@testset "squash" begin
    @testset "$g_in, kwargs=$kwargs" for kwargs in
                                         [(), (alwayscopy=false,), (alwayscopy=true,)],
        (g_in, g_expected) in [
            (SimpleGraph{Int64}(), SimpleGraph{Int8}()),
            (
                SimpleDiGraph{UInt8}(),
                if kwargs == (alwayscopy=false,)
                    SimpleDiGraph{UInt8}()
                else
                    SimpleDiGraph{Int8}()
                end,
            ),
            (path_graph(Int16(126)), path_graph(Int8(126))),
            (path_digraph(Int16(127)), path_digraph(UInt8(127))),
            (path_graph(Int16(254)), path_graph(UInt8(254))),
            (path_digraph(Int16(255)), path_digraph(Int16(255))),
            (
                path_graph(UInt16(255)),
                if kwargs == (alwayscopy=false,)
                    path_graph(UInt16(255))
                else
                    path_graph(Int16(255))
                end,
            ),
            (star_graph(Int16(32766)), star_graph(Int16(32766))),
            (star_digraph(Int32(32767)), star_digraph(UInt16(32767))),
            (cycle_graph(Int128(123)), cycle_graph(Int8(123))),
        ]

        g_actual = squash(g_in; kwargs...)
        @test typeof(g_actual) === typeof(g_expected)
        @test g_actual == g_expected
        if kwargs == (alwayscopy=false,) && typeof(g_in) === typeof(g_actual)
            @test g_in === g_actual
        end
    end
end
