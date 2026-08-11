# Color refinement

Color refinement (the 1-dimensional Weisfeiler-Leman algorithm) iteratively refines a
vertex coloring until it is stable, so that two vertices share a color exactly when the
refinement cannot distinguish them.

## Index

```@index
Pages = ["color_refinement.md"]
```

## Full docs

```@autodocs
Modules = [Graphs]
Pages   = ["color_refinement.jl"]
```
