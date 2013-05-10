Graph Types
===========

This package provides several graph types that implement different subsets of interfaces.
In particular, it has three graph types:

* ``GenericAdjacencyList``
* ``GenericIncidenceList``
* ``GenericGraph``

All of these types of parametric types. One can easily derive customized graph types using different type parameters. 

Adjacency List
---------------

``GenericAdjacencyList`` implements the adjacency list representation of a graph, where each vertex maintains a list of neighbors (*i.e.* adjacent vertices).

Here is the definition of ``GenericAdjacencyList``:

.. code-block:: python

    type GenericAdjacencyList{V, VList, AdjList} <: AbstractGraph{V, Edge{V}}
    
It has three type parameters:

* ``V``: the vertex type
* ``VList``: the type of vertex list
* ``AdjList``: the type of the adjacency list. Let ``a`` be an instance of ``AdjList``, and ``i`` be the index of a vertex, then ``a[i]`` must be an iterable container of the neighbors.

The package defines following aliases for convenience:

.. code-block:: python

    typealias SimpleAdjacencyList GenericAdjacencyList{Int, Range1{Int}, Vector{Vector{Int}}}
    typealias AdjacencyList{V} GenericAdjacencyList{V, Vector{V}, Vector{Vector{V}}}
    
``GenericAdjacencyList`` implements the following interfaces

* ``vertex_list``
* ``vertex_map``
* ``adjacency_list``

Specially, it implements the following methods:

.. py:function:: is_directed(g)

    returns whether ``g`` is a directed graph.

.. py:function:: num_vertices(g)

    returns the number of vertices contained in ``g``.
    
.. py:function:: vertices(g)

    returns an iterable view/container of all vertices.
    
.. py:function:: num_edges(g)

    returns the number of edges contained in ``g``.
    
.. py:function:: vertex_index(v, g)

    returns the index of a vertex ``v`` in graph ``g``
    
.. py:function:: out_degree(v, g)

    returns the number of outgoing neighbors from vertex ``v`` in graph ``g``.
    
.. py:function:: out_neighbors(v, g)

    returns an iterable view/container of all outgoing neighbors of vertex ``v`` in graph ``g``.
    
In addition, it implements following methods for construction:

.. py:function:: simple_adjlist(nv[, is_directed=true])

    constructs a simple adjacency list with ``nv`` vertices and no edges (initially). 
    
.. py:function:: adjlist(V[, is_directed=true])
    
    constructs an empty adjacency list of vertex type ``V``. 
    
.. py:function:: add_vertex!(g, v)

    adds a vertex ``v``. This function applies only to graph of type ``AdjacencyList``. 
    It returns the added vertex.
    
    If the vertex type is ``KeyVertex{K}``, then the second argument here can be the key value, and the function will constructs a vertex and assigns an index.
    
    
.. py:function:: add_edge!(g, u, v)

    adds an edge between u and v, such that ``v`` becomes an outgoing neighbor of ``u``. If ``g`` is undirected, then ``u`` is also added to the neighbor list of ``v``.


Incidence List
--------------

``GenericIncidenceList`` implements the incidence list representation of a graph, where each vertex maintains a list of outgoing edges. 

Here is the definition of ``GenericIncidenceList``:

.. code-block:: python

    type GenericIncidenceList{V, E, VList, IncList} <: AbstractGraph{V, E}
    
It has four type parameters:

* ``V``: the vertex type
* ``E``: the edge type
* ``VList``: the type of vertex list
* ``IncList``: the type of incidence list. Let ``a`` be such a list, then ``a[i]`` should be an iterable container of edges. 

The package defines following aliases for convenience:

.. code-block:: python

    typealias SimpleIncidenceList GenericIncidenceList{Int, IEdge, Range1{Int}, Vector{Vector{IEdge}}}
    typealias IncidenceList{V} GenericIncidenceList{V, Edge{V}, Vector{V}, Vector{Vector{Edge{V}}}}
    
``GenericIncidenceList`` implements the following interfaces:

* ``vertex_list``
* ``vertex_map``
* ``edge_map``
* ``adjacency_list``
* ``incidence_list``

Specially, it implements the following methods:

.. py:function:: is_directed(g)

    returns whether ``g`` is a directed graph.

.. py:function:: num_vertices(g)

    returns the number of vertices contained in ``g``.
    
.. py:function:: vertices(g)

    returns an iterable view/container of all vertices.
    
.. py:function:: num_edges(g)

    returns the number of edges contained in ``g``.
    
.. py:function:: vertex_index(v, g)

    returns the index of a vertex ``v`` in graph ``g``

.. py:function:: edge_index(e, g)

    returns the index of an edge ``e`` in graph ``g``.
    
.. py:function:: source(e, g)

    returns the source vertex of an edge ``e`` in graph ``g``.
    
.. py:function:: target(e, g)

    returns the target vertex of an edge ``e`` in graph ``g``. 
    
.. py:function:: out_degree(v, g)

    returns the number of outgoing neighbors from vertex ``v`` in graph ``g``.
    
.. py:function:: out_edges(v, g)

    returns the number of outgoing edges from vertex ``v`` in graph ``g``.
    
.. py:function:: out_neighbors(v, g)

    returns an iterable view/container of all outgoing neighbors of vertex ``v`` in graph ``g``.

    **Note:** ``out_neighbors`` here is implemented based on ``out_edges`` via a proxy type. Therefore, it may be less efficient than the counterpart for ``GenericAdjacencyList``.
    
    
In addition, it implements following methods for construction:    
    
.. py:function:: simple_inclist(nv[, is_directed=true])

    constructs a simple incidence list with ``nv`` vertices and no edges (initially). 
    
.. py:function:: inclist(V[, is_directed=true])
    
    constructs an empty incidence list of vertex type ``V``. The edge type is ``Edge{V}``.
    
.. py:function:: add_vertex!(g, v)

    adds a vertex ``v``. This function applies only to graph of type ``AdjacencyList``. 
    It returns the added vertex.
    
    If the vertex type is ``KeyVertex{K}``, then the second argument here can be the key value, and the function will constructs a vertex and assigns an index.
    
    
.. py:function:: add_edge!(g, u, v)

    adds an edge between u and v, such that ``v`` becomes an outgoing neighbor of ``u``. If ``g`` is undirected, then ``u`` is also added to the neighbor list of ``v``.
    It returns the added edge.
    
    
Graph
------

``GenericGraph`` provides a complete interface by integrating edge list, adjacency list, and incidence list into one type. The definition is given by

.. code-block:: python

    type GenericGraph{V,E,VList,EList,AdjList,IncList} <: AbstractGraph{V,E}

It has six type parameters:

* ``V``: the vertex type
* ``E``: the edge type
* ``VList``: the type of vertex list
* ``EList``: the type of edge list
* ``AdjList``: the type of adjacency list
* ``IncList``: the type of incidence list

It also defines ``SimpleGraph`` as follows

.. code-block:: python

    typealias SimpleGraph GenericGraph{
        Int,            # V
        IEdge,          # E
        Range1{Int},    # VList
        Vector{IEdge},  # EList
        Vector{Vector{Int}},    # AdjList
        Vector{Vector{IEdge}}}  # IncList

``GenericGraph`` implements the following interfaces:

* ``vertex_list``
* ``edge_list``
* ``vertex_map``
* ``edge_map``
* ``adjacency_list``
* ``incidence_list``    

Specifically, it implements the following methods:

.. py:function:: is_directed(g)

    returns whether ``g`` is a directed graph.

.. py:function:: num_vertices(g)

    returns the number of vertices contained in ``g``.
    
.. py:function:: vertices(g)

    returns an iterable view/container of all vertices.
    
.. py:function:: num_edges(g)

    returns the number of edges contained in ``g``.
    
.. py:function:: edges(g)

    returns an iterable view/container of all edges.
    
.. py:function:: vertex_index(v, g)

    returns the index of a vertex ``v`` in graph ``g``

.. py:function:: edge_index(e, g)

    returns the index of a vertex ``e`` in graph ``g``.
    
.. py:function:: source(e, g)

    returns the source vertex of an edge ``e`` in graph ``g``.
    
.. py:function:: target(e, g)

    returns the target vertex of an edge ``e`` in graph ``g``. 
    
.. py:function:: out_degree(v, g)

    returns the number of outgoing neighbors from vertex ``v`` in graph ``g``.
    
.. py:function:: out_edges(v, g)

    returns the number of outgoing edges from vertex ``v`` in graph ``g``.
    
.. py:function:: out_neighbors(v, g)

    returns an iterable view/container of all outgoing neighbors of vertex ``v`` in graph ``g``.

In addition, it also implements the following methods for construction:

.. py:function:: simple_graph(nv[, is_directed=true])

    constructs an instance of ``SimpleGraph`` with ``nv`` vertices and no edges (initially). 
    
.. py:function:: graph(V, E[, is_directed=true])

    constructs an empty graph of vertex type ``V`` and edge type ``E``. The vertex list, edge list, adjacency list, and incidence list are respectively of types: ``Vector{V}``, ``Vector{E}``, ``Vector{Vector{V}}``, and ``Vector{Vector{E}}``.

.. py:function:: add_vertex!(g, v)

    adds a vertex ``v``. ``v`` can also be a key value if ``V`` is ``KeyVertex``, or a label string if ``V`` is ``ExVertex``.
    
.. py:function:: add_edge!(g, e)

    adds an edge ``e``. 
    
.. py:function:: add_edge!(g, u, v)

    adds an edge between ``u`` and ``v``. This applies only when ``E`` is either ``Edge`` or ``ExEdge``.

    
    
    