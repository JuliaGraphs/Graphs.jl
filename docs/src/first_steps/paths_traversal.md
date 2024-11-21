# Paths and traversal

_Graphs.jl_ provides several traversal and shortest-path algorithms, along with various utility functions. Where appropriate, edge distances may be passed in as a matrix of real number values.

Edge distances for most traversals may be passed in as a sparse or dense matrix of values, indexed by `[src,dst]` vertices. That is, `distmx[2,4] = 2.5` assigns the distance `2.5` to the (directed) edge connecting vertex 2 and vertex 4. Note that for undirected graphs `distmx[4,2]` also has to be set.

Default edge distances may be passed in via the `Graphs.DefaultDistance` structure.

Any graph traversal will traverse an edge only if it is present in the graph. When a distance matrix is given:

1. distance values for undefined edges will be ignored;
2. any unassigned values (in sparse distance matrices) for edges that are present in the graph will be assumed to take the default value of 1.0;
3. any zero values (in sparse/dense distance matrices) for edges that are present in the graph will instead have an implicit edge cost of 1.0.

## Graph traversal

Graph traversal refers to a process that traverses vertices of a graph following certain order (starting from user-input sources). This package implements three traversal schemes:

- `BreadthFirst`
- `DepthFirst`
- `MaximumAdjacency`

The package also includes uniform random walks and self avoiding walks with the following functions:

- `randomwalk`
- `non_backtracking_randomwalk`
- `self_avoiding_walk`

## Shortest paths

The following properties always hold for shortest path algorithms implemented here:

- The distance from a vertex to itself is always `0`.
- The distance between two vertices with no connecting edge is always `Inf` or `typemax(eltype(distmx))`.

The [`dijkstra_shortest_paths`](@ref), [`desopo_pape_shortest_paths`](@ref), [`floyd_warshall_shortest_paths`](@ref), [`bellman_ford_shortest_paths`](@ref), and [`yen_k_shortest_paths`](@ref) functions return _path states_ (subtypes of `Graphs.AbstractPathState`) that contain various information about the graph learned during traversal.

The corresponding state types (with the exception of `YenState`) have the following common fields:

- `state.dists` holds a vector with the distances computed, indexed by source vertex.
- `state.parents` holds a vector of parents of each vertex on the shortest paths (the parent of a source vertex is always `0`). `YenState` substitutes `.paths` for `.parents`.

In addition, with the appropriate optional arguments, [`dijkstra_shortest_paths`](@ref) will return information on all possible shortest paths available from the source.

## Utility functions

- Once a path state is found using a shortest path algorithm, some or all of the paths can be obtained using [`enumerate_paths`](@ref).
- A longest path within a directed acyclic graph can be found with [`dag_longest_path`](@ref).
- In the case of a graph with some edges having negative weights, the existence of a cycle whose edges sum to a negative value can be detected with [`has_negative_edge_cycle_spfa`](@ref).
