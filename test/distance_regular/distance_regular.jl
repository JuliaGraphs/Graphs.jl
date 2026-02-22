@testset "Distance-regular" begin
    icosahedral = smallgraph(:icosahedral)
    dodecahedral = smallgraph(:dodecahedral)
    @testset "Is distance-regular" begin
        @test is_distance_regular(icosahedral)
        @test is_distance_regular(dodecahedral)
    end
    @testset "Intersection array" begin
        @test intersection_array(icosahedral) == ([5, 2, 1], [1, 2, 5])
    end
end
