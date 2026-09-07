"""
    chromatic_number(g, alg)

The chromatic number of the undirected graph `g`, that is the smallest number of colors in a
proper vertex coloring, computed with the algorithm `alg`.

!!! note
    This function is declared without any methods. Computing a chromatic number exactly is
    NP-hard and Graphs.jl provides no implementation of it. Methods are added by other
    packages, each supplying its own algorithm type; VNGraphs.jl, which wraps the
    `very_nauty` C library, is the first intended to do so. Settings that belong to a
    particular algorithm are fields of `alg` rather than arguments here.
"""
function chromatic_number end

"""
    edge_chromatic_number(g, alg)

The edge chromatic number of the undirected graph `g`, that is the smallest number of colors
in a proper edge coloring, computed with the algorithm `alg`.

!!! note
    This function is declared without any methods, on the same terms as `chromatic_number`.
"""
function edge_chromatic_number end
