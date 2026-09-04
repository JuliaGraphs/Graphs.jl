@testset "SimpleEdgeIter" begin
    rng = StableRNG(1)

    ga = @inferred(SimpleGraph(10, 20; rng=StableRNG(1)))
    gb = @inferred(SimpleGraph(10, 20; rng=StableRNG(1)))
    dga = @inferred(SimpleDiGraph(10, 20; rng=StableRNG(1)))
    dgb = @inferred(SimpleDiGraph(10, 20; rng=StableRNG(1)))
    @testset "string representation" begin
        @test sprint(show, edges(ga)) == "SimpleEdgeIter 20"
    end

    @test length(collect(edges(Graph(0, 0; rng=rng)))) == 0

    @testset "collection operations" begin
        @test @inferred(edges(ga)) == edges(gb)
        @test @inferred(edges(ga)) == collect(Edge, edges(gb))
        @test edges(ga) != collect(Edge, Base.Iterators.take(edges(gb), 5))
        @test collect(Edge, edges(gb)) == edges(ga)
        @test Set{Edge}(collect(Edge, edges(gb))) == edges(ga)
        @test @inferred(edges(ga)) == Set{Edge}(collect(Edge, edges(gb)))

        @test @inferred(edges(dga)) == edges(dgb)
        @test @inferred(edges(dga)) == collect(SimpleEdge, edges(dgb))
        @test edges(dga) != collect(Edge, Base.Iterators.take(edges(dgb), 5))
        @test collect(SimpleEdge, edges(dgb)) == edges(dga)
        @test Set{Edge}(collect(SimpleEdge, edges(dgb))) == edges(dga)
        @test @inferred(edges(dga)) == Set{SimpleEdge}(collect(SimpleEdge, edges(dgb)))
    end
    @testset "eltype" begin
        @test @inferred(eltype(edges(ga))) == eltype(typeof(edges(ga))) == edgetype(ga)
        @test eltype(collect(edges(ga))) == edgetype(ga)
        @test eltype(collect(edges(dga))) == edgetype(dga)
        #
        # codecov for eltype(::Type{SimpleEdgeIter{SimpleDiGraph{T}}}) where {T} = SimpleDiGraphEdge{T}
        gd = SimpleDiGraph{UInt8}(10, 20; rng=rng)
        @test @inferred(eltype(edges(gd))) ==
            eltype(typeof(edges(gd))) ==
            edgetype(gd) ==
            SimpleDiGraphEdge{UInt8}
    end

    ga = SimpleGraph(10)
    add_edge!(ga, 3, 2)
    add_edge!(ga, 3, 10)
    add_edge!(ga, 5, 10)
    add_edge!(ga, 10, 3)

    dga = SimpleDiGraph(10)
    add_edge!(dga, 3, 2)
    add_edge!(dga, 3, 10)
    add_edge!(dga, 5, 10)
    add_edge!(dga, 10, 3)

    e1 = Edge(3, 10)
    e2 = (3, 10)
    @testset "membership operations" begin
        @test e1 ∈ edges(ga)
        @test e2 ∈ edges(ga)
        @test (3, 9) ∉ edges(ga)

        for u in 1:12, v in 1:12
            b = has_edge(ga, u, v)
            @test b == @inferred (u, v) ∈ edges(ga)
            @test b == @inferred (u => v) ∈ edges(ga)
            @test b == @inferred Edge(u, v) ∈ edges(ga)

            db = has_edge(dga, u, v)
            @test db == @inferred (u, v) ∈ edges(dga)
            @test db == @inferred (u => v) ∈ edges(dga)
            @test db == @inferred Edge(u, v) ∈ edges(dga)
        end
    end

    @testset "iterator protocol" begin
        eit = edges(ga)
        # @inferred not valid for new interface anymore (return type is a Union)
        @test collect(eit) == [Edge(2, 3), Edge(3, 10), Edge(5, 10)]

        eit = @inferred(edges(dga))
        @test collect(eit) ==
            [SimpleEdge(3, 2), SimpleEdge(3, 10), SimpleEdge(5, 10), SimpleEdge(10, 3)]
    end

    @testset "graph modifications" begin
        gb = copy(ga)
        add_vertex!(gb)
        @test edges(ga) == edges(gb)
        @test edges(gb) == edges(ga)

        dgb = copy(dga)
        add_vertex!(dgb)
        @test edges(dga) == edges(dgb)
        @test edges(dgb) == edges(dga)
    end

    @testset "hash and isequal" begin
        ghb = copy(ga)
        add_vertex!(ghb)
        dghb = copy(dga)
        add_vertex!(dghb)

        # `isequal` agrees with `==` between two iterators, including for graphs that differ
        # only in trailing isolated vertices
        @test isequal(edges(ga), edges(ghb))
        @test hash(edges(ga)) == hash(edges(ghb))
        @test isequal(edges(dga), edges(dghb))
        @test hash(edges(dga)) == hash(edges(dghb))
        @test !isequal(edges(ga), edges(dga))

        # graphs of differing eltype compare and hash equal
        @test isequal(edges(SimpleGraph{UInt8}(ga)), edges(ga))
        @test hash(edges(SimpleGraph{UInt8}(ga))) == hash(edges(ga))
        @test isequal(edges(SimpleDiGraph{Int16}(dga)), edges(dga))
        @test hash(edges(SimpleDiGraph{Int16}(dga))) == hash(edges(dga))

        # edgeless graphs are equal regardless of vertex count or directedness
        @test isequal(edges(SimpleGraph(0)), edges(SimpleGraph(7)))
        @test hash(edges(SimpleGraph(0))) == hash(edges(SimpleGraph(7)))
        @test isequal(edges(SimpleGraph(4)), edges(SimpleDiGraph(9)))
        @test hash(edges(SimpleGraph(4))) == hash(edges(SimpleDiGraph(9)))

        # `isequal` is structural where `==` is not, so edge containers are distinct keys
        ea = collect(Edge, edges(ga))
        sa = Set{Edge}(ea)
        @test edges(ga) == ea
        @test !isequal(edges(ga), ea)
        @test !isequal(ea, edges(ga))
        @test edges(ga) == sa
        @test !isequal(edges(ga), sa)
        @test !isequal(sa, edges(ga))

        # `Dict` and `Set` use `isequal`
        d = Dict{Any,Int}(edges(ga) => 1)
        @test d[edges(ghb)] == 1
        @test !haskey(d, ea)
        @test !haskey(d, sa)
        @test length(Set{Any}([edges(ga), edges(ghb), ea, sa])) == 3
        @test length(unique(Any[edges(ga), edges(ghb)])) == 1

        # distinct edge sets hash apart
        @test length(
            Set(hash(edges(SimpleGraph(20, 40; rng=StableRNG(s)))) for s in 1:200)
        ) == 200
    end
end
