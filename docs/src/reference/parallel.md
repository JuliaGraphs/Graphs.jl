# Parallel Algorithms

*Graphs.jl* implements some graph algorithms in a parallelized fashion.

## Index

```@index
Pages = ["parallel.md"]
```

## Full Docs

```@autodocs
Modules = [Graphs.Parallel]
Pages = [
    "Parallel/Parallel.jl",
    "Parallel/utils.jl",
    "Parallel/distance.jl",
    "Parallel/centrality/betweenness.jl",
    "Parallel/centrality/closeness.jl",
    "Parallel/centrality/pagerank.jl",
    "Parallel/centrality/radiality.jl",
    "Parallel/centrality/stress.jl",
    "Parallel/dominatingset/minimal_dom_set.jl",
    "Parallel/independentset/maximal_ind_set.jl",
    "Parallel/shortestpaths/bellman-ford.jl",
    "Parallel/shortestpaths/dijkstra.jl",
    "Parallel/shortestpaths/floyd-warshall.jl",
    "Parallel/shortestpaths/johnson.jl",
    "Parallel/traversals/bfs.jl",
    "Parallel/traversals/greedy_color.jl",
    "Parallel/vertexcover/random_vertex_cover.jl",
]

```