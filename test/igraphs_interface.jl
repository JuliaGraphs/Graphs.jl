using Graphs
using IGraphs
using Test

@testset "IGraphs Interface Compliance" begin
    # Test with undirected graph
    @testset "Undirected Graph" begin
        g_orig = path_graph(5)
        ig = igraph(g_orig)
        
        @testset "Basic Properties" begin
            @test nv(ig) == nv(g_orig)
            @test ne(ig) == ne(g_orig)
            @test is_directed(ig) == false
        end
        
        @testset "Vertices and Edges" begin
            @test collect(vertices(ig)) == collect(vertices(g_orig))
            ig_edges = edges(ig)
            @test length(ig_edges) == ne(ig)
            
            if ne(ig) > 0
                e = first(ig_edges)
                @test has_edge(ig, src(e), dst(e))
            end
        end
        
        @testset "Neighbors" begin
            for v in vertices(ig)
                @test sort(outneighbors(ig, v)) == sort(outneighbors(g_orig, v))
                @test sort(inneighbors(ig, v)) == sort(inneighbors(g_orig, v))
            end
        end
    end

    # Test with directed graph
    @testset "Directed Graph" begin
        g_orig = path_digraph(5)
        ig = igraph(g_orig)
        
        @testset "Basic Properties" begin
            @test nv(ig) == nv(g_orig)
            @test ne(ig) == ne(g_orig)
            @test is_directed(ig) == true
        end
        
        @testset "Vertices and Edges" begin
            @test collect(vertices(ig)) == collect(vertices(g_orig))
            ig_edges = edges(ig)
            @test length(ig_edges) == ne(ig)
        end
        
        @testset "Neighbors" begin
            for v in vertices(ig)
                @test sort(outneighbors(ig, v)) == sort(outneighbors(g_orig, v))
                @test sort(inneighbors(ig, v)) == sort(inneighbors(g_orig, v))
            end
        end
    end
end
