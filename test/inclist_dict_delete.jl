using Test
using Graphs


@testset "Incidence Dictionaries" begin

g = Graphs.incdict(Graphs.ExVertex,is_directed=false)
variables = [ExVertex(1, "x1"), ExVertex(2, "x2"), ExVertex(3, "x3"), ExVertex(4, "x4")]
map(v -> add_vertex!(g, v), variables)

for i = 1 : length(variables)
    @test vertices(g)[i] in variables
    @test out_degree(variables[i], g) == 0
end

factors =[ExVertex(5, "x1x2f1"), ExVertex(6, "x2x3f1"), ExVertex(7, "x3x4f1")]
add_vertex!(g, factors[1])
edge = Graphs.make_edge(g, variables[1], factors[1]); Graphs.add_edge!(g, edge)
edge = Graphs.make_edge(g, factors[1], variables[2]); Graphs.add_edge!(g, edge)
add_vertex!(g, factors[2])
edge = Graphs.make_edge(g, variables[2], factors[2]); Graphs.add_edge!(g, edge)
edge = Graphs.make_edge(g, factors[2], variables[3]); Graphs.add_edge!(g, edge)
add_vertex!(g, factors[3])
edge = Graphs.make_edge(g, variables[3], factors[3]); Graphs.add_edge!(g, edge)
edge = Graphs.make_edge(g, factors[3], variables[4]); Graphs.add_edge!(g, edge)

@test num_vertices(g) == 7

@test [out_degree(v, g) for v in variables] == [1, 2, 2, 1]
@test [out_degree(f, g) for f in factors] == [2, 2, 2]

@test setdiff(collect(out_neighbors(variables[1], g)), [factors[1]]) == []
@test setdiff(collect(out_neighbors(variables[2], g)), [factors[1], factors[2]]) == []
@test setdiff(collect(out_neighbors(variables[3], g)), [factors[2], factors[3]]) == []
@test setdiff(collect(out_neighbors(variables[4], g)), [factors[3]]) == []
@test setdiff(collect(in_neighbors(variables[1], g)), [factors[1]]) == []
@test setdiff(collect(in_neighbors(variables[2], g)), [factors[1], factors[2]]) == []
@test setdiff(collect(in_neighbors(variables[3], g)), [factors[2], factors[3]]) == []
@test collect(in_neighbors(variables[4], g)) == [factors[3]]

# Delete testing
delete_vertex!(variables[4], g)
@test num_vertices(g) == 6
@test_throws Exception out_degree(variables[4], g)
@test out_degree(factors[3], g) == 1 # Should be just x3 now

end
