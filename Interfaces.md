# Interfaces of Graph Package


The *Graphs* package supports generic programming via a generic interface system, which consists of a hierarchy of abstract types for graph representation. Each graph type should implement a set of methods to provide basic interfaces for external codes to interact with them. This document outlines the type system and the interface requirements. 

It is worth noting that the design here is largely inspired by the [Boost Graph Library](http://www.boost.org/doc/libs/1_53_0/libs/graph/doc/index.html).

## Graph Concepts

Several abstract graph types are introduced for graphs exposing different sets of interfaces. These types are organized into a hierarchy as follows

```julia
 # the root type of all graphs
abstract AbstractGraph

 # for graphs where vertices can be directly enumerated
abstract AbstractVertexListGraph <: AbstractGraph

 # for graphs where edges can be directly enumerated
abstract AbstractEdgeListGraph <: AbstractVertexListGraph

 # all graphs where outgoing edges of each vertex can be enumerated
abstract AbstractIncidenceGraph <: AbstractVertexListGraph

 # all graphs where both incoming & outgoing edges of each vertex can be enumerated
abstract AbstractBidirectionalGraph <: AbstractIncidenceGraph

 # all graphs where adjacent vertices (neighbors) of each vertex can be enumerated
abstract AbstractAdjacencyGraph <: AbstractVertexListGraph

 # all graphs where one can test the existence of an edge (u, v) efficient
abstract AbstractAdjacencyMatrix <: AbstractVertexListGraph
```

**Remarks**

1. Here is a quote from the document of Boost Graph Library, which justifies the design of this seemingly complex concept hierarchy:

    ```
    The reason for factoring the graph interface into so many concepts is to encourage algorithm 
    interfaces to require and use only the minimum interface of a graph, thereby increasing the 
    reusability of the algorithm.
    ```
    
2. As Julia does not support multiple inheritance. we adjust the structure of the concept hierarchy. In particular, we make ``AbstractVertexListGraph`` the parent of most other concepts. Below are reasons for this adjustment:

   (1) It is very rare in practice that a graph class is not able to provide interfaces to enumerate all vertices. Therefore, imposing this requirement for most graph types is reasonable. 
   
   (2) This change circumvents the need of multiple inheritance.
   
   (3) Under special circumstances where it is not feasible to provide a vertex enumeration interface, one can still create new concepts by inheriting from the root type ``AbstractGraph``. 
    
    
3. Unlike BGL, we do not use ``property_map``. Arrays and Associative types in Julia provide a more elegant solution in most cases.
    

## Interface Requirements

**Notations**

``G`` | a graph type
``g`` | an instance of ``G``
``e`` | an edge, which should be an instance of type ``edge_type(G)``
``u``, ``v`` | vertices, which should be instances of type ``vertex_type(G)`` 

#### AbstractGraph

```julia
vertex_type(g)      # The type of each vertex
edge_type(g)        # The type of each edge
is_directed(g)      # Whether it is a directed graph
is_mutable(g)       # whether it can be mutated
```

#### AbstractVertexListGraph

``AbstractVertexListGraph`` refines ``AbstractGraph``, and additionally requires the interfaces below

```julia
num_vertices(g)     # the number of vertices
vertices(g)         # an iterable object for enumerating all vertices
```

To iterate over all vertices of an instance of ``AbstractVertexListGraph``:
```julia
for v in vertices(g)
    ...
end
```

#### AbstractEdgeListGraph

``AbstractEdgeListGraph`` refines ``AbstractVertexListGraph``, and additionally requires the interfaces below

```julia
num_edges(g)        # the number of edges
edges(g)            # an iterable object for enumerating all edges
```

To iterate over all edges of an instance of ``AbstractEdgeList``:
```julia
for e in edges(g)
    ...
end
```

#### AbstractIncidenceGraph

``AbstractIncidenceGraph`` refines ``AbstractVertexListGraph``, and additionally requires the interfaces below

```julia
source(e, g)        # get the source vertex of edge e
target(e, g)        # get the target vertex of edge e
out_degree(v, g)    # the number of outgoing edges incident with v
out_edges(g)        # an iterable object for enumerating outgoing edges of v
```

To iterate over the outgoing edges and neighbors of a vertex ``s``:
```julia
for e in out_edges(s, g)
    # source(e, g) is always s
    t = target(e, g)   # get a neighbor t 
    ...
end
```


#### AbstractBidirectionalGraph

``AbstractBidirectionalGraph`` refines ``AbstractIncidenceGraph``, and additionally requires the interfaces below

```julia
in_degree(v, g)     # the number of incoming edges incident with v
in_edges(v, g)      # an iterable object for enumerating incoming edges of v
``` 

#### AbstractAdjacencyGraph

``AbstractAdjacencyGraph`` refines ``AbstractVertexListGraph``, and additionally requires the interfaces below

```julia
num_adjvertices(v, g)       # the number of adjacent vertices of v
adjvertices(v, g)           # an iterable object for enumerating adjacent vertices of v
```

#### AbstractAdjacencyMatrix

```AdjacencyAdjacencyMatrix``` refines ```AbstractVertexListGraph```, and additionally requires the interfaces below

```julia
edge(u, v, g)       # return the edge from u to v
```



#### Undirected Graphs

Following the design of BGL, the interfaces for undirected graphs are the same as those for directed graphs. The reason that BGL (and thus this package) does not provide separate interfaces for undirected graph is that many algorithms on directed graphs also work (without changes) on undirected graphs, and it would be very inconvenient to implement each of these algorithms twice simply because of slight differences in the interface. 

However, people should keep in mind some differences in semantics when using the interfaces for undirected graphs. 

* Let ``g`` be an instance of ``AbstractEdgeListGraph``. Then ``num_edges(g)`` is the number of *undirected edges* when ``g`` is undirected. More specifically, ``(u, v)`` and ``(v, u)`` are counted as one edge. In alignment with this semantics, ``edges(g)`` returns a list of *undirected edges*, which may contain either ``(u, v)`` or ``(v, u)``, but not both of them.

* Let ``g`` be an instance of ``AbstractIncidenceGraph``. Then each edge in ``out_edges(g)`` is also an incoming edge. Therefore, for undirected graph, you may simply interpret ``out_edges(g)`` as the collection of all incident edges, and it should be fine in most cases. 

    As a rule of thumb, types that use incidence list to represent an undirected graph should inherit from ``AbstractIncidenceGraph`` instead of ``AbstractBidirectionalGraph``.
    
* Let ``g`` be an instance of ``AbstractAdjacencyMatrix``, ``edge(u, v, g)`` should be equal to ``edge(v, u, g)``.

* These differences in semantics are irrelevant to many graph algorithms (e.g. graph search/traversal, shortest path, and spanning tree). In cases where these differences do matter, one can always call ``is_directed(g)`` to tell whether ``g`` is a directed or undirected graph.

