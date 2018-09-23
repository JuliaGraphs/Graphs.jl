## Graphs.jl

[![Build Status](https://travis-ci.org/JuliaAttic/Graphs.jl.svg?branch=master)](https://travis-ci.org/JuliaAttic/Graphs.jl)
[![Coverage Status](https://img.shields.io/coveralls/JuliaAttic/Graphs.jl.svg)](https://coveralls.io/r/JuliaAttic/Graphs.jl?branch=master)

[![Graphs](http://pkg.julialang.org/badges/Graphs_0.6.svg)](http://pkg.julialang.org/?pkg=Graphs&ver=0.6)
[![Graphs](http://pkg.julialang.org/badges/Graphs_0.7.svg)](http://pkg.julialang.org/?pkg=Graphs&ver=0.7)
[![Graphs](http://pkg.julialang.org/badges/Graphs_1.0.svg)](http://pkg.julialang.org/?pkg=Graphs&ver=1.0)

Graphs.jl is a Julia package that provides graph types and algorithms. The design of this package is inspired by the [Boost Graph Library](http://www.boost.org/doc/libs/1_53_0/libs/graph/doc/index.html) (*e.g.* using standardized generic interfaces), while taking advantage of Julia's language features (*e.g.* multiple dispatch). This library allows storing of own information in the graph structure -- useful in many cases.

**Note:** as of 2016, this package's original author is no longer actively maintaining it, but there are several active users in the community. We'll engage as best we can, and feel free to open issues here to improve this library. There is a sister library, [LightGraphs](https://github.com/JuliaGraphs/LightGraphs.jl), focused on a slightly different set of use cases.

### Main Features

An important aspect of *Graphs.jl* is the generic abstraction of graph concepts expressed via standardized interfaces, which allows access to a graph's structure while hiding the implementation details. This encourages reuse of data structures and algorithms. In particular, one can write generic graph algorithms that can be applied to different graph types as long as they implement the required interface.

In addition to the generic abstraction, there are other important features:

* A variety of graph types tailored to different purposes
    - generic adjacency list
    - generic incidence list
    - a simple graph type with compact and efficient representation
    - an extended graph type that supports labels and attributes

* A collection of graph algorithms:
    - graph traversal with visitor support: BFS, DFS
    - cycle detection
    - connected components
    - topological sorting
    - shortest paths: Dijkstra, Floyd-Warshall, A\*
    - minimum spanning trees: Prim, Kruskal
    - maximal cliques
    - random graph generation: Erdős–Rényi, Watts-Strogatz (see the
      RandomGraphs.jl package for more random graph models)
    - more algorithms are being implemented

* Matrix-based characterization: adjacency matrix, weight matrix, Laplacian matrix

* All data structures and algorithms are implemented in *pure Julia*, and thus they are portable.

* We paid special attention to the runtime performance. Many of the algorithms are very efficient. For example, a benchmark shows that it takes about *15 milliseconds* to run the Dijkstra's algorithm over a graph with *10 thousand* vertices and *1 million*  edges on a macbook pro.


### Documentation

Please refer to [*Graphs.jl Documentation*](http://graphsjl-docs.readthedocs.org/en/latest/) for latest documentation.
