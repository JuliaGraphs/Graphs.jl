# News

## dev - unreleased
- Louvain community detection algorithm
- Graph views: `ReverseView` and `UndirectedView` for directed graphs
- New graph products: `strong_product`, `disjunctive_product`, `lexicographic_product`, `homomorphic_product`
- `maximum_clique`, `clique_number`, `maximal_independent_sets`, `maximum_independent_set`, `independence_number`
- `regular_tree` generator
- `kruskal_mst` now accepts weight vectors
- `is_planar` planarity test and `planar_maximally_filtered_graph` (PMFG) algorithm
- `count_connected_components` for efficiently counting connected components without materializing them
- `connected_components!` is now exported and accepts an optional `search_queue` argument to reduce allocations
- `is_connected` optimized to avoid allocating component vectors

## v1.13.0 - 2025-06-05
- **(breaking)** Julia v1.10 (LTS) minimum version requirement
- Non-allocating `enumerate_paths!`

## v1.12.0 - 2024-09-29
- New options for `BFSIterator`

## v1.11.0 - 2024-05-05
- DFS and BFS iterators
- Dorogovtsev-Mendes graph generator optimization

## v1.10.0 - 2024-04-05
- Longest path algorithm for DAGs
- All simple paths algorithm

## v1.9.0 - 2023-09-28
- Rewrite of `edit_distance` with edge costs
- Eulerian cycles/trails for undirected graphs
- `mincut` implementation
- `strongly_connected_components_tarjan`

## v1.8.0 - 2023-02-10
- `newman_watts_strogatz` graph generator
- Prufer coding for trees
- `isdigraphical`

## v1.7.0 - 2022-06-19
- Hierarchical documentation structure

## v1.6.0 - 2022-02-09
- **(breaking)** Requires Julia >= v1.6
- **(breaking)** `Base.zero` no longer mandatory for `AbstractGraph`
- Simplified `AbstractGraph` interface

## v1.5.0 - 2022-01-09
- **(breaking)** `merge_vertices` now only works on subtypes of `AbstractSimpleGraph`
- `rich_club` function
- `induced_subgraph` with boolean indexing
- Optional start vertex for `maximum_adjacency_search`

## v1.4.0 - 2021-10-17
- Initial release as Graphs.jl (successor to LightGraphs.jl)

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
