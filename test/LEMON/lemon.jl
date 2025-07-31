using Graphs.LEMON

@testset "LEMON" begin
    @testset "Graph Construction" begin
        g = LEMONGraph()
        @test nv(g) == 0
        @test ne(g) == 0
        @test !is_directed(g)
        
        g2 = LEMONGraph(5)
        @test nv(g2) == 5
        @test ne(g2) == 0
        
        @test_throws DomainError LEMONGraph(-1)
    end
    
    @testset "DiGraph Construction" begin
        g = LEMONDiGraph()
        @test nv(g) == 0
        @test ne(g) == 0
        @test is_directed(g)
        
        g2 = LEMONDiGraph(5)
        @test nv(g2) == 5
        @test ne(g2) == 0
        
        @test_throws DomainError LEMONDiGraph(-1)
    end
    
    @testset "Basic Properties" begin
        g = LEMONGraph(10)
        @test vertices(g) == 1:10
        @test eltype(g) == Int
        
        dg = LEMONDiGraph(10)
        @test vertices(dg) == 1:10
        @test eltype(dg) == Int
    end
end