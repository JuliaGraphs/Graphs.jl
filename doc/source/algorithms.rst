Graph Algorithms
=================

``Graphs.jl`` implements a collection of classic graph algorithms:

- graph traversal with visitor support: BFS, DFS
- cycle detection
- connected components
- topological sorting
- shortest paths: Dijkstra, Floyd-Warshall, A*
- minimum spanning trees: Prim, Kruskal
- random graph generation
- more algorithms are being implemented


Graph Traversal
---------------

Graph traversal refers to a process that traverses vertices of a graph following certain order (starting from user-input sources). This package implements two traversal schemes: *breadth-first* and *depth-first*.

During traveral, each vertex maintains a status (also called *color*), which is an integer value defined as below:

* ``color = 0``: the vertex has not been encountered (*i.e.* discovered)
* ``color = 1``: the vertex has been discovered and remains open
* ``color = 2``: the vertex has been closed (*i.e.* all its neighbors have been examined)

.. py:function:: traverse_graph(graph, alg, source, visitor[, colormap])

    :param graph:       The input graph, which must implement ``vertex_map`` and ``adjacency_list``.
    :param alg:         The algorithm of traveral, which can be either ``BreadthFirst()`` or ``DepthFirst()``.
    :param source:      The source vertex (or vertices). The traversal starts from here.
    :param visitor:     The visitor which performs certain operations along the traversal.
    :param colormap:    An integer vector that indicates the status of each vertex. If this is input by the user, the status will be written to the input vector, otherwise an internal color vector will be created.

Here, ``visitor`` must be an instance of a sub-type of ``AbstractGraphVisitor``. A specific graph visitor type can choose to implement some or all of the following methods.

.. py:function:: discover_vertex!(visitor, v)

    invoked when a vertex ``v`` is encountered for the first time. This function should return whether to continue traversal.

.. py:function:: open_vertex!(visitor, v)

    invoked when a vertex ``v`` is about to examine ``v``'s neighbors.

.. py:function:: examine_neighbor!(visitor, u, v, color, ecolor)

    invoked when a neighbor/out-going edge is examined. Here ``color`` is the status of ``v``, and ``ecolor`` is the status of the outgoing edge. Edge statuses are currently only considered by depth-first search.

.. py:function:: close_vertex!(visitor, v)

     invoked when all neighbors of ``v`` has been examined.

If a method of these is not implemented, it will automatically fallback to no-op. The package provides some pre-defined visitor types:

* ``TrivialGraphVisitor``: all methods are no-op.
* ``VertexListVisitor``: it has a field ``vertices``, which is a vector comprised of vertices in the order of being discovered.
* ``LogGraphVisitor``: it prints message to show the progress of the traversal.

Many graph algorithms can be implemented based on graph traversal through certain visitors or by using the colormap in certain ways. For example, in this package, topological sorting, connected components, and cycle detection are all implemented using ``traverse_graph`` with specifically designed visitors.


Cycle detection
---------------

In graph theory, a cycle is defined to be a path that starts from some vertex ``v`` and ends up at ``v``.

.. py:function:: test_cyclic_by_dfs(g)

    Tests whether a graph contains a cycle through depth-first search. It returns ``true`` when it finds a cycle, otherwise ``false``. Here, ``g`` must implement ``vertex_list``, ``vertex_map``, and ``adjacency_list``.


Connected components
--------------------

In graph theory, a connected component (in an undirected graph) refers to a subset of vertices such that there exists a path between any pair of them.

.. py:function:: connected_components(g)

    Returns a vector of components, where each component is represented by a vector of vertices. Here, ``g`` must be an undirected graph, and implement ``vertex_list``, ``vertex_map``, and ``adjacency_list``.

Cliques
-------

In graph theory, a clique in an undirected graph is a subset of its vertices
such that every two vertices in the subset are connected by an edge. A maximal
clique is the largest clique containing a given node.

.. py:function:: maximal_cliques(g)

    Returns a vector of maximal cliques, where each maximal clique is represented by a vector of vertices. Here, ``g`` must be an undirected graph, and implement ``vertex_list`` and ``adjacency_list``.

Topological Sorting
-------------------

Topological sorting of an acyclic directed graph is a linear ordering of vertices, such that for each directed edge ``(u, v)``, ``u`` always comes before ``v`` in the ordering.

.. py:function:: topological_sort_by_dfs(g)

    Returns a topological sorting of the vertices in ``g`` in the form of a vector of vertices. Here, ``g`` may be directed or undirected, and implement ``vertex_list``, ``vertex_map``, and ``adjacency_list``.


Shortest Paths
---------------

This package implements three classic algorithms for finding shortest paths:
*Dijkstra's algorithm*, the *Floyd-Warshall algorithm*, and the *A\*
algorithm*. We plan to implement the *Bellman-Ford algorithm* and *Johnson's
algorithm* in the near future.

Dijkstra's Algorithm
~~~~~~~~~~~~~~~~~~~~

.. py:function:: dijkstra_shortest_paths(graph, edge_dists, source[, visitor])

    Performs Dijkstra's algorithm to find shortest paths to all vertices from input sources.

    :param graph:       The input graph
    :param edge_dists:  The vector of edge distances or an edge
			property inspector.
    :param source:      The source vertex (or vertices)
    :param visitor:     An visitor instance

    :returns:           An instance of ``DijkstraStates`` that encapsulates the results.

Here, ``graph`` can be directed or undirected. It must implement
``vertex_map``, ``edge_map`` and ``incidence_list``. `edge_dists` is optional; if not specified,
default distances of `1` are used for each edge.

The following is an example that shows how to use this function:

.. code-block:: python

    # construct a graph and the edge distance vector

    g = simple_inclist(5)

    inputs = [       # each element is (u, v, dist)
        (1, 2, 10.),
        (1, 3, 5.),
        (2, 3, 2.),
        (3, 2, 3.),
        (2, 4, 1.),
        (3, 5, 2.),
        (4, 5, 4.),
        (5, 4, 6.),
        (5, 1, 7.),
        (3, 4, 9.) ]

    ne = length(g1_wedges)
    dists = zeros(ne)

    for i = 1 : ne
        a = inputs[i]
        add_edge!(g1, a[1], a[2])   # add edge
        dists[i] = a[3]             # set distance
    end

    r = dijkstra_shortest_paths(g, dists, 1)

    @assert r.parents == [1, 3, 1, 2, 3]
    @assert r.dists == [0., 8., 5., 9., 7.]

The result has several fields, among which the following are most useful:

* ``parents[i]``:  the parent vertex of the i-th vertex. The parent of each source vertex is itself.
* ``dists[i]``:  the minimum distance from the i-th vertex to source.

The user can (optionally) provide a visitor that perform operations along with the algorithm. The visitor must be an instance of a sub type of ``AbstractDijkstraVisitor``, which may implement part of all of the following methods.

.. py:function:: discover_vertex!(visitor, u, v, d)

    Invoked when a new vertex ``v`` is first discovered (from the parent ``u``). ``d`` is the initial distance from ``v`` to source.

.. py:function:: include_vertex!(visitor, u, v, d)

    Invoked when the distance of a vertex is determined (at the point ``v`` is popped from the heap). This function should return whether to continue the procedure. One can use a visitor to terminate the algorithm earlier by letting this function return ``false`` under certain conditions.

.. py:function:: update_vertex!(visitor, u, v, d)

    Invoked when the distance to a vertex is updated (relaxed).

.. py:function:: close_vertex!(visitor, u, v, d)

    Invoked when a vertex is closed (all its neighbors have been examined).

.. py:function:: dijkstra_shortest_paths_explicit(graph, edge_dists, source[, visitor])
Returns the explicit paths using ``dijkstra_shortest_paths()`` as an array of
vectors of vertices from the source to each target. Empty vectors are used to
indicate vertices that are unreachable from the source. Parameters are the same
as described in ``dijkstra_shortest_paths()``.


Bellman Ford Algorithm
~~~~~~~~~~~~~~~~~~~~

.. py:function:: bellman_ford_shortest_paths(graph, edge_dists, source)

    Performs Bellman Ford algorithm to find shortest paths to all vertices from input sources.

    :param graph:       The input graph
    :param edge_dists:  The vector of edge distances or an edge
			property inspector.
    :param source:      The source vertex (or vertices)

    :returns:           An instance of ``BellmanFordStates`` that encapsulates the results.

Here, ``graph`` can be directed or undirected. Weights can be negative
for a directed graph. It must implement
``vertex_map``, ``edge_map`` and ``incidence_list``.  If there is a
negative weight cycle an exception of ``NegativeCycleError`` is thrown.

The result has several fields, among which the following are most useful:

* ``parents[i]``:  the parent vertex of the i-th vertex. The parent of each source vertex is itself.
* ``dists[i]``:  the minimum distance from the i-th vertex to source.

.. py:function:: has_negative_edge_cycle(graph, edge_dists)

		 Tests if the graph has a negative weight cycle.

    :param graph:       The input graph
    :param edge_dists:  The vector of edge distances or an edge
			property inspector.
    :returns: ``true`` if there is a negative weight cycle, ``false`` otherwise.e

Floyd-Warshall's algorithm
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. py:function:: floyd_warshall(dists)

    Performs Floyd-Warshall algorithm to compute shortest path lengths between each pair of vertices.

    :param dists: The edge distance matrix.
    :returns: The matrix of shortest path lengths.

.. py:function:: floyd_warshall!(dists)

    Performs Floyd-Warshall algorithm inplace, updating an edge distance matrix into a matrix of shortest path lengths.

.. py:function:: floyd_warshall!(dists, nexts)

    Performs Floyd-Warshall algorithm inplace, and writes the next-hop matrix. When this function finishes, ``nexts[i,j]`` is the next hop of ``i`` along the shortest path from ``i`` to ``j``. One can reconstruct the shortest path based on this matrix.


A*
~~

.. py:function:: shortest_path(graph, dists, s, t[, heuristic])

    Find the shortest path between vertices ``s`` and ``t`` of ``graph`` using Hart, Nilsson and Raphael's `A* algorithm <http://en.wikipedia.org/wiki/A*_search_algorithm>`_.

    :param graph: the input graph
    :param dists: the edge distance matrix or an edge property inspector
    :param s: the start vertex
    :param t: the end vertex
    :param heuristic: a function underestimating the distance from its input node to ``t``.

    :returns: an array of edges representing the shortest path.

Minimum Spanning Trees
-----------------------

This package implements two algorithm to find a minimum spanning tree of a graph: *Prim's algorithm* and *Kruskal's algorithm*.

Prim's algorithm
~~~~~~~~~~~~~~~~~

Prim's algorithm finds a minimum spanning tree by growing from a root vertex, adding one edge at each iteration.

.. py:function:: prim_minimum_spantree(graph, eweights, root)

    Perform Prim's algorithm to find a minimum spanning tree.

    :param graph:       the input graph
    :param eweights:    the edge weights (a vector or an edge property inspector)
    :param root:        the root vertex

    :returns:   ``(re, rw)``, where ``re`` is a vector of edges that constitute the resultant tree, and ``rw`` is the vector of corresponding edge weights.


Kruskal's algorithm
~~~~~~~~~~~~~~~~~~~~

Kruskal's algorithm finds a minimum spanning tree (or forest) by gradually uniting disjoint trees.

.. py:function:: kruskal_minimum_spantree(graph, eweights[, K=1])

    :param graph:       the input graph
    :param eweights:    the edge weights (a vector or an edge property inspector)
    :param K:           the number of trees in the resultant forest. If ``K = 1``, it ends up with a tree. This argument is optional. By default, it is set to ``1``.

    :returns:   ``(re, rw)``, where ``re`` is a vector of edges that constitute the resultant tree, and ``rw`` is the vector of corresponding edge weights.


Random Graphs
-------------

Erdős–Rényi graphs
~~~~~~~~~~~~~~~~~~

The `Erdős–Rényi model <https://en.wikipedia.org/wiki/Erd%C5%91s%E2%80%93R%C3%A9nyi_model>`_ sets an edge between each pair of vertices with equal
probability, independently of the other edges.

.. py:function:: erdos_renyi_graph(g, n, p[; has_self_loops=false])

    Add edges between vertices 1:n of graph ``g`` randomly, adding each possible edge with probability ``p`` independently of all others.

    :param g:           the input graph
    :param n:           the number of vertices between which to add edges
    :param p:           the probability with which to add each edge
    :param has_self_loops:      whether to consider edges ``v -> v``.

    :returns: the graph ``g``.

.. py:function:: erdos_renyi_graph(n, p[, has_self_loops=false])

    Convenience function to construct an ``n``-vertex Erdős–Rényi graph as an incidence list.

Watts-Strogatz graphs
~~~~~~~~~~~~~~~~~~~~~

The `Watts–Strogatz
model <https://en.wikipedia.org/wiki/Watts_and_Strogatz_model>`_ is a random
graph generation model that produces graphs with small-world properties,
including short average path lengths and high clustering.

.. py:function:: watts_strogatz_graph(g, n, k, beta)

    Adjust the edges between vertices 1:n of the graph ``g`` in accordance with the Watts-Strogatz model.

    :param g:           the input graph
    :param n:           the number of vertices between which to adjust edges
    :param k:           the base degree of each vertex (n > k, k >= 2, k must be even.)
    :param beta:        the probability of each edge being "rewired".

    :returns: the graph ``g``.

.. py:function:: watts_strogatz_graph(n, k, beta)

    Convenience function to construct an ``n``-vertex Watts-Strogatz graph as an incidence list.
