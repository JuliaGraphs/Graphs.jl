using Aqua
using Documenter
using Graphs
using Graphs.SimpleGraphs
using Graphs.Experimental
using JuliaFormatter
using Test
using SparseArrays
using LinearAlgebra
using Compat
using DelimitedFiles
using Base64
using Random
using Statistics: mean, std
using StableRNGs

const testdir = dirname(@__FILE__)

@testset verbose = true "Code quality (Aqua.jl)" begin
    Aqua.test_all(Graphs; ambiguities=false)
end

@testset verbose = true "Code formatting (JuliaFormatter.jl)" begin
    @test format(Graphs; verbose=false, overwrite=false, ignore="vf2.jl")  # TODO: remove ignore kwarg once the file is formatted correctly
end

@testset verbose = true "Doctests (Documenter.jl)" begin
    # doctest(Graphs)  # TODO: uncomment it when the errors it throws are fixed
end

function testgraphs(g)
    return if is_directed(g)
        [g, DiGraph{UInt8}(g), DiGraph{Int16}(g)]
    else
        [g, Graph{UInt8}(g), Graph{Int16}(g)]
    end
end
testgraphs(gs...) = vcat((testgraphs(g) for g in gs)...)
testdigraphs = testgraphs

# some operations will create a large graph from two smaller graphs. We
# might error out on very small eltypes.
function testlargegraphs(g)
    return if is_directed(g)
        [g, DiGraph{UInt16}(g), DiGraph{Int32}(g)]
    else
        [g, Graph{UInt16}(g), Graph{Int32}(g)]
    end
end
testlargegraphs(gs...) = vcat((testlargegraphs(g) for g in gs)...)

tests = [
    "simplegraphs/runtests",
    "linalg/runtests",
    "parallel/runtests",
    "interface",
    "core",
    "operators",
    "degeneracy",
    "distance",
    "digraph/transitivity",
    "cycles/hawick-james",
    "cycles/johnson",
    "cycles/karp",
    "cycles/basis",
    "cycles/limited_length",
    "cycles/incremental",
    "edit_distance",
    "connectivity",
    "persistence/persistence",
    "shortestpaths/astar",
    "shortestpaths/bellman-ford",
    "shortestpaths/desopo-pape",
    "shortestpaths/dijkstra",
    "shortestpaths/johnson",
    "shortestpaths/floyd-warshall",
    "shortestpaths/yen",
    "shortestpaths/spfa",
    "traversals/bfs",
    "traversals/bipartition",
    "traversals/greedy_color",
    "traversals/dfs",
    "traversals/maxadjvisit",
    "traversals/randomwalks",
    "traversals/diffusion",
    "community/cliques",
    "community/core-periphery",
    "community/label_propagation",
    "community/modularity",
    "community/clustering",
    "community/clique_percolation",
    "community/assortativity",
    "community/rich_club",
    "centrality/betweenness",
    "centrality/closeness",
    "centrality/degree",
    "centrality/katz",
    "centrality/pagerank",
    "centrality/eigenvector",
    "centrality/stress",
    "centrality/radiality",
    "utils",
    "deprecations",
    "spanningtrees/boruvka",
    "spanningtrees/kruskal",
    "spanningtrees/prim",
    "steinertree/steiner_tree",
    "biconnectivity/articulation",
    "biconnectivity/biconnect",
    "biconnectivity/bridge",
    "graphcut/normalized_cut",
    "graphcut/karger_min_cut",
    "dominatingset/degree_dom_set",
    "dominatingset/minimal_dom_set",
    "independentset/degree_ind_set",
    "independentset/maximal_ind_set",
    "vertexcover/degree_vertex_cover",
    "vertexcover/random_vertex_cover",
    "experimental/experimental",
]

@testset verbose = true "Graphs" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end;
