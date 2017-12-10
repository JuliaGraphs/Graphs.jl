Vertices and Edges
===================

Vertex Types
-------------

A vertex can be of any Julia type. For example, it can be an integer, a character, or a string.

This package provides two specific vertex types: ``KeyVertex`` and ``ExVertex``. The definition of ``KeyVertex`` is:

.. code-block:: python

    struct KeyVertex{K}
        index::Int
        key::K
    end

Here, each vertex has a unique index and a key value of a user-chosen type (*e.g.* a string).

The definition of ``ExVertex`` is:

.. code-block:: python

    mutable struct ExVertex
        index::Int
        label::UTF8String
        attributes::Dict{UTF8String,Any}
    end

The ``ExVertex`` type allows one to attach a label as well as other attributes to a vertex. The constructor of this type takes an index and a label string as arguments. The following code shows how one can create an instance of ``ExVertex`` and attach a price to it.

.. code-block:: python

    v = ExVertex(1, "vertex-a")
    v.attributes["price"] = 100.0

The ``ExVertex`` type implements a ``vertex_index`` function, as

.. py:function:: vertex_index(v)

    returns the index of the vertex ``v``.

``SimpleGraph`` is a special case where the vertices are of type ``Int`` and store both their index and identity. In all other graphs, ``Int`` vertices are unordered indices.

Edge Types
-----------

This package provides two edge types: ``Edge`` and ``ExEdge``. The former is a basic edge type that simply encapsulates the source and target vertices of an edge, while the latter allows one to specify attributes.

The definition of ``Edge`` is given by

.. code-block:: python

    struct Edge{V}
        index::Int
        source::V
        target::V
    end

    typealias IEdge Edge{Int}

The definition of ``ExEdge`` is given by

.. code-block:: python

    mutable struct ExEdge{V}
        index::Int
        source::V
        target::V
        attributes::Dict{UTF8String,Any}
    end

``ExEdge`` has two constructors, one takes ``index``, ``source``, and ``target`` as arguments, while the other use all four fields.

One can either construct an edge directly using the constructors, or use the ``add_edge`` methods for graphs, which can automatically assign an index to a new edge.

Both edge types implement the following methods:

.. py:function:: edge_index(e)

    returns the index of the edge ``e``.

.. py:function:: source(e)

    returns the source vertex of the edge ``e``.

.. py:function:: target(e)

    returns the target vertex of the edge ``e``.

.. py::function:: revedge(e)

    returns a new edge, exactly the same except source and target are switched.

A custom edge type ``E{V}`` which is constructible by ``E(index::Int, s::V, t::V)`` and implements the above methods is usable in the ``VectorIncidenceList`` parametric type.  Construct such a list with ``inclist(V,E{V})``, where E and V are your vertex and edge types.  See test/inclist.jl for an example.

Edge Properties
---------------

Many algorithms use a property of an edge such as length, weight,
flow, etc. as input. As the algorithms do not mandate any structure
for the edge types, these edge properties can be passed through to the
algorithm by an ``EdgePropertyInspector``.  An
``EdgePropertyInspector`` when passed to the ``edge_property`` method
along with an edge and a graph, will return that property of an edge.

All edge property inspectors should be declared as a subtype of
``AbstractEdgePropertyInspector{T}`` where ``T`` is the type of the
edge property.  The edge propery inspector should respond to the
following methods.

.. py::function:: edge_property(i, e, g)

  returns the edge property of edge ``e`` in graph ``g`` selected by
  inspector ``i``.

.. py::function:: edge_property_requirement(i, g)

  checks that graph ``g`` implements the interface(s) necessary for
  inspector ``i``

Three edge property inspectors are provided
``ConstantEdgePropertyInspector``, ``VectorEdgePropertyInspector`` and
``AttributeEdgePropertyInspector``.

``ConstantEdgePropertyInspector(c)`` constructs an edge property
inspector that returns the constant ``c`` for each edge.

``VectorEdgePropertyInspector(v)`` constructs an edge property
inspector that returns ``v[edge_index(e, g)]``.  It requires that
``g`` implement the ``edge_map`` interface.

``AttributeEdgePropertyInspector(name)``  constructs an edge property
inspector that returns the named attribute from an ``ExEdge``.
``AttributeEdgePropertyInspector`` requires that the graph implements
the ``edge_map`` interface.
