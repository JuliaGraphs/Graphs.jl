using BenchmarkTools, Graphs

const BENCHDIR = dirname(@__FILE__)

const DIGRAPHS = Dict{String,DiGraph}(
    "complete100" => complete_digraph(100), "path500" => path_digraph(500)
)

const GRAPHS = Dict{String,Graph}(
    "complete100" => complete_graph(100),
    "tutte" => smallgraph(:tutte),
    "path500" => path_graph(500),
)

serialbenchmarks = [
    "serial/core.jl",
    "serial/connectivity.jl",
    "serial/centrality.jl",
    "serial/edges.jl",
    "serial/insertions.jl",
    "serial/traversals.jl",
]

const SUITE = BenchmarkGroup()

foreach(serialbenchmarks) do bm
    include(bm)
end

parallelbenchmarks = ["parallel/egonets.jl"]

foreach(parallelbenchmarks) do bm
    include(joinpath(BENCHDIR, bm))
end
