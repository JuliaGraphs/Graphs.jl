mutable struct DummyGraph <: AbstractGraph{Int} end
mutable struct DummyDiGraph <: AbstractGraph{Int} end
mutable struct DummyEdge <: AbstractEdge{Int} end

@testset "Interface" begin
    dummygraph = DummyGraph()
    dummydigraph = DummyDiGraph()
    dummyedge = DummyEdge()

    @test_throws Graphs.NotImplementedError is_directed(DummyGraph)
    @test_throws Graphs.NotImplementedError zero(DummyGraph)

    for edgefun in [src, dst, Pair, Tuple, reverse]
        @test_throws Graphs.NotImplementedError edgefun(dummyedge)
    end

    for edgefun2edges in [==]
        @test_throws Graphs.NotImplementedError edgefun2edges(dummyedge, dummyedge)
    end

    for graphfunbasic in [nv, ne, vertices, edges, is_directed, edgetype]
        @test_throws Graphs.NotImplementedError graphfunbasic(dummygraph)
    end

    for graphfun1int in [has_vertex, inneighbors, outneighbors]
        @test_throws Graphs.NotImplementedError graphfun1int(dummygraph, 1)
    end
    for graphfunedge in [has_edge]
        @test_throws Graphs.NotImplementedError graphfunedge(dummygraph, dummyedge)
        @test_throws Graphs.NotImplementedError graphfunedge(dummygraph, 1, 2)
    end

    # Implementation error
    impl_error = Graphs.NotImplementedError(edges)
    @test impl_error isa Graphs.NotImplementedError{typeof(edges)}
    io = IOBuffer()
    Base.showerror(io, impl_error)
    @test String(take!(io)) == "method $edges not implemented."
end # testset
