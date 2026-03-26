using Graphs
using IGraphs
using Test

@testset "IGraphs Interface Compliance" begin
    # Test with both directed and undirected graphs
    for g_orig in [path_graph(5), path_digraph(5)]
        ig = igraph(g_orig)
        
        @testset "Basic Properties ($(is_directed(g_orig) ? "Directed" : "Undirected"))" begin
            @test nv(ig) == nv(g_orig)
            @test ne(ig) == ne(g_orig)
            @test is_directed(ig) == is_directed(g_orig)
            @test eltype(ig) == eltype(g_orig)
            @test edgetype(ig) == edgetype(g_orig)
        end
        
        @testset "Vertices and Edges" begin
            @test collect(vertices(ig)) == collect(vertices(g_orig))
            @test length(collect(edges(ig))) == ne(ig)
            
            if ne(ig) > 0
                e = first(edges(ig))
                @test has_edge(ig, src(e), dst(e))
            end
        end
        
        @testset "Neighbors" begin
            for v in vertices(ig)
                @test sort(neighbors(ig, v)) == sort(neighbors(g_orig, v))
                @test sort(inneighbors(ig, v)) == sort(inneighbors(g_orig, v))
                @test sort(outneighbors(ig, v)) == sort(outneighbors(g_orig, v))
            end
        end
        
        @testset "Connectivity / Algorithms (Interface Support)" begin
            # If the interface is correctly implemented, these should work
            @test length(connected_components(SimpleGraph(ig))) == length(connected_components(g_orig))
            # Note: connected_components might not work directly if it expects SimpleGraph
            # But functions that take AbstractGraph should work.
            @test gdistances(ig, 1) == gdistances(g_orig, 1)
        end
    end
end
