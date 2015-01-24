Generic Interfaces
==================

In *Graphs.jl*, the graph concepts are abstracted into a set of generic interfaces. Below is a detailed specification. We *strongly* recommend reading through this specification before you write a graph type to ensure that your graph type conforms to the interface system.

Basic interface
---------------

All graph types should be declared as a sub-type of ``AbstractGraph{V,E}``, where ``V`` is the vertex type, and ``E`` is the edge type. 

The following two functions are provided for graphs of all types.

.. py:function:: vertex_type(g)

    returns the vertex type of a graph, *i.e.*, ``V``.
    
.. py:function:: edge_type(g)

    returns the edge type of a graph, *i.e.*, ``E``.

**Note:** The two basic functions above have been implemented over ``AbstractGraph`` and one need not implement them for specific graph types. 

In addition, the following method needs to be implemented for each graph type:

.. py:function:: is_directed(g)

    returns whether ``g`` is a directed graph.


Vertex List interface
---------------------

.. py:function:: num_vertices(g)

    returns the number of vertices contained in ``g``.
    
.. py:function:: vertices(g)

    returns an iterable view/container of all vertices.
    
    
Edge List interface
-------------------
    
.. py:function:: num_edges(g)

    returns the number of edges contained in ``g``.
    
.. py:function:: edges(g)

    returns an iterable view/container of all edges.
    
.. py:function:: source(e, g)

    returns the source vertex of an edge ``e`` in graph ``g``.
    
.. py:function:: target(e, g)

    returns the target vertex of an edge ``e`` in graph ``g``.
        
Vertex Map interface
---------------------

.. py:function:: vertex_index(v, g)

    returns the index of a vertex ``v`` in graph ``g``. Each vertex
    must have a unique index between 1 and ``num_vertices``.
    
Edge Map interface
------------------

.. py:function:: edge_index(e, g)

    returns the index of an edge ``e`` in graph ``g``. Each edge
    must have a unique index between 1 and ``num_edges``.
        
    
Adjacency List interface
------------------------

.. py:function:: out_degree(v, g)

    returns the number of outgoing neighbors from vertex ``v`` in graph ``g``.
    
.. py:function:: out_neighbors(v, g)

    returns an iterable view/container of all outgoing neighbors of vertex ``v`` in graph ``g``.
    
The following example prints all vertices of a graph as well as its neighbors

.. code-block:: python

    for u in vertices(g)
        print("$u: ")
        for v in out_neighbors(u, g)
            println("$v ")
        end
        println()
    end
    
    
Incidence List interface
------------------------

.. py:function:: out_degree(v, g)
        
    returns the number of outgoing edges from vertex ``v`` in graph ``g``.
    
.. py:function:: out_edges(v, g)

    returns an iterable view/container of outgoing edges from vertex ``v`` in graph ``g``.
    
.. py:function:: source(e, g)

    returns the source vertex of an edge ``e`` in graph ``g``.
    
.. py:function:: target(e, g)

    returns the target vertex of an edge ``e`` in graph ``g``.  
        
The following example prints all vertices of a graph as well as its incidence edges

.. code-block:: python

    for u in vertices(g)
        print("$u: ")
        for e in out_edges(u, g)
            v = target(e, g)
            println("($u -- $v) ")
        end
        println()
    end        
        
        
    
Bidirectional Incidence List interface
--------------------------------------

This interface refines the ``Incidence List`` and requires the implementation of two additional methods:

.. py:function:: in_degree(v, g)
        
    returns the number of incoming edges to vertex ``v`` in graph ``g``.
    
.. py:function:: in_edges(v, g)

    returns an iterable view/container of the incoming edges to vertex ``v`` in graph ``g``.
         

    
Interface declaration and verification
---------------------------------------

It is important to note that a specific graph type can implement multiple interfaces. If a method is required to be implemented for two interfaces (*e.g.*, ``out_degree`` in both adjacency list an incidence list), this method need only be implemented once. 

Julia does not provide a builtin mechanism for interface declaration. To declare that a specific graph type implements certain interfaces, one can use the macro ``@graph_implements``. For example, to declare that a graph type ``G`` implements vertex list and adjacency list, one can write:

.. code-block:: python

     @graph_implements G vertex_list adjacency_list


This statement instantiates the following methods:

.. code-block:: python

    implements_vertex_list(::G) = true
    implements_adjacency_list(::G) = true
    
The following is a list of supported interface names

* ``vertex_list``
* ``edge_list``
* ``vertex_map``
* ``edge_map``
* ``adjacency_list``
* ``incidence_list``
* ``bidirectional_adjacency_list``
* ``bidirectional_incidence_list``

In a function that implements a generic graph algorithm, one can use the macro ``@graph_requires`` to verify whether the input graph implements the required interfaces. A typical graph algorithm function may look like follows

.. code-block:: python

    function myfunc(g::AbstractGraph, params)
        @graph_requires g vertex_list adjacency_list
        ...
    end

Here, the ``@graph_requires`` statement checks whether the graph ``g`` implements the interfaces for ``vertex_list`` and ``adjacency_list``, and throws exceptions if ``g`` does not satisfy the requirements. 




