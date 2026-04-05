# Graph views formats

*Graphs.jl* provides views around directed graphs. 
`ReverseGraph` is a graph view that wraps a directed graph and reverse the direction of every edge.
`UndirectedGraph` is a graph view that wraps a directed graph and consider every edge as undirected.

## Index

```@index
Pages = ["wrappedgraphs.md"]
```

## Full docs

```@autodocs
Modules = [Graphs]
Pages = [
    "wrappedGraphs/graphviews.jl",
]

```