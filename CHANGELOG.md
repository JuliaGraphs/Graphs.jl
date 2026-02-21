# News

## dev - unreleased
- Louvain community detection algorithm
- Graph views: `ReverseView` and `UndirectedView` for directed graphs
- New graph products: `strong_product`, `disjunctive_product`, `lexicographic_product`, `homomorphic_product`
- `maximum_clique`, `clique_number`, `maximal_independent_sets`, `maximum_independent_set`, `independence_number`
- `regular_tree` generator
- `kruskal_mst` now accepts weight vectors

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
