@testset "graph properties" begin
    undirected_graph = ladder_graph(5)
    directed_graph = wheel_digraph(5)
    @testset "properties without parameter" begin
        properties_both = (GraphProperties.NumberOfVertices,)
        properties_undirected_only = (
            GraphProperties.DegreeSequence,
            GraphProperties.NumberOfEdges,
            GraphProperties.NumberOfConnectedComponents,
        )
        properties_directed_only = (
            GraphProperties.NumberOfArcs,
            GraphProperties.NumberOfWeaklyConnectedComponents,
            GraphProperties.NumberOfStronglyConnectedComponents,
        )
        properties = (
            properties_both..., properties_undirected_only..., properties_directed_only...
        )
        for options in ((), (nothing,))
            for property in properties
                local graphs
                if property in properties_both
                    graphs = (undirected_graph, directed_graph)
                elseif property in properties_undirected_only
                    graphs = (undirected_graph,)
                elseif property in properties_directed_only
                    graphs = (directed_graph,)
                end
                invalid_inputs = setdiff((undirected_graph, directed_graph), graphs)
                for graph in graphs
                    @test ((@inferred graph_property(graph, property(), options...)); true)
                    @test something(graph_property(graph, property(), options...)) isa
                        graph_property_type(property())
                end
                for graph in invalid_inputs
                    @test_throws ArgumentError graph_property(graph, property(), options...)
                end
            end
        end
    end
end
