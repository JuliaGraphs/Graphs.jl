# Parallel algorithms

`Graphs.Parallel` is a module for graph algorithms that are parallelized. Their names should be consistent with the serial versions in the main module. In order to use parallel versions of the algorithms you can write:

```julia
using Graphs
import Graphs.Parallel

g = path_graph(10)
bc = Parallel.betweenness_centrality(g)
```

## How to use them?

The arguments to parallel versions of functions match as closely as possible their serial versions with potential addition default or keyword arguments to control parallel execution. One exception is that for algorithms that cannot be meaningfully parallelized for certain types of arguments a MethodError will be raised. For example, `dijkstra_shortest_paths` works for either a single or multiple source argument, but since the parallel version is slower when given only a single source, it will raise a `MethodError`.

```julia
g = Graph(10)
# these work
Graphs.dijkstra_shortest_paths(g,1)
Graphs.dijkstra_shortest_paths(g, [1,2])
Parallel.dijkstra_shortest_paths(g, [1,2])
# this doesn't
Parallel.dijkstra_shortest_paths(g,1)
```

Note that after `import`ing or `using` `Graphs.Parallel`, you must fully qualify the version of the function you wish to use (using, _e.g._, `Graphs.betweenness_centrality(g)` for the sequential version and `Parallel.betweenness_centrality(g)` for the parallel version).

## Available parallel algorithms

The following is a current list of parallel algorithms:

- Centrality measures:

  - `Parallel.betweenness_centrality`
  - `Parallel.closeness_centrality`
  - `Parallel.pagerank`
  - `Parallel.radiality_centrality`
  - `Parallel.stress_centrality`

- Distance measures:

  - `Parallel.center`
  - `Parallel.diameter`
  - `Parallel.eccentricity`
  - `Parallel.radius`

- Shortest paths algorithms:

  - `Parallel.bellman_ford_shortest_paths`
  - `Parallel.dijkstra_shortest_paths`
  - `Parallel.floyd_warshall_shortest_paths`
  - `Paralell.johnson_shortest_paths`

- Traversal algorithms:
  - `Parallel.bfs`
  - `Parallel.greedy_color`

Also note that in some cases, the arguments for the parallel versions may differ from the serial (standard) versions. As an example, parallel Dijkstra shortest paths takes advantage of multiple processors to execute centrality from multiple source vertices. It is an error to pass a single source vertex into the parallel version of dijkstra_shortest_paths.

## Index

```@index
Pages = ["parallel.md"]
```

## Full docs

```@autodocs
Modules = [Graphs, Graphs.Parallel]
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