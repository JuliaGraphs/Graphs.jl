Graph Types
===========

This package provides several graph types that implement different subsets of interfaces.
In particular, it has four graph types:

* ``GenericEdgeList``
* ``GenericAdjacencyList``
* ``GenericIncidenceList``
* ``GenericGraph``

All of these types are parametric. One can easily derive customized graph types using different type parameters.

Edge List
-----------

``GenericEdgeList`` implements the edge list representation of a graph, where a list of all edges is maintained by each graph.

Here is the definition of ``GenericEdgeList``:

.. code-block:: python

    type EdgeList{V,E,VList,EList} <: AbstractGraph{V, E}

It has four type parameters:

* ``V``:  the vertex type
* ``E``:  the edge type
* ``VList``: the type of the vertex list
* ``EList``: the type of the edge list

The package defines the following aliases for convenience:

.. code-block:: python

    const SimpleEdgeList{E} = GenericEdgeList{Int,E,UnitRange{Int},Vector{E}}
    const EdgeList{V,E} = GenericEdgeList{V,E,Vector{V},Vector{E}}

``GenericEdgeList`` implements the following interfaces

* ``vertex_list``
* ``vertex_map``
* ``edge_list``
* ``edge_map``

Specifically, it implements the following methods:

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

.. py:function:: edges(g)

    returns the list of all edges

.. py:function:: edge_index(e, g)

    returns the index of ``e`` in graph ``g``.


In addition, it implements following methods for construction:

.. py:function:: simple_edgelist(nv, edges[, is_directed=true])

    constructs a simple edge list with ``nv`` vertices and the given list of edges.

.. py:function:: edgelist(vs, edges[, is_directed=true])

    constructs an edge list given lists of vertices and edges.



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

    const SimpleAdjacencyList = GenericAdjacencyList{Int, UnitRange{Int}, Vector{Vector{Int}}}
    const AdjacencyList{V} = GenericAdjacencyList{V, Vector{V}, Vector{Vector{V}}}

``GenericAdjacencyList`` implements the following interfaces

* ``vertex_list``
* ``vertex_map``
* ``adjacency_list``

Specifically, it implements the following methods:

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

.. py:function:: adjlist(vs[, is_directed=true])

    constructs an adjacency list with a vector of vertices given by ``vs``.

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

    const SimpleIncidenceList = GenericIncidenceList{Int, IEdge, UnitRange{Int}, Vector{Vector{IEdge}}}
    const IncidenceList{V,E} = GenericIncidenceList{V, E, Vector{V}, Vector{Vector{E}}}

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

.. py:function:: inclist(vs[, is_directed=true])

    constructs an incidence list with a list of vertices ``vs``. The edge type is ``Edge{V}``.

.. py:function:: inclist(V, E[, is_directed=true])

    constructs an empty incidence list of vertex type ``V``. The edge type is ``E``.

.. py:function:: inclist(vs, E[, is_directed=true])

    constructs an incidence list with a list of vertices ``vs``. The edge type is ``E``.

.. py:function:: add_vertex!(g, x)

    adds a vertex. Here, ``x`` can be of a vertex type, or can be made into a vertex using ``make_vertex(g, x)``.

.. py:function:: add_edge!(g, e)

    adds an edge ``e`` to the graph.

.. py:function:: add_edge!(g, u, v)

    adds an edge between ``u`` and ``v``. This applies when ``make_edge(g, u, v)`` is defined for the input types.


Graph
------

``GenericGraph`` provides a complete interface by integrating edge list, bidirectional adjacency list, and bidirectional incidence list into one type. The definition is given by

.. code-block:: python

    type GenericGraph{V,E,VList,EList,IncList} <: AbstractGraph{V,E}

It has six type parameters:

* ``V``: the vertex type
* ``E``: the edge type
* ``VList``: the type of vertex list
* ``EList``: the type of edge list
* ``IncList``: the type of incidence list

It also defines ``SimpleGraph`` as follows

.. code-block:: python

    const SimpleGraph = GenericGraph{Int,IEdge,UnitRange{Int},Vector{IEdge},Vector{Vector{IEdge}}}

and a more full-fledged type ``Graph`` as follows

.. code-block:: python

    const Graph{V,E} = GenericGraph{V,E,Vector{V},Vector{E},Vector{Vector{E}}}


``GenericGraph`` implements the following interfaces:

* ``vertex_list``
* ``edge_list``
* ``vertex_map``
* ``edge_map``
* ``adjacency_list``
* ``incidence_list``
* ``bidirectional_adjacency_list``
* ``bidirectional_incidence_list``

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

.. py:function:: in_degree(v, g)

    returns the number of incoming neighbors to vertex ``v`` in graph ``g``.

.. py:function:: in_edges(v, g)

    returns the number of incoming edges to vertex ``v`` in graph ``g``.

.. py:function:: in_neighbors(v, g)

    returns an iterable view/container of all incoming neighbors to vertex ``v`` in graph ``g``.


In addition, it also implements the following methods for construction:

.. py:function:: simple_graph(nv[, is_directed=true])

    constructs an instance of ``SimpleGraph`` with ``nv`` vertices and no edges (initially).

.. py:function:: graph(vertices, edges[, is_directed=true])

    constructs an instance of ``Graph`` with given vertices and edges.


.. py:function:: add_vertex!(g, x)

    adds a vertex. Here, ``x`` can be of a vertex type, or can be made into a vertex using ``make_vertex(g, x)``.

.. py:function:: add_edge!(g, e)

    adds an edge ``e`` to the graph.

.. py:function:: add_edge!(g, u, v)

    adds an edge between ``u`` and ``v``. This applies when ``make_edge(g, u, v)`` is defined for the input types.
