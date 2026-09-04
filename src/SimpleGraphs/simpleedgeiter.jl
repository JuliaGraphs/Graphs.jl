"""
    SimpleEdgeIter

The function [`edges`](@ref) returns a `SimpleEdgeIter` for `AbstractSimpleGraph`s.
The iterates are in lexicographical order, smallest first. The iterator is valid for
one pass over the edges, and is invalidated by changes to the graph.

# Examples
```jldoctest
julia> using Graphs

julia> g = path_graph(3);

julia> es = edges(g)
SimpleEdgeIter 2

julia> e_it = iterate(es)
(Edge 1 => 2, (1, 2))

julia> iterate(es, e_it[2])
(Edge 2 => 3, (2, 3))
```
"""
struct SimpleEdgeIter{G} <: AbstractEdgeIter
    g::G
end

eltype(::Type{SimpleEdgeIter{SimpleGraph{T}}}) where {T} = SimpleGraphEdge{T}
eltype(::Type{SimpleEdgeIter{SimpleDiGraph{T}}}) where {T} = SimpleDiGraphEdge{T}

@traitfn @inline function iterate(
    eit::SimpleEdgeIter{G}, state=(one(eltype(eit.g)), 1)
) where {G<:AbstractSimpleGraph;!IsDirected{G}}
    g = eit.g
    T = eltype(g)
    n = T(nv(g))
    u, i = state

    @inbounds while u < n
        list_u = fadj(g, u)
        if i > length(list_u)
            u += one(u)
            i = searchsortedfirst(fadj(g, u), u)
            continue
        end
        e = SimpleEdge(u, list_u[i])
        state = (u, i + 1)
        return e, state
    end

    @inbounds (n == 0 || i > length(fadj(g, n))) && return nothing

    e = SimpleEdge(n, n)
    state = (u, i + 1)
    return e, state
end

@traitfn @inline function iterate(
    eit::SimpleEdgeIter{G}, state=(one(eltype(eit.g)), 1)
) where {G<:AbstractSimpleGraph;IsDirected{G}}
    g = eit.g
    T = eltype(g)
    n = T(nv(g))
    u, i = state

    n == 0 && return nothing

    @inbounds while true
        list_u = fadj(g, u)
        if i > length(list_u)
            u == n && return nothing

            u += one(u)
            list_u = fadj(g, u)
            i = 1
            continue
        end
        e = SimpleEdge(u, list_u[i])
        state = (u, i + 1)
        return e, state
    end

    return nothing
end

length(eit::SimpleEdgeIter) = ne(eit.g)

function _isequal(e1::SimpleEdgeIter, e2)
    k = 0
    for e in e2
        has_edge(e1.g, e) || return false
        k += 1
    end
    return k == ne(e1.g)
end
==(e1::SimpleEdgeIter, e2::AbstractVector{SimpleEdge}) = _isequal(e1, e2)
==(e1::AbstractVector{SimpleEdge}, e2::SimpleEdgeIter) = _isequal(e2, e1)
==(e1::SimpleEdgeIter, e2::Set{SimpleEdge}) = _isequal(e1, e2)
==(e1::Set{SimpleEdge}, e2::SimpleEdgeIter) = _isequal(e2, e1)

function ==(e1::SimpleEdgeIter, e2::SimpleEdgeIter)
    g = e1.g
    h = e2.g
    ne(g) == ne(h) || return false
    m = min(nv(g), nv(h))
    for i in 1:m
        fadj(g, i) == fadj(h, i) || return false
    end
    nv(g) == nv(h) && return true
    for i in (m + 1):nv(g)
        isempty(fadj(g, i)) || return false
    end
    for i in (m + 1):nv(h)
        isempty(fadj(h, i)) || return false
    end
    return true
end

Base.isequal(e1::SimpleEdgeIter, e2::SimpleEdgeIter) = e1 == e2
# set `isequal`s to false to ensure the hash-isequal contract is fulfilled
Base.isequal(::SimpleEdgeIter, ::AbstractVector{SimpleEdge}) = false
Base.isequal(::AbstractVector{SimpleEdge}, ::SimpleEdgeIter) = false
Base.isequal(::SimpleEdgeIter, ::Set{SimpleEdge}) = false
Base.isequal(::Set{SimpleEdge}, ::SimpleEdgeIter) = false

function Base.hash(eit::SimpleEdgeIter, h::UInt)
    lists = fadj(eit.g)
    n = something(findlast(!isempty, lists), 0)
    h = hash(ne(eit.g), h)
    h = hash(n, h)
    # Sample about log(n) adjacency lists, working backwards with Fibonacci skips
    i = n
    skip = prevskip = 1
    while i >= 1
        list = lists[i]
        h = hash(length(list), h)
        isempty(list) || (h = hash(first(list), hash(last(list), h)))
        i -= skip
        skip, prevskip = skip + prevskip, skip
    end
    return h
end

in(e, es::SimpleEdgeIter) = has_edge(es.g, e)

show(io::IO, eit::SimpleEdgeIter) = write(io, "SimpleEdgeIter $(ne(eit.g))")
