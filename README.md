# Graphs

[![Build Status](https://github.com/JuliaGraphs/Graphs.jl/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/JuliaGraphs/Graphs.jl/actions/workflows/ci.yml?query=branch%3Amaster)
[![codecov.io](http://codecov.io/github/JuliaGraphs/Graphs.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphs/Graphs.jl?branch=master)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://juliagraphs.org/Graphs.jl/dev/)

**Project Status:** The Graphs project is a reboot of the now-archived LightGraphs
package, which remains available on GitHub at
[sbromberger/LightGraphs.jl](https://github.com/sbromberger/LightGraphs.jl). If
you don't need any new features developed since the fork, you can continue to
use older versions of LightGraphs indefinitely. New versions will be released
here using the name Graphs instead of LightGraphs. There was an older package
also called Graphs. The source history and versions are still available in
this repository, but the current code base is unrelated to the old Graphs code
and is derived purely from LightGraphs. To access the history of the old Graphs code,
you can start from [commit 9a25019](https://github.com/JuliaGraphs/Graphs.jl/commit/9a2501948053f60c630caf9d4fb257e689629041).

Graphs offers both (a) a set of simple, concrete graph implementations -- `Graph`
(for undirected graphs) and `DiGraph` (for directed graphs), and (b) an API for
the development of more sophisticated graph implementations under the `AbstractGraph`
type.

The project goal is to mirror the functionality of robust network and graph
analysis libraries such as [NetworkX](http://networkx.github.io). It is an explicit design
decision that any data not required for graph manipulation (attributes and
other information, for example) is expected to be stored outside of the graph
structure itself. Such data lends itself to storage in more traditional and
better-optimized mechanisms.

Additional functionality may be found in a number of companion packages, including:
  * [LightGraphsExtras.jl](https://github.com/JuliaGraphs/LightGraphsExtras.jl):
  extra functions for graph analysis.
  * [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl): graphs with
  associated meta-data.
  * [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl):
  weighted graphs.
  * [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl): tools for importing
  and exporting graph objects using common file types like edgelists, GraphML,
  Pajek NET, and more.

## Documentation
Full documentation is available at [GitHub Pages](https://juliagraphs.org/Graphs.jl/dev/).
Documentation for methods is also available via the Julia REPL help system.
Additional tutorials can be found at [JuliaGraphsTutorials](https://github.com/JuliaGraphs/JuliaGraphsTutorials).

## Installation
Installation is straightforward: enter Pkg mode by hitting `]`, and then
```julia-repl
(v1.0) pkg> add Graphs
```

## Supported Versions
* Graphs master is generally designed to work with the latest stable version of Julia (except during Julia version increments as we transition to the new version).
* The project was previously developed under the name LightGraphs and older versions of LightGraphs (≤ v1.3.5) must still be used with that name.
* There was also an older package also called Graphs (git tags `v0.2.5` through `v0.10.3`), but the current code base here is a fork of LightGraphs v1.3.5.
* All older LightGraphs versions are tagged using the naming scheme `lg-vX.Y.Z` rather than plain `vX.Y.Z` which is used for old Graphs versions (≤ v0.10) and newer versions derived from LightGraphs but released with the Graphs name (≥ v1.4).
* If you are using a version of Julia prior to 1.x, then you should use LightGraphs.jl at `lg-v.12.*` or Graphs.jl at `v0.10.3`
* Later versions: Some functionality might not work with prerelease / unstable / nightly versions of Julia. If you run into a problem, please file an issue.

# Contributing and Reporting Bugs
We welcome contributions and bug reports! Please see [CONTRIBUTING.md](https://github.com/JuliaGraphs/Graphs.jl/blob/master/CONTRIBUTING.md)
for guidance on development and bug reporting.

JuliaGraphs development subscribes to the [Julia Community Standards](https://julialang.org/community/standards/).

# Citing

We encourage you to cite our work if you have used our libraries, tools or datasets, refer to `CITATION.bib`.
Starring the repository on GitHub is also appreciated.
