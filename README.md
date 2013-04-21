## Graphs.jl

Graphs.jl is a Julia package that provides graph types and algorithms. The design of this package is inspired by the [Boost Graph Library](http://www.boost.org/doc/libs/1_53_0/libs/graph/doc/index.html) (*e.g.* using standardized generic interfaces), while taking advantage of Julia's language features (*e.g.* multiple dispatch).

**Main Features:**

* Generic abstraction of graph concepts through standardized interface
* A variety of graph types tailored to different purposes (some uses compact and efficient representation, while others provides more expressive power)
* A collection of graph algorithms:
    - graph traversal with visitor support: BFS, DFS
    - cycle detection
    - connected components
    - topological sorting
    - shortest paths: Dijkstra, Floyd-Warshall
    - minimum spanning trees: Prim, Kruskal
    - more algorithms are being implemented
* Matrix-based characterization: adjacency matrix, weight matrix, Laplacian matrix

