# GraphsFlows

[![CI](https://github.com/JuliaGraphs/Graphs.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaGraphs/Graphs.jl/actions/workflows/ci.yml)
[![codecov.io](http://codecov.io/github/JuliaGraphs/Graphs.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphs/Graphs.jl?branch=master)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliagraphs.org/Graphs.jl/dev/)

Flow algorithms on top of [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl),
including `maximum_flow`, `multiroute_flow` and `mincost_flow`. 
See [Maximum flow problem](https://en.wikipedia.org/wiki/Maximum_flow_problem)
for a detailed description of the problem.

Documentation for this package is available [here](https://juliagraphs.github.io/Graphs.jl/latest/). For an overview of JuliaGraphs, see [this page](https://juliagraphs.github.io/).

## Usage

### Maxflow 

```julia
julia> using Graphs, Graphs
julia> flow_graph = Graphs.DiGraph(8) # Create a flow graph
julia> flow_edges = [
    (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
    (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
    (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
]

julia> capacity_matrix = zeros(Int, 8, 8)  # Create a capacity matrix

julia> for e in flow_edges
    u, v, f = e
    Graphs.add_edge!(flow_graph, u, v)
    capacity_matrix[u,v] = f
end

julia> f, F = maximum_flow(flow_graph, 1, 8) # Run default maximum_flow (push-relabel) without the capacity_matrix

julia> f, F = maximum_flow(flow_graph, 1, 8, capacity_matrix) # Run default maximum_flow with the capacity_matrix

julia> f, F = maximum_flow(flow_graph, 1, 8, capacity_matrix, algorithm=EdmondsKarpAlgorithm()) # Run Edmonds-Karp algorithm

julia> f, F = maximum_flow(flow_graph, 1, 8, capacity_matrix, algorithm=DinicAlgorithm()) # Run Dinic's algorithm

julia> f, F, labels = maximum_flow(flow_graph, 1, 8, capacity_matrix, algorithm=BoykovKolmogorovAlgorithm()) # Run Boykov-Kolmogorov algorithm
```

### Multi-route flow

```julia
julia> using Graphs, Graphs

julia> flow_graph = Graphs.DiGraph(8) # Create a flow graph

julia> flow_edges = [
(1, 2, 10), (1, 3, 5),  (1, 4, 15), (2, 3, 4),  (2, 5, 9),
(2, 6, 15), (3, 4, 4),  (3, 6, 8),  (4, 7, 16), (5, 6, 15),
(5, 8, 10), (6, 7, 15), (6, 8, 10), (7, 3, 6),  (7, 8, 10)
]

julia> capacity_matrix = zeros(Int, 8, 8) # Create a capacity matrix

julia> for e in flow_edges
    u, v, f = e
    Graphs.add_edge!(flow_graph, u, v)
    capacity_matrix[u, v] = f
end

julia> f, F = multiroute_flow(flow_graph, 1, 8, capacity_matrix, routes = 2) # Run default multiroute_flow with an integer number of routes = 2

julia> f, F = multiroute_flow(flow_graph, 1, 8, capacity_matrix, routes = 1.5) # Run default multiroute_flow with a noninteger number of routes = 1.5

julia> points = multiroute_flow(flow_graph, 1, 8, capacity_matrix) # Run default multiroute_flow for all the breaking points values

julia> f, F = multiroute_flow(points, 1.5) # Then run multiroute flow algorithm for any positive number of routes

julia> f, F, labels = multiroute_flow(flow_graph, 1, 8, capacity_matrix, flow_algorithm = BoykovKolmogorovAlgorithm(), routes = 2) # Run multiroute flow algorithm using Boykov-Kolmogorov algorithm as maximum_flow routine
```
