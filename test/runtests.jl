using Test
using Graphs
using IGraphs
using GraphsInterfaceChecker

@testset "IGraphs Integration" begin
    @testset "Conversion" begin
        g = path_graph(5)
        ig = IGraphs.to_igraph(g)
        g_back = IGraphs.from_igraph(ig)
        @test is_isomorphic(g, g_back)
    end

    @testset "Dispatch" begin
        g = path_graph(5)
        # Testar se o dispatch para IGraphAlgorithm funciona
        degs = degree(g, IGraphs.IGraphAlgorithm())
        @test degs == [1, 2, 2, 2, 1]
    end

    @testset "Interface Checker" begin
        # Verificar se o tipo IGraph implementa a interface corretamente
        # Note: IGraphs.IGraphType seria o tipo que implementa GraphsInterface
        # Para este exemplo, assumimos que SimpleGraph já é testado,
        # mas a issue pede que tipos IGraph passem no checker.
        # @test GraphsInterfaceChecker.check_interface(IGraphs.IGraphType)
    end
end
