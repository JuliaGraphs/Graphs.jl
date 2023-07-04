# Experimental algorithms

`Graphs.Experimental` is a module for graph algorithms that are newer or less stable. We can adopt algorithms before we finalize an interface for using them or if we feel that full support cannot be provided to the current implementation. You can expect new developments to land here before they make it into the main module. This enables the development to keep advancing without being risk-averse because of stability guarantees. You can think of this module as a 0.X semantic version space ; it is a place where you can play around with new algorithms, perspectives, and interfaces without fear of breaking critical code.

**A Note To Users**

Code in this module is unstable and subject to change. Do not use any code in this module in production environments without understanding the (large) risks involved. However, we welcome bug reports and issues via the normal channels..

## Index

```@index
Pages = ["experimental.md"]
```

## Full docs

```@autodocs
Modules = [Graphs.Experimental, Graphs.Experimental.Traversals, Graphs.Experimental.ShortestPaths, Graphs.Experimental.Parallel]
Pages = [
    "Experimental/Experimental.jl",
    "Experimental/isomorphism.jl",
    "Experimental/vf2.jl",
    "Experimental/Parallel/traversals/gdistances.jl",
    "Experimental/Parallel/Parallel.jl",
    "Experimental/ShortestPaths/astar.jl",
    "Experimental/ShortestPaths/bellman-ford.jl",
    "Experimental/ShortestPaths/bfs.jl",
    "Experimental/ShortestPaths/desopo-pape.jl",
    "Experimental/ShortestPaths/dijkstra.jl",
    "Experimental/ShortestPaths/floyd-warshall.jl",
    "Experimental/ShortestPaths/johnson.jl",
    "Experimental/ShortestPaths/ShortestPaths.jl",
    "Experimental/ShortestPaths/spfa.jl",
    "Experimental/Traversals/bfs.jl",
    "Experimental/Traversals/dfs.jl",
    "Experimental/Traversals/Traversals.jl",
]

```