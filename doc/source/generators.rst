Graph Generators
=================

``Graphs.jl`` implements a collection of classic graph generators, each of which returns a ``simple_graph``:

.. py:function:: simple_complete_graph(n[, is_directed=true])

    Creates a (default directed) complete graph with ``n`` vertices. A complete graph has edges connecting each pair of vertices.

.. py:function:: simple_star_graph(n[, is_directed=true])

    Creates a (default directed) star graph with ``n`` vertices. A star graph has a central vertex with edges to each other vertex.

.. py:function:: simple_path_graph,(n[, is_directed=true])

    Creates a (default directed) path graph with ``n`` vertices. A path graph connects each successive vertex by a single edge.

.. py:function:: simple_wheel_graph(n[, is_directed=true])

    Creates a (default directed) wheel graph with ``n`` vertices. A wheel graph is a star graph with the outer vertices connected via a closed path graph.

.. py:function:: simple_diamond_graph()

    A `diamond graph <http://en.wikipedia.org/wiki/Diamond_graph>`_.

.. py:function:: simple_bull_graph()

    A `bull graph <https://en.wikipedia.org/wiki/Bull_graph>`_.

.. py:function:: simple_chvatal_graph()

    A `Chvátal graph <https://en.wikipedia.org/wiki/Chvátal_graph>`_.

.. py:function:: simple_cubical_graph()
    
    A `Platonic cubical graph <https://en.wikipedia.org/wiki/Platonic_graph>`_.

.. py:function:: simple_desargues_graph()

    A `Desargues graph <https://en.wikipedia.org/wiki/Desargues_graph>`_.

.. py:function:: simple_dodecahedral_graph()

    A `Platonic dodecahedral graph <https://en.wikipedia.org/wiki/Platonic_graph>`_.

.. py:function:: simple_frucht_graph()

    A `Frucht graph <https://en.wikipedia.org/wiki/Frucht_graph>`_.

.. py:function:: simple_heawood_graph()

    A `Heawood graph <https://en.wikipedia.org/wiki/Heawood_graph>`_.

.. py:function:: simple_house_graph()

    A graph mimicing the classic outline of a house.

.. py:function:: simple_house_x_graph()

    A house graph, with two edges crossing the bottom square.

.. py:function:: simple_icosahedral_graph()

    A `Platonic icosahedral graph <https://en.wikipedia.org/wiki/Platonic_graph>`_.

.. py:function:: simple_krackhardt_kite_graph()

    A `Krackhardt-Kite social network <http://mathworld.wolfram.com/KrackhardtKite.html>`_. 

.. py:function:: moebius_kantor_graph()

    A `Möbius-Kantor graph <http://en.wikipedia.org/wiki/Möbius–Kantor_graph>`_.

.. py:function:: simple_octahedral_graph()

    A `Platonic octahedral graph <https://en.wikipedia.org/wiki/Platonic_graph>`_.

.. py:function:: simple_pappus_graph()

    A `Pappus graph <http://en.wikipedia.org/wiki/Pappus_graph>`_.

.. py:function:: simple_petersen_graph()

    A `Petersen graph <http://en.wikipedia.org/wiki/Petersen_graph>`_.
   
.. py:function:: simple_sedgewick_maze_graph()

    A simple maze graph used in Sedgewick's *Algorithms in C++: Graph Algorithms (3rd ed.)*
.. py:function:: simple_tetrahedral_graph()

    A `Platonic tetrahedral graph <https://en.wikipedia.org/wiki/Platonic_graph>`_.

.. py:function:: simple_truncated_cube_graph()

    A skeleton of the `truncated cube graph <https://en.wikipedia.org/wiki/Truncated_cube>`_.

.. py:function:: simple_truncated_tetrahedron_graph()

    A skeleton of the `truncated tetrahedron graph <https://en.wikipedia.org/wiki/Truncated_tetrahedron>`_.

.. py:function:: simple_tutte_graph()

    A `Tutte graph <https://en.wikipedia.org/wiki/Tutte_graph>`_.

