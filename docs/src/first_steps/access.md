# Graph access

The following is an overview of functions for accessing graph properties.

## Global graph properties

- `nv(g)` returns the number of vertices in `g`.
- `ne(g)` returns the number of edges in `g`.
- `vertices(g)` returns an iterable object containing all the vertices in `g`.
- `edges(g)` returns an iterable object containing all the edges in `g`.
- `has_vertex(g, v)` checks whether graph `g` includes a vertex numbered `v`.
- `has_edge(g, s, d)` checks whether graph `g` includes an edge from the source vertex `s` to the destination vertex `d`.
- `has_edge(g, e)` returns true if there is an edge in g that satisfies `e == f` for any `f ∈ edges(g)`. This is a strict equality test that may require all properties of `e` are the same. This definition of equality depends on the implementation. For testing whether an edge exists between two vertices `s,d` use `has_edge(g, s, d)`. Note: to use the `has_edge(g, e)` method safely, it is important to understand the conditions under which edges are equal to each other. These conditions are defined by the `has_edge(g::G,e)` method **as defined** by the graph type `G`. The default behavior is to check `has_edge(g,src(e),dst(e))`. This distinction exists to allow new graph types such as MetaGraphs or MultiGraphs to distinguish between edges with the same source and destination but potentially different properties.
- `has_self_loops(g)` checks for self-loops in `g`.
- `is_directed(g)` checks if `g` is a directed graph.
- `eltype(g)` returns the type of the vertices of `g`.

## Vertex properties

- `neighbors(g, v)` returns the neighbors of vertex `v` in an iterable (if `g` is directed, only outneighbors are returned).
- `all_neighbors(` returns all the neighbors of vertex `v` (if `g` is directed, both inneighbors and outneighbors are returned).
- `inneighbors` return the inneighbors of vertex `v` (equivalent to `neighbors` for undirected graphs).
- `outneighbors` returns the outneighbors of vertex `v` (equivalent to `neighbors` for undirected graphs).

## Edge properties

- `src(e)` gives the source vertex `s` of an edge `(s, d)`.
- `dst(e)` gives the destination vertex `d` of an edge `(s, d)`.
- `reverse(e)` creates a new edge `(d, s)` from edge `(s, d)`.

## Persistence of vertex indices
Adding a vertex to the graph with `add_vertex!(g)` adds it (if successful) to the end of the "vertex-list". Therefore, it is possible to access the index of the recently added vertex by using `nv(g)`:
```julia-repl
julia> g = SimpleGraph(10)
{10, 0} undirected simple Int64 graph

julia> add_vertex!(g)
true

julia> last_added_vertex = nv(g)
11
```
Note that this index is NOT persistent if vertices added earlier are removed. When `rem_vertex!(g, v)` is called, `v` is "switched" with the last vertex before being deleted. As edges are identified by vertex indices, one has to be careful with edges as well. An edge added as `add_edge!(g, 3, 11)` can not be expected to always pass the `has_edge(g, 3, 11)` check:
```julia-repl
julia> g = SimpleGraph(10)
{10, 0} undirected simple Int64 graph

julia> add_vertex!(g)
true

julia> add_edge!(g, 3, 11)
true

julia> g
{11, 1} undirected simple Int64 graph

julia> has_edge(g, 3, 11)
true

julia> rem_vertex!(g, 7)
true

julia> has_edge(g, 3, 11)
false

julia> has_edge(g, 3, 7)  # vertex number 11 "renamed" to vertex number 7
true
```