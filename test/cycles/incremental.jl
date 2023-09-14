# The test here cannot be done with GenericDiGraph, as the functions under test
# modify the graph. We probably need another generic graph type with more relaxed
# constraints for modifying graphs.

@testset "ICT" begin
    Gempty = SimpleDiGraph(3)
    Gsomedges = SimpleDiGraph(6)
    add_edge!(Gsomedges, 4, 5)
    add_edge!(Gsomedges, 6, 5)
    for Gtemplate in (Gempty, Gsomedges)
        for dir in (:out, :in)
            G = copy(Gtemplate)
            ict = IncrementalCycleTracker(G; dir=dir)
            @test_nowarn repr(ict)
            @test add_edge_checked!(ict, 1, 2)
            @test add_edge_checked!(ict, 2, 3)
            @test length(edges(G)) == 2 + length(edges(Gtemplate))
            @test !add_edge_checked!(ict, 3, 1)
            @test !add_edge_checked!(ict, 3, 2)
            if dir === :in
                @test !add_edge_checked!(ict, (2, 3), 1)
                @test !add_edge_checked!(ict, (1, 3), 2)
            else
                @test !add_edge_checked!(ict, 3, (1, 2))
                @test !add_edge_checked!(ict, 2, (1, 3))
            end
            @test length(edges(G)) == 2 + length(edges(Gtemplate))
            @test filter(in((1, 2, 3)), topological_sort(ict)) == [1, 2, 3]
        end
    end

    Gcycle2 = SimpleDiGraph(2)
    add_edge!(Gcycle2, 1, 2)
    add_edge!(Gcycle2, 2, 1)
    @test_throws ErrorException IncrementalCycleTracker(Gcycle2)

    Gcycle3 = SimpleDiGraph(3)
    add_edge!(Gcycle3, 1, 2)
    add_edge!(Gcycle3, 2, 3)
    add_edge!(Gcycle3, 3, 1)
    @test_throws ErrorException IncrementalCycleTracker(Gcycle3)
end
