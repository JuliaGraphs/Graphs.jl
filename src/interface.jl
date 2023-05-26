# This file contains the common interface for Graphs.

"""
    NotImplementedError{M}(m)

`Exception` thrown when a method from the `AbstractGraph` interface
is not implemented by a given graph type.
"""
struct NotImplementedError{M} <: Exception
    m::M
    NotImplementedError(m::M) where {M} = new{M}(m)
end

Base.showerror(io::IO, ie::NotImplementedError) = print(io, "method $(ie.m) not implemented.")

_NI(m) = throw(NotImplementedError(m))

"""
    AbstractVertex

A trait representing a single vertex.
"""
@traitdef AbstractVertex{V}
@traitimpl AbstractVertex{V} <- is_directed(V)

"""
    AbstractEdge

An abstract type representing a single edge between two vertices of a graph.
"""
abstract type AbstractEdge{V} end
abstract type AbstractWeightedEdge{V, U} <: AbstractEdge{V} end

"""
    AbstractEdgeIter

An abstract type representing an edge iterator.
"""
abstract type AbstractEdgeIter end

"""
    AbstractGraph

An abstract type representing a simple graph (but which can have loops).
"""
abstract type AbstractGraph{V, E} end

"""
    AbstractGraph

An abstract type representing a simple graph (but which can have loops).
"""
abstract type AbstractGraph{V, E} end

abstract type AbstractBidirectionalGraph{V, E} <: AbstractGraph{V, E} end

@traitdef IsDirected{G<:AbstractGraph}
@traitimpl IsDirected{G} <- is_directed(G)

@traitdef IsRangeBased{G<:AbstractGraph}
@traitimpl IsRangeBased{G} <- is_range_based(G)

@traitdef IsSimplyMutable{G<:AbstractGraph}
@traitimpl IsSimplyMutable{G} <- is_simply_mutable(G)

@traitdef IsMutable{G<:AbstractGraph}
@traitimpl IsMutable{G} <- is_mutable(G)

@traitdef IsWeightMutable{G<:AbstractGraph}
@traitimpl IsWeightMutable{G} <- is_weight_mutable(G)

@traitdef IsVertexStable{G<:AbstractGraph}
@traitimpl IsVertexStable{G} <- is_vertex_stable(G)

#
# Interface for AbstractVertex
#
import Base.isless#, Base.:(==)
"""
    isless(v1, v2)

Return true if vertex v1 is less than vertex v2 in lexicographic order.
"""
@traitfn Base.isless(v1::V, v2::V) where {V; AbstractVertex{V}} = _NI("src")

# @traitfn Base.:(==)(v1::V, v2::V) where {V; AbstractVertex{V}} = _NI("==")

"""
    vindex(v)

Return an index for the vertex `v`.
"""
vindex(v) = _NI("vindex")

#
# Interface for AbstractEdge
#
hash(v::AbstractEdge) = _NI("hash")

"""
    isless(e1, e2)

Return true if edge e1 is less than edge e2 in lexicographic order.
"""
isless(v1::AbstractEdge , v2::AbstractEdge) = _NI("src")

==(e1::AbstractEdge, e2::AbstractEdge) = _NI("==")

"""
    src(e)

Return the source vertex of edge `e`.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleGraph(2);

julia> add_edge!(g, 1, 2);

julia> src(first(edges(g)))
1
```
"""
src(e::AbstractEdge) = _NI("src")

"""
    dst(e)

Return the destination vertex of edge `e`.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleGraph(2);

julia> add_edge!(g, 1, 2);

julia> dst(first(edges(g)))
2
```
"""
dst(e::AbstractEdge) = _NI("dst")

"""
    weight(e)

Return the weight of edge `e`.
"""
weight(e::AbstractWeightedEdge) = _NI("weight")


Pair(e::AbstractEdge) = _NI("Pair")
Tuple(e::AbstractEdge) = _NI("Tuple")

"""
    reverse(e)

Create a new edge from `e` with source and destination vertices reversed.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleDiGraph(2);

julia> add_edge!(g, 1, 2);

julia> reverse(first(edges(g)))
Edge 2 => 1
```
"""
reverse(e::AbstractEdge) = _NI("reverse")


#
# Interface for AbstractGraphs
#
"""
    edgetype(g)

Return the type of graph `g`'s edge
"""
edgetype(g::AbstractGraph{V, E}) where {V, E} = E

"""
    eltype(g)

Return the type of the graph's vertices
"""
eltype(g::AbstractGraph{V, E}) where {V, E} = V


"""
    vertices(g)

Return (an iterator to or collection of) the vertices of a graph.

### Implementation Notes
A returned iterator is valid for one pass over the edges, and
is invalidated by changes to `g`.

# Examples
```jldoctest
julia> using Graphs

julia> collect(vertices(SimpleGraph(4)))
4-element Array{Int64,1}:
 1
 2
 3
 4
```
"""
vertices(g::AbstractGraph) = _NI("vertices")

"""
    get_edges(g, u, v)

Return (an iterator to or collection of) the edges of a graph `g`
going from `u` to `v`.

### Implementation Notes
A returned iterator is valid for one pass over the edges, and
is invalidated by changes to `g`.

# Examples
```jldoctest
julia> using Graphs

julia> g = path_graph(3);

julia> collect(get_edges(g, 1, 2))
1-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
```
"""
@traitfn get_edges(g::AbstractGraph, u::V, v::V) where {V; AbstractVertex{V}} = _NI("get_edges")

"""
    edges(g)

Return (an iterator to or collection of) the edges of a graph.
For `AbstractSimpleGraph`s it returns a `SimpleEdgeIter`.
The expressions `e in edges(g)` and `e ∈ edges(ga)` evaluate as
calls to [`has_edge`](@ref).

### Implementation Notes
A returned iterator is valid for one pass over the edges, and
is invalidated by changes to `g`.

# Examples
```jldoctest
julia> using Graphs

julia> g = path_graph(3);

julia> collect(edges(g))
2-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
```
"""
edges(g::AbstractGraph) = _NI("edges")

"""
    outedges(g, u)

Return (an iterator to or collection of) the edges of a graph `g`
leaving `u`.

### Implementation Notes
A returned iterator is valid for one pass over the edges, and
is invalidated by changes to `g`.

# Examples
```jldoctest
julia> using Graphs

julia> g = path_graph(3);

julia> collect(outedges(g, 1))
1-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
```
"""
@traitfn outedges(g::AbstractGraph, v::V) where {V; AbstractVertex{V}} = _NI("outedges")

"""
    nv(g)

Return the number of vertices in `g`.

# Examples
```jldoctest
julia> using Graphs

julia> nv(SimpleGraph(3))
3
```
"""
nv(g::AbstractGraph) = length(vertices(g))

"""
    ne(g)

Return the number of edges in `g`.

# Examples
```jldoctest
julia> using Graphs

julia> g = path_graph(3);

julia> ne(g)
2
```
"""
ne(g::AbstractGraph) = length(edges(g))


"""
    is_vertex(G)

Return `true` if the graph type `V` is an AbstractVertex ; `false` otherwise.
The method can also be called with `is_vertex(v::V)`
"""
is_vertex(::V) where {V} = is_vertex(V)
is_vertex(::Type{T}) where T = _NI("is_vertex")

"""
    is_directed(G)

Return `true` if the graph type `G` is a directed graph; `false` otherwise.
New graph types must implement `is_directed(::Type{<:G})`.
The method can also be called with `is_directed(g::G)`
# Examples
```jldoctest
julia> using Graphs

julia> is_directed(SimpleGraph(2))
false

julia> is_directed(SimpleGraph)
false

julia> is_directed(SimpleDiGraph(2))
true
```
"""
is_directed(::G) where {G} = is_directed(G)
is_directed(::Type{T}) where T = _NI("is_directed")

"""
    is_range_based(G)

Return `true` if the vertex of graph type `G` forms a OneTo range; `false` otherwise.
New graph types must implement `is_range_based(::Type{<:G})`.
The method can also be called with `is_range_based(g::G)`
"""
is_range_based(::G) where {G} = is_range_based(G)
is_range_based(::Type{T}) where T = false

"""
    is_simply_mutable(G)

Return `true` if the graph type `G` is able to represent the structure
of any unweighted simple graph (with loops); `false` otherwise.
New graph types must implement `is_simply_mutable(::Type{<:G})`.
The method can also be called with `is_simply_mutable(g::G)`
"""
is_simply_mutable(::G) where {G} = is_simply_mutable(G)
is_simply_mutable(::Type{T}) where T = false

"""
    is_mutable(G)

Return `true` if the graph type `G` is able to represent the structure
of any unweighted multigraph; `false` otherwise.
New graph types must implement `is_mutable(::Type{<:G})`.
The method can also be called with `is_mutable(g::G)`
"""
is_mutable(::G) where {G} = is_mutable(G)
is_mutable(::Type{T}) where T = false

"""
    is_weight_mutable(G)

Return `true` if the graph type `G` is able to modify any of its weights
(but not necessarily able to modify its structure); `false` otherwise.
New graph types must implement `is_weight_mutable(::Type{<:G})`.
The method can also be called with `is_weight_mutable(g::G)`
"""
is_weight_mutable(::G) where {G} = is_weight_mutable(G)
is_weight_mutable(::Type{T}) where T = false

"""
    is_vertex_stable(G)

Return `true` if vertices of the graph type `G` are kept when mutating
the graph; `false` otherwise.
New graph types must implement `is_vertex_stable(::Type{<:G})`.
The method can also be called with `is_vertex_stable(g::G)`
"""
is_vertex_stable(::G) where {G} = is_vertex_stable(G)
is_vertex_stable(::Type{T}) where T = false

"""
    has_vertex(g, v)

Return true if `v` is a vertex of `g`.

# Examples
```jldoctest
julia> using Graphs

julia> has_vertex(SimpleGraph(2), 1)
true

julia> has_vertex(SimpleGraph(2), 3)
false
```
"""
has_vertex(g, v) = _NI("has_vertex")

"""
    has_edge(g, s, d)

Return true if the graph `g` has an edge from node `s` to node `d`.

An optional `has_edge(g, e)` can be implemented to check if an edge belongs
to a graph, including any data other than source and destination node.

`e ∈ edges(g)` or `e ∈ edges(g)` evaluate as
calls to `has_edge`, c.f. [`edges`](@ref).

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleDiGraph(2);

julia> add_edge!(g, 1, 2);

julia> has_edge(g, 1, 2)
true

julia> has_edge(g, 2, 1)
false
```
"""
has_edge(g, s, d) = _NI("has_edge")
has_edge(g, e) = has_edge(g, src(e), dst(e))

"""
    inneighbors(g, v)

Return a list of all neighbors connected to vertex `v` by an incoming edge.

### Implementation Notes
Returns a reference to the current graph's internal structures, not a copy.
Do not modify result. If the graph is modified, the behavior is undefined:
the array behind this reference may be modified too, but this is not guaranteed.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> inneighbors(g, 4)
2-element Array{Int64,1}:
 3
 5
```
"""
inneighbors(g, v) = _NI("inneighbors")

"""
    outneighbors(g, v)

Return a list of all neighbors connected to vertex `v` by an outgoing edge.

# Implementation Notes
Returns a reference to the current graph's internal structures, not a copy.
Do not modify result. If the graph is modified, the behavior is undefined:
the array behind this reference may be modified too, but this is not guaranteed.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> outneighbors(g, 4)
1-element Array{Int64,1}:
 5
```
"""
outneighbors(g, v) = _NI("outneighbors")

"""
    get_vertex_container(g::AbstractGraph{V, E}, K::Type)

Return a container indexed by vertices of 'g' of eltype 'K'.

# Examples
```jldoctest
julia> c = get_vertex_container(SimpleGraph(5), Int16)

julia> typeof(c)
Vector{Int16}

julia> length(c)
5
```
"""
get_vertex_container(g::AbstractGraph, K::Type) = Dict{V, K}()

"""
    get_edge_container(g::AbstractGraph{V, E}, K::Type)

Return a container indexed by edges of 'g' of eltype 'K'.
"""
get_edge_container(g::AbstractGraph, K::Type) = Dict{E, K}()

"""
    zero(G)

Return a zero-vertex, zero-edge version of the graph type `G`.
The fallback is defined for graph values `zero(g::G) = zero(G)`.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> zero(typeof(g))
{0, 0} directed simple Int64 graph

julia> zero(g)
{0, 0} directed simple Int64 graph
```
"""
zero(::Type{<:AbstractGraph}) = _NI("zero")

zero(g::G) where {G<: AbstractGraph} = zero(G)
