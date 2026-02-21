@testset "Path from parents" begin
    using Graphs: path_from_parents
    parents = [3, 0, 2, 5, 5]
    @test path_from_parents(1, parents) == [2, 3, 1]
    @test path_from_parents(2, parents) == [2]
    @test path_from_parents(3, parents) == [2, 3]
    @test path_from_parents(4, parents) == [5, 4]
    @test path_from_parents(5, parents) == [5]
end
