"""
    is_chordal(g)

Check whether a graph is chordal.

A graph is said to be *chordal* if every cycle of length `≥ 4` has a chord
(i.e., an edge between two nodes not adjacent in the cycle).

### Performance
This algorithm is linear in the number of vertices and edges of the graph (i.e.,
it runs in `O(nv(g) + ne(g))` time).

### Implementation Notes
`g` is chordal if and only if it admits a perfect elimination ordering—that is,
an ordering of the vertices of `g` such that for every vertex `v`, the set of
all neighbors of `v` that come later in the ordering forms a complete graph.
This is precisely the condition checked by the maximum cardinality search
algorithm [1], implemented herein.

We take heavy inspiration here from the existing Python implementation in [2].

Not implemented for directed graphs, graphs with self-loops, or graphs with
parallel edges.

### References
[1] Tarjan, Robert E. and Mihalis Yannakakis. "Simple Linear-Time Algorithms to
    Test Chordality of Graphs, Test Acyclicity of Hypergraphs, and Selectively
    Reduce Acyclic Hypergraphs." *SIAM Journal on Computing* 13, no. 3 (1984):
    566–79. https://doi.org/10.1137/0213035.
[2] NetworkX Developers. "is_chordal." NetworkX 3.5 documentation. NetworkX,
    May 29, 2025. Accessed June 2, 2025.
    https://networkx.org/documentation/stable/reference/algorithms/generated/networkx.algorithms.chordal.is_chordal.html.

# Examples
TODO: Add examples
"""
function is_chordal(g::AbstractSimpleGraph)
    # The possibility of self-loops is already ruled out by the `AbstractSimpleGraph` type
    is_directed(g) && throw(ArgumentError("Graph must be undirected"))
    has_self_loops(g) && throw(ArgumentError("Graph must not have self-loops"))

    # Every graph of order `< 4` has no cycles of length `≥ 4` and thus is trivially chordal
    nv(g) < 4 && return true

    unnumbered = Set(vertices(g))
    start_vertex = pop!(unnumbered) # The search can start from any arbitrary vertex
    numbered = Set(start_vertex)

    #= Searching by maximum cardinality ensures that in any possible perfect elimination
    ordering of `g`, `purported_clique_nodes` is precisely the set of neighbors of `v` that
    come later in the ordering. Hence, if the subgraph induced by `purported_clique_nodes`
    in any iteration is not complete, `g` cannot be chordal. =#
    while !isempty(unnumbered)
        # `v` is the vertex in `unnumbered` with the most neighbors in `numbered`
        v = _max_cardinality_node(g, unnumbered, numbered)
        delete!(unnumbered, v)
        push!(numbered, v)

        # A complete subgraph of a larger graph is called a "clique," hence the naming here
        purported_clique_nodes = intersect(neighbors(g, v), numbered)
        purported_clique = induced_subgraph(g, purported_clique_nodes)

        _is_complete_graph(purported_clique) || return false
    end

    #= That `g` admits a perfect elimination ordering is an "if and only if" condition for
    chordality, so if every `purported_clique` was indeed complete, `g` must be chordal. =#
    return true
end

function _max_cardinality_node(
    g::AbstractSimpleGraph, unnumbered::Set{T}, numbered::Set{T}
) where {T}
    cardinality(v::T) = count(in(numbered), neighbors(g, v))
    return argmax(cardinality, unnumbered)
end

_is_complete_graph(g::AbstractSimpleGraph) = density(g) == 1
