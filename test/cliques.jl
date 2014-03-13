using Graphs
using Base.Test

function setofsets(array_of_arrays)
    Set(map(Set, array_of_arrays))
end

function test_cliques(graph, expected)
    # Make test results insensitive to ordering
    setofsets(find_cliques(graph)) == setofsets(expected)
end

g = simple_adjlist(3, is_directed=false)
add_edge!(g, 1, 2)
@test test_cliques(g, Array[[1,2], [3]])
add_edge!(g, 2, 3)
@test test_cliques(g, Array[[1,2], [2,3]])
