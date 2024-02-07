# Graphs.jl

[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://juliagraphs.org/Graphs.jl/dev/)
[![Build status](https://github.com/JuliaGraphs/Graphs.jl/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/JuliaGraphs/Graphs.jl/actions/workflows/ci.yml?query=branch%3Amaster)
[![Code coverage](http://codecov.io/github/JuliaGraphs/Graphs.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphs/Graphs.jl?branch=master)
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

The _Graphs.jl_ project is a reboot of the _LightGraphs.jl_ package (archived in October 2021), which remains available on GitHub at [sbromberger/LightGraphs.jl](https://github.com/sbromberger/LightGraphs.jl). If you don't need any new features developed since the fork, you can continue to use older versions of _LightGraphs.jl_ indefinitely. New versions will be released here using the name _Graphs.jl_ instead of _LightGraphs.jl_. There was an older package also called _Graphs.jl_. The source history and versions are still available in this repository, but the current code base is unrelated to the old _Graphs.jl_ code and is derived purely from _LightGraphs.jl_. To access the history of the old _Graphs.jl_ code, you can start from [commit 9a25019](https://github.com/JuliaGraphs/Graphs.jl/commit/9a2501948053f60c630caf9d4fb257e689629041).

### Transition from LightGraphs to Graphs

_LightGraphs.jl_ and _Graphs.jl_ are functionally identical, still there are some steps involved making the change:

- Change `LightGraphs = "093fc24a-ae57-5d10-9952-331d41423f4d"` to `Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"` in your Project.toml.
- Update your `using` and `import` statements.
- Update your type constraints and other references to `LightGraphs` to `Graphs`.
- Increment your version number. Following semantic versioning, we suggest a patch release when no graphs or other `Graphs.jl`-objects can be passed through the API of your package by those depending on it, otherwise consider it a breaking release. "Passed through" entails created outside and consumed inside your package and vice versa.
- Tag a release.

### About versions

- The master branch of _Graphs.jl_ is generally designed to work with versions of Julia starting from the [LTS release](https://julialang.org/downloads/#long_term_support_release) all the way to the [current stable release](https://julialang.org/downloads/#current_stable_release), except during Julia version increments as we transition to the new version.
- Later versions: Some functionality might not work with prerelease / unstable / nightly versions of Julia. If you run into a problem, please file an issue.
- The project was previously developed under the name _LightGraphs.jl_ and older versions of _LightGraphs.jl_ (≤ v1.3.5) must still be used with that name.
- There was also an older package also called _Graphs.jl_ (git tags `v0.2.5` through `v0.10.3`), but the current code base here is a fork of _LightGraphs.jl_ v1.3.5.
- All older _LightGraphs.jl_ versions are tagged using the naming scheme `lg-vX.Y.Z` rather than plain `vX.Y.Z`, which is used for old _Graphs.jl_ versions (≤ v0.10) and newer versions derived from _LightGraphs.jl_ but released with the _Graphs.jl_ name (≥ v1.4).
- If you are using a version of Julia prior to 1.x, then you should use _LightGraphs.jl_ at `lg-v.12.*` or _Graphs.jl_ at `v0.10.3`
