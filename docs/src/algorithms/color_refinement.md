# Color refinement

Color refinement repeatedly splits color classes according to the number of neighbors
each vertex has in every color class. The process stops when no class can be split
further. In the resulting stable coloring, vertices share a color when color refinement
cannot distinguish them.

## Index

```@index
Pages = ["color_refinement.md"]
```

## Full docs

```@autodocs
Modules = [Graphs]
Pages   = ["color_refinement.jl"]
```
