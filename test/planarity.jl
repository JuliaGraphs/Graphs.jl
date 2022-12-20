@testset "Planarity tests" begin
    @testset "Aux functions tests" begin
        g = complete_graph(10)
        f = SimpleGraph()
        Graphs.add_vertices_from!(g, f)
        @test nv(g) == nv(f)
        Graphs.add_edges_from!(g, f)
        @test g == f
    end

    @testset "LRP constructor tests" begin
        function lrp_constructor_test(g)
            try
                lrp = Graphs.LRPlanarity(g)
                return true
            catch e
                return false
            end
        end
        g = SimpleGraph(10, 10)
        @test lrp_constructor_test(g)
        g = SimpleGraph{Int8}(10, 10)
        @test lrp_constructor_test(g)
    end

    @testset "DFS orientation tests" begin
        dfs_test_edges = [
            (1, 2),
            (1, 4),
            (1, 6),
            (2, 3),
            (2, 4),
            (2, 5),
            (3, 5),
            (3, 6),
            (4, 5),
            (4, 6),
            (5, 6),
        ]

        dfs_g = Graph(6)
        for edge in dfs_test_edges
            add_edge!(dfs_g, edge)
        end

        self = Graphs.LRPlanarity(dfs_g)
        #want to test dfs orientation 
        # make adjacency lists for dfs
        for v in 1:nv(self.G) #for all vertices in G,
            self.adjs[v] = neighbors(self.G, v) ##neighbourhood of v
        end
        T = eltype(self.G)

        # orientation of the graph by depth first search traversal
        for v in vertices(self.G)
            if self.height[v] == -one(T) #using -1 rather than nothing for type stability. 
                self.height[v] = zero(T)
                push!(self.roots, v)
                Graphs.dfs_orientation!(self, v)
            end
        end

        #correct data
        parent_edges = Dict([
            (1, Edge(0, 0)),
            (2, Edge(1, 2)),
            (3, Edge(2, 3)),
            (4, Edge(5, 4)),
            (5, Edge(3, 5)),
            (6, Edge(4, 6)),
        ])

        @test parent_edges == self.parent_edge

        correct_heights = Dict([(1, 0), (2, 1), (3, 2), (4, 4), (5, 3), (6, 5)])

        @test correct_heights == self.height
    end

    @testset "Planarity results" begin
        #Construct example planar graph
        planar_edges = [
            (1, 2), (1, 3), (2, 4), (2, 7), (3, 4), (3, 5), (4, 6), (4, 7), (5, 6)
        ]

        g = Graph(7)

        for edge in planar_edges
            add_edge!(g, edge)
        end

        @test is_planar(g) == true

        #another planar graph 
        cl = circular_ladder_graph(8)
        @test is_planar(cl) == true

        # one more planar graph 
        w = wheel_graph(10)
        @test is_planar(w) == true

        #Construct some non-planar graphs
        g = complete_graph(10)
        @test is_planar(g) == false

        petersen = smallgraph(:petersen)
        @test is_planar(petersen) == false

        d = smallgraph(:desargues)
        @test is_planar(d) == false

        h = smallgraph(:heawood)
        @test is_planar(h) == false

        mb = smallgraph(:moebiuskantor)
        @test is_planar(mb) == false

        #Directed, planar example
        dg = SimpleDiGraphFromIterator([Edge(1, 2), Edge(2, 3), Edge(3, 1)])

        @test is_planar(dg) == true
    end
end
