# Graphs.jl

[![Documentation stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliagraphs.org/Graphs.jl/stable/)
[![Documentation dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliagraphs.org/Graphs.jl/dev/)
[![Build status](https://github.com/JuliaGraphs/Graphs.jl/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/JuliaGraphs/Graphs.jl/actions/workflows/ci.yml?query=branch%3Amaster)
[![Code coverage](https://codecov.io/github/JuliaGraphs/Graphs.jl/coverage.svg?branch=master)](https://codecov.io/github/JuliaGraphs/Graphs.jl?branch=master)
[![Code style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

## Overview

The goal of _Graphs.jl_ is to offer a performant platform for network and graph analysis in Julia, following the example of libraries such as [NetworkX](http://networkx.github.io) in Python. To this end, _Graphs.jl_ offers:

- a set of simple, concrete graph implementations -- `SimpleGraph` (for undirected graphs) and `SimpleDiGraph` (for directed graphs)
- an API for the development of more sophisticated graph implementations under the `AbstractGraph` type
- a large collection of graph algorithms with the same requirements as this API.

## Installation

Installation is straightforward. First, enter Pkg mode by hitting `]`, and then run the following command:

```julia-repl
pkg> add Graphs
```

## Basic use

_Graphs.jl_ includes numerous convenience functions for generating graphs, such as `path_graph`, which builds a simple undirected [path graph](https://en.wikipedia.org/wiki/Path_graph) of a given length. Once created, these graphs can be easily interrogated and modified.

```julia-repl
julia> g = path_graph(6)
{6, 5} undirected simple Int64 graph

# Number of vertices
julia> nv(g)
6

# Number of edges
julia> ne(g)
5

# Add an edge to make the path a loop
julia> add_edge!(g, 1, 6);
```

## Documentation

The full documentation is available at [GitHub Pages](https://juliagraphs.org/Graphs.jl/dev/). Documentation for methods is also available via the Julia REPL help system.
Additional tutorials can be found at [JuliaGraphsTutorials](https://github.com/JuliaGraphs/JuliaGraphsTutorials).

## Citing

We encourage you to cite our work if you have used our libraries, tools or datasets. Starring the _Graphs.jl_ repository on GitHub is also appreciated.

The latest citation information may be found in the [CITATION.bib](https://raw.githubusercontent.com/JuliaGraphs/Graphs.jl/master/CITATION.bib) file within the repository.

## Contributing

We welcome contributions and bug reports!
Please see [CONTRIBUTING.md](https://github.com/JuliaGraphs/Graphs.jl/blob/master/CONTRIBUTING.md) for guidance on development and bug reporting.

JuliaGraphs development subscribes to the [Julia Community Standards](https://julialang.org/community/standards/).

## Related packages

It is an explicit design decision that any data not required for graph manipulation (attributes and other information, for example) is expected to be stored outside of the graph structure itself.

Additional functionality like advanced IO and file formats, weighted graphs, property graphs, and optimization-related functions can be found in the packages of the [JuliaGraphs organization](https://juliagraphs.org/).

## Project status

_Graphs.jl_ is the successor to _LightGraphs.jl_ (archived October 2021); see the [CHANGELOG](CHANGELOG.md) for the full transition history.
