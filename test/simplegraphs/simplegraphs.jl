import Random

@testset "SimpleGraphs" begin
    rng = StableRNG(1)
    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    # specific concrete generators - no need for loop
    @test @inferred(eltype(SimpleGraph())) == Int
    @test @inferred(eltype(SimpleGraph(adjmx1))) == Int
    @test_throws ArgumentError SimpleGraph(adjmx2)

    @test_throws Graphs.NotImplementedError badj(DummySimpleGraph())

    @test @inferred(ne(SimpleGraph(path_digraph(5)))) == 4
    @test @inferred(!is_directed(SimpleGraph))
    @test @inferred(!is_directed(SimpleGraph{Int}))

    @test @inferred(eltype(SimpleDiGraph())) == Int
    @test @inferred(eltype(SimpleDiGraph(adjmx2))) == Int
    @test @inferred(ne(SimpleDiGraph(path_graph(5)))) == 8
    @test @inferred(is_directed(SimpleDiGraph))
    @test @inferred(is_directed(SimpleDiGraph{Int}))


    for gbig in [SimpleGraph(0xff), SimpleDiGraph(0xff)]
        @test @inferred(!add_vertex!(gbig))    # overflow
        @test @inferred(add_vertices!(gbig, 10) == 0)
    end

    gdx = path_digraph(4)
    gx = SimpleGraph()
    for g in testgraphs(gx)
        T = eltype(g)
        @test repr("text/plain", g) == "{0, 0} undirected simple $T graph"
        @test @inferred(add_vertices!(g, 5) == 5)
        @test repr("text/plain", g) == "{5, 0} undirected simple $T graph"
        @test eval(Meta.parse(repr(g))) == g
    end
    gx = SimpleDiGraph()
    for g in testdigraphs(gx)
        T = eltype(g)
        @test repr("text/plain", g) == "{0, 0} directed simple $T graph"
        @test @inferred(add_vertices!(g, 5) == 5)
        @test repr("text/plain", g) == "{5, 0} directed simple $T graph"
        @test eval(Meta.parse(repr(g))) == g
    end

    gx = path_graph(4)
    for g in testgraphs(gx)
        @test @inferred(vertices(g)) == 1:4
        @test Edge(2, 3) in edges(g)
        @test @inferred(nv(g)) == 4
        @test @inferred(fadj(g)) == badj(g) == adj(g) == g.fadjlist
        @test @inferred(fadj(g, 2)) == badj(g, 2) == adj(g, 2) == g.fadjlist[2]

        @test @inferred(has_edge(g, 2, 3))
        @test @inferred(!has_edge(g, 20, 3))
        @test @inferred(!has_edge(g, 2, 30))
        @test @inferred(has_edge(g, 3, 2))

        gc = copy(g)
        @test @inferred(add_edge!(gc, 4 => 1)) && gc == cycle_graph(4)
        @test @inferred(has_edge(gc, 4 => 1)) && has_edge(gc, 0x04 => 0x01)
        gc = copy(g)
        @test @inferred(add_edge!(gc, (4, 1))) && gc == cycle_graph(4)
        @test @inferred(has_edge(gc, (4, 1))) && has_edge(gc, (0x04, 0x01))
        gc = copy(g)
        @test add_edge!(gc, 4, 1) && gc == cycle_graph(4)

        @test @inferred(inneighbors(g, 2)) == @inferred(outneighbors(g, 2)) == @inferred(neighbors(g, 2)) == [1, 3]
        @test @inferred(add_vertex!(gc))   # out of order, but we want it for issubset
        @test @inferred(g ⊆ gc)
        @test @inferred(has_vertex(gc, 5))

        @test @inferred(ne(g)) == 3

        @test @inferred(rem_edge!(gc, 1, 2)) && @inferred(!has_edge(gc, 1, 2))
        ga = @inferred(copy(g))
        @test @inferred(rem_vertex!(ga, 2)) && ne(ga) == 1
        @test @inferred(!rem_vertex!(ga, 10))

        @test @inferred(zero(g)) == SimpleGraph{eltype(g)}()

        # concrete tests below

        @test @inferred(eltype(g)) == eltype(fadj(g, 1)) == eltype(nv(g))
        T = @inferred(eltype(g))
        @test @inferred(nv(SimpleGraph{T}(6))) == 6

        @test @inferred(eltype(SimpleGraph(T))) == T
        @test @inferred(eltype(SimpleGraph{T}(adjmx1))) == T

        ga = SimpleGraph(10)
        @test @inferred(eltype(SimpleGraph{T}(ga))) == T

        for gd in testdigraphs(gdx)
            U = eltype(gd)
            @test @inferred(eltype(SimpleGraph(gd))) == U
        end

        @test @inferred(edgetype(g)) == SimpleGraphEdge{T}
        @test @inferred(copy(g)) == g
        @test @inferred(!is_directed(g))

        e = first(edges(g))
        @test @inferred(has_edge(g, e))
    end

    gdx = path_digraph(4)
    for g in testdigraphs(gdx)
        @test @inferred(vertices(g)) == 1:4
        @test Edge(2, 3) in edges(g)
        @test !(Edge(3, 2) in edges(g))
        @test @inferred(nv(g)) == 4
        @test @inferred(fadj(g)[2]) == fadj(g, 2) == [3]
        @test @inferred(badj(g)[2]) == badj(g, 2) == [1]
        @test_throws MethodError adj(g)

        @test @inferred(has_edge(g, 2, 3))
        @test @inferred(!has_edge(g, 3, 2))
        @test @inferred(!has_edge(g, 20, 3))
        @test @inferred(!has_edge(g, 2, 30))

        gc = copy(g)
        @test @inferred(add_edge!(gc, 4 => 1)) && gc == cycle_digraph(4)
        @test @inferred(has_edge(gc, 4 => 1)) && has_edge(gc, 0x04 => 0x01)
        gc = copy(g)
        @test @inferred(add_edge!(gc, (4, 1))) && gc == cycle_digraph(4)
        @test @inferred(has_edge(gc, (4, 1))) && has_edge(gc, (0x04, 0x01))
        gc = @inferred(copy(g))
        @test @inferred(add_edge!(gc, 4, 1)) && gc == cycle_digraph(4)

        @test @inferred(inneighbors(g, 2)) == [1]
        @test @inferred(outneighbors(g, 2)) == @inferred(neighbors(g, 2)) == [3]
        @test @inferred Set(all_neighbors(g, 2)) == Set(union(inneighbors(g, 2), outneighbors(g, 2)))
        @test @inferred(add_vertex!(gc))   # out of order, but we want it for issubset
        @test @inferred(g ⊆ gc)
        @test @inferred(has_vertex(gc, 5))

        @test @inferred(ne(g)) == 3

        @test @inferred(!rem_edge!(gc, 2, 1))
        @test @inferred(rem_edge!(gc, 1, 2)) && @inferred(!has_edge(gc, 1, 2))
        ga = @inferred(copy(g))
        @test @inferred(rem_vertex!(ga, 2)) && ne(ga) == 1
        @test @inferred(!rem_vertex!(ga, 10))

        @test @inferred(zero(g)) == SimpleDiGraph{eltype(g)}()

        # concrete tests below

        @test @inferred(eltype(g)) == eltype(@inferred(fadj(g, 1))) == eltype(nv(g))
        T = @inferred(eltype(g))
        @test @inferred(nv(SimpleDiGraph{T}(6))) == 6

        @test @inferred(eltype(SimpleDiGraph(T))) == T
        @test @inferred(eltype(SimpleDiGraph{T}(adjmx2))) == T

        ga = SimpleDiGraph(10)
        @test @inferred(eltype(SimpleDiGraph{T}(ga))) == T

        for gu in testgraphs(gx)
            U = @inferred(eltype(gu))
            @test @inferred(eltype(SimpleDiGraph(gu))) == U
        end

        @test @inferred(edgetype(g)) == SimpleDiGraphEdge{T}
        @test @inferred(copy(g)) == g
        @test @inferred(is_directed(g))

        e = first(@inferred(edges(g)))
        @test @inferred(has_edge(g, e))
    end

    gx = complete_graph(4)
    for g in testgraphs(gx)
        h = Graph(g)
        @test g == h
        @test rem_vertex!(g, 2)
        @test nv(g) == 3 && ne(g) == 3
        @test g != h
    end


    gdx = complete_digraph(4)
    for g in testdigraphs(gdx)
        h = DiGraph(g)
        @test g == h
        @test rem_vertex!(g, 2)
        @test nv(g) == 3 && ne(g) == 6
        @test g != h
    end
    # tests for #820
    g = complete_graph(3)
    add_edge!(g, 3, 3)
    rem_vertex!(g, 1)
    @test nv(g) == 2 && ne(g) == 2 && has_edge(g, 1, 1)

    g = path_digraph(3)
    add_edge!(g, 3, 3)
    rem_vertex!(g, 1)
    @test nv(g) == 2 && ne(g) == 2 && has_edge(g, 1, 1)

    @testset "Cannot create graphs for noncrete integer type $T" for T in [Signed, Integer]

        @test_throws DomainError SimpleGraph{T}()
        @test_throws DomainError SimpleGraph{T}(one(T))

        @test_throws DomainError SimpleDiGraph{T}()
        @test_throws DomainError SimpleDiGraph{T}(one(T))
    end

    # Tests for constructors from iterators of edges
    @testset "Constructors from edge lists" begin
        g_undir = erdos_renyi(200, 100; rng=StableRNG(0))
        add_edge!(g_undir, 200, 1) # ensure that the result uses all vertices
        add_edge!(g_undir, 2, 2) # add a self-loop

        @testset "SimpleGraphFromIterator for edgetype $(edgetype(g))" for g in testgraphs(g_undir)

            # We create an edge list, shuffle it and reverse half of its edges
            # using this edge list should result in the same graph
            edge_list = [e for e in edges(g)]
            shuffle!(rng, edge_list)
            for i in rand(rng, 1:length(edge_list), length(edge_list) ÷ 2)
                e = edge_list[i]
                Te = typeof(e)
                edge_list[i] = Te(dst(e), src(e))
            end

            edge_iter = (e for e in edge_list)
            edge_set = Set(edge_list)
            edge_set_any = Set{Any}(edge_list)

            g1 = @inferred SimpleGraph(edge_list)
            # we can't infer the return type of SimpleGraphFromIterator at the moment 
            g2 = SimpleGraphFromIterator(edge_list)
            g3 = SimpleGraphFromIterator(edge_iter)
            g4 = SimpleGraphFromIterator(edge_set)
            g5 = SimpleGraphFromIterator(edge_set_any)

            @test g == g1
            @test g == g2
            @test g == g3
            @test g == g4
            @test g == g5
            @test edgetype(g) == edgetype(g1)
            @test edgetype(g) == edgetype(g2)
            @test edgetype(g) == edgetype(g3)
            @test edgetype(g) == edgetype(g4)
            @test edgetype(g) == edgetype(g5)
        end

        g_dir = erdos_renyi(200, 100; is_directed=true, rng=StableRNG(0))
        add_edge!(g_dir, 200, 1)
        add_edge!(g_dir, 2, 2)

        @testset "SimpleGraphFromIterator for edgetype $(edgetype(g))" for g in testdigraphs(g_dir)
            # We create an edge list and shuffle it
            edge_list = [e for e in edges(g)]
            shuffle!(rng, edge_list)
            
            edge_iter = (e for e in edge_list)
            edge_set = Set(edge_list)
            edge_set_any = Set{Any}(edge_list)

            g1 = @inferred SimpleDiGraph(edge_list)
            # we can't infer the return type of SimpleDiGraphFromIterator at the moment 
            g2 = SimpleDiGraphFromIterator(edge_list)
            g3 = SimpleDiGraphFromIterator(edge_iter)
            g4 = SimpleDiGraphFromIterator(edge_set)
            g5 = SimpleDiGraphFromIterator(edge_set_any)

            @test g == g1
            @test g == g2
            @test g == g3
            @test g == g4
            @test g == g5
            @test edgetype(g) == edgetype(g1)
            @test edgetype(g) == edgetype(g2)
            @test edgetype(g) == edgetype(g3)
            @test edgetype(g) == edgetype(g4)
            @test edgetype(g) == edgetype(g5)
        end

        # SimpleGraphFromIterator of an empty iterator should result
        # in an empty graph of default edgetype
        empty_iter = (x for x in [])
        @testset "SimpleGraphFromIterator for empty iterator" begin
            @test SimpleGraphFromIterator(empty_iter) == SimpleGraph(0)
            @test edgetype(SimpleGraphFromIterator(empty_iter)) == edgetype(SimpleGraph(0))
        end
        @testset "SimpleGraphDiFromIterator for empty iterator" begin
            @test SimpleDiGraphFromIterator(empty_iter) == SimpleDiGraph(0)
            @test edgetype(SimpleDiGraphFromIterator(empty_iter)) == edgetype(SimpleDiGraph(0))
        end

        @testset "SimpleGraphFromIterator for wrong edge types" begin
            @test_throws DomainError SimpleGraphFromIterator( (i for i in 1:2) )
        end

        @testset "SimpleDiGraphFromIterator for wrong edge types" begin
            @test_throws DomainError SimpleDiGraphFromIterator( (SimpleDiGraphEdge(1,2), "a string") )
        end

        # check if multiple edges && multiple self-loops result in the 
        # correct number of edges & vertices
        # edges using integers < 1 should be ignored
        g_undir = SimpleGraph(0)
        @testset "SimpleGraphFromIterator with self-loops and multiple edges, edgetype $(edgetype(g))" for g in testgraphs(SimpleGraph(0))

            E = edgetype(g)
            edge_list = E.([(4, 4),(1, 2),(4, 4),(1, 2),(4, 4),(2, 1),(0, 1),(1, 0),(0, 0)])
            edge_iter = (e for e in edge_list)
            edge_set = Set(edge_list)
            edge_set_any = Set{Any}(edge_list)

            g1 = @inferred SimpleGraph(edge_list)
            g2 = SimpleGraphFromIterator(edge_list)
            g3 = SimpleGraphFromIterator(edge_iter)
            g4 = SimpleGraphFromIterator(edge_set)
            g5 = SimpleGraphFromIterator(edge_set_any)

            @test nv(g1) == 4
            @test nv(g2) == 4
            @test nv(g3) == 4
            @test nv(g4) == 4
            @test nv(g5) == 4
 
            @test ne(g1) == 2
            @test ne(g2) == 2
            @test ne(g3) == 2
            @test ne(g4) == 2
            @test ne(g5) == 2
        end

        @testset "SimpleDiGraphFromIterator with self-loops and multiple edges, edgetype $(edgetype(g))" for g in testdigraphs(SimpleDiGraph(0))

            E = edgetype(g)
            edge_list = E.([(4, 4),(1, 2),(4, 4),(1, 2),(4, 4),(2, 1),(0, 1),(1, 0),(0, 0)])
            edge_iter = (e for e in edge_list)
            edge_set = Set(edge_list)
            edge_set_any = Set{Any}(edge_list)

            g1 = @inferred SimpleDiGraph(edge_list)
            g2 = SimpleDiGraphFromIterator(edge_list)
            g3 = SimpleDiGraphFromIterator(edge_iter)
            g4 = SimpleDiGraphFromIterator(edge_set)
            g5 = SimpleDiGraphFromIterator(edge_set_any)

            @test nv(g1) == 4
            @test nv(g2) == 4
            @test nv(g3) == 4
            @test nv(g4) == 4
            @test nv(g5) == 4
 
            @test ne(g1) == 3
            @test ne(g2) == 3
            @test ne(g3) == 3
            @test ne(g4) == 3
            @test ne(g5) == 3
        end

        # test for iterators where the type of the elements can only be determined at runtime
        g_undir = SimpleGraph(0)
        @testset "SimpleGraphFromIterator with edgelist of eltype Any" for g in testgraphs(g_undir)
            T = edgetype(g)
            edge_list_good = Any[ T.(1, 2), T.(3, 4) ]
            edge_list_bad =  Any[ T.(1, 2), Int64(1) ]

            g1 = SimpleGraphFromIterator(edge_list_good)
            @test edgetype(g1) == T
            @test_throws DomainError SimpleGraphFromIterator(edge_list_bad)
        end
        g_dir = SimpleDiGraph(0)
        @testset "SimpleGraphDiFromIterator with edgelist of eltype Any" for g in testdigraphs(g_dir)
            T = edgetype(g)
            edge_list_good = Any[ T.(1, 2), T.(3, 4) ]
            edge_list_bad =  Any[ T.(1, 2), Int64(1) ]

            g1 = SimpleDiGraphFromIterator(edge_list_good)
            @test edgetype(g1) == T
            @test_throws DomainError SimpleDiGraphFromIterator(edge_list_bad)
        end


        @testset "SimpleGraphFromIterator with edgelist of eltype Any" begin
            # If there are edges of multiple types, the construction should fail
            edge_list_1 = Any[Edge{Int8}(1, 2), Edge{Int16}(3, 4)]
            edge_list_2 = Any[Edge{Int16}(1, 2), Edge{Int8}(3, 4)]
            @test_throws DomainError SimpleGraphFromIterator(edge_list_1)
            @test_throws DomainError SimpleGraphFromIterator(edge_list_2)
        end


        @testset "SimpleDiGraphFromIterator with edgelist of eltype Any" begin
            edge_list_1 = Any[Edge{Int8}(1, 2), Edge{Int16}(3, 4)]
            edge_list_2 = Any[Edge{Int16}(1, 2), Edge{Int8}(3, 4)]
            @test_throws DomainError SimpleDiGraphFromIterator(edge_list_1)
            @test_throws DomainError SimpleDiGraphFromIterator(edge_list_2)
        end
    end

    # test for rem_vertices!
    let
        g_undir = complete_graph(5)
        g_dir = complete_digraph(5)
        for g in (testgraphs(g_undir) ∪ testdigraphs(g_dir))
            T = eltype(g)

            g5 = copy(g)
            vmap = @inferred rem_vertices!(g5, T[], keep_order=true)
            @test g5 == g
            @test vmap == 1:5
            @test isvalid_simplegraph(g5)

            g4 = copy(g)
            vmap = rem_vertices!(g4, T[3], keep_order=true)
            @test g4 == (is_directed(g) ? complete_digraph(T(4)) : complete_graph(T(4)))
            @test vmap == [1, 2, 4, 5]
            @test isvalid_simplegraph(g4)

            g4 = copy(g)
            add_edge!(g4, 1, 1) # some self_loops
            add_edge!(g4, 2, 2)
            vmap = rem_vertices!(g4, T[1, 1, 1], keep_order=false)
            @test ne(g4) == (is_directed(g) ? 13 : 7)
            @test sort(vmap) == [2, 3, 4, 5]
            @test isvalid_simplegraph(g4)

            g2 = copy(g)
            vmap = rem_vertices!(g2, T[2, 1, 4], keep_order=false)
            @test g2 == (is_directed(g) ? complete_digraph(T(2)) : complete_graph(T(2)))
            @test sort(vmap) == [3, 5]
            @test isvalid_simplegraph(g2)

            g0 = copy(g)
            vmap = rem_vertices!(g0, T[1, 3, 2, 3, 5, 4], keep_order=false)
            @test g0 == (is_directed(g) ? SimpleDiGraph(T(0)) : SimpleGraph(T(0)))
            @test isempty(vmap)
            @test isvalid_simplegraph(g0)
            vmap = rem_vertices!(g0, T[], keep_order=false)
            @test g0 == (is_directed(g) ? SimpleDiGraph(T(0)) : SimpleGraph(T(0)))
            @test isempty(vmap)
            @test isvalid_simplegraph(g0)

            g5 = copy(g)
            @test_throws ArgumentError rem_vertices!(g5, T[2, 6], keep_order=true)
            g5 = copy(g)
            @test_throws ArgumentError rem_vertices!(g5, T[3, 0], keep_order=false)
        end

        g_undir = erdos_renyi(10, 0.5, rng=rng)
        g_dir = erdos_renyi(10, 0.5, is_directed=true, rng=rng)
        for u = 1:2:10
            add_edge!(g_undir, u, u)
            add_edge!(g_dir, u, u)
        end
        a = Random.randsubseq(1:10, 0.5)
        for g in (testgraphs(g_undir) ∪ testdigraphs(g_dir))
            T = eltype(g)

            gt = copy(g)
            gf = copy(g)
            a_converted = convert(Vector{T}, a)
            vmap_t = rem_vertices!(gt, a_converted, keep_order=true)
            vmap_f = rem_vertices!(gf, a_converted, keep_order=false)
            @test issorted(vmap_t)
            @test allunique(vmap_t)
            @test allunique(vmap_f)
            @test sort(vmap_f) == vmap_t
            @test length(vmap_f) == nv(g) - length(a_converted)
            @test vmap_t == setdiff(collect(vertices(g)), a_converted)
            @test Graphs.Experimental.has_isomorph(gt, gf)
            gi = g[setdiff(collect(vertices(g)), a_converted)]
            @test Graphs.Experimental.has_isomorph(gf, gi)
            @test isvalid_simplegraph(gt)
            @test isvalid_simplegraph(gf)
        end
    end
    # codecov for has_edge(::AbstractSimpleGraph, x, y)
    @test @inferred has_edge(DummySimpleGraph(), 1, 2)
end
