# Graphs

[![Build Status](https://github.com/JuliaGraphs/Graphs.jl/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/JuliaGraphs/Graphs.jl/actions/workflows/ci.yml?query=branch%3Amaster)
[![codecov.io](http://codecov.io/github/JuliaGraphs/Graphs.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphs/Graphs.jl?branch=master)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://juliagraphs.github.io/Graphs.jl/latest)

**Project Status:** The Graphs project is a fork of the now-archived LightGraphs
package, which remains available on GitHub at
[sbromberger/LightGraphs.jl](https://github.com/sbromberger/LightGraphs.jl). If
you don't need any new features developed since the fork, you can continue to
use older versions of LightGraphs indefinitely. New versions will be released
here using the name Graphs instead of LightGraphs. There was an older package
also called Graphs, of which the source history and versions are still available in
this repository, but the current code base is unrelated to the old Graphs code
and is derived purely from LightGraphs.

Graphs offers both (a) a set of simple, concrete graph implementations -- `Graph`
(for undirected graphs) and `DiGraph` (for directed graphs), and (b) an API for
the development of more sophisticated graph implementations under the `AbstractGraph`
type.

The project goal is to mirror the functionality of robust network and graph
analysis libraries such as [NetworkX](http://networkx.github.io) while being
simpler to use and more efficient than existing Julian graph libraries such as
[Graphs.jl](https://github.com/JuliaLang/Graphs.jl). It is an explicit design
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
Full documentation is available at [GitHub Pages](https://juliagraphs.github.io/Graphs.jl/latest).
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
* Julia 0.3: LightGraphs v0.3.7 (`lg-v0.3.7`) is the last version guaranteed to work with Julia 0.3.
* Julia 0.4: LightGraphs versions in the 0.6 series (`lg-v0.6.*`) are designed to work with Julia 0.4.
* Julia 0.5: LightGraphs versions in the 0.7 series (`lg-v0.7.*`) are designed to work with Julia 0.5.
* Julia 0.6: LightGraphs versions in the 0.8 through 0.12 (`lg-v0.{8-12}.*`) series are designed to work with Julia 0.6.
* Julia 0.7 / 1.0: LightGraphs versions in the 1.x series (`lg-v1.*`) are designed to work with Julia 0.7 and Julia 1.0.
* Later versions: Some functionality might not work with prerelease / unstable / nightly versions of Julia. If you run into a problem, please file an issue.

# Contributing and Reporting Bugs
We welcome contributions and bug reports! Please see [CONTRIBUTING.md](https://github.com/JuliaGraphs/Graphs.jl/blob/master/CONTRIBUTING.md)
for guidance on development and bug reporting.

# Citing

We encourage you to cite our work if you have used our libraries, tools or datasets, refer to `CITATION.bib`.
Starring the repository on GitHub is also appreciated.
