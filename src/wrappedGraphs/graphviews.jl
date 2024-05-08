"""
    ReverseView{G} <: ReverseView{G} where {G <: AbstractGraph}

A wrapper on a graph that reverse the direction of every edge.
"""
# @traitfn struct ReverseView{G<:AbstractGraph{T}::IsDirected} <: ReverseView{T, G}
struct ReverseView{T<:Integer,G<:AbstractGraph} <: AbstractGraph{T}
    g::G

    @traitfn ReverseView{T,G}(g::::(IsDirected)) where {T<:Integer,G<:AbstractGraph{T}} =
        new(g)
    @traitfn ReverseView{T,G}(g::::(!IsDirected)) where {T<:Integer,G<:AbstractGraph{T}} =
        "Your graph needs to be directed"
end

ReverseView(g::G) where {T<:Integer,G<:AbstractGraph{T}} = ReverseView{T,G}(g)

wrapped_graph(g::ReverseView) = g.g

Graphs.is_directed(::ReverseView{T,G}) where {T,G} = true
Graphs.is_directed(::Type{<:ReverseView{T,G}}) where {T,G} = true

Graphs.edgetype(g::ReverseView) = Graphs.edgetype(g.g)
Graphs.has_vertex(g::ReverseView, v) = Graphs.has_vertex(g.g, v)
Graphs.ne(g::ReverseView) = Graphs.ne(g.g)
Graphs.nv(g::ReverseView) = Graphs.nv(g.g)
Graphs.vertices(g::ReverseView) = Graphs.vertices(g.g)
Graphs.edges(g::ReverseView) = (reverse(e) for e in Graphs.edges(g.g))
Graphs.has_edge(g::ReverseView, s, d) = Graphs.has_edge(g.g, d, s)
Graphs.inneighbors(g::ReverseView, v) = Graphs.outneighbors(g.g, v)
Graphs.outneighbors(g::ReverseView, v) = Graphs.inneighbors(g.g, v)

"""
    UndirectedView{G} <: ReverseView{G} where {G <: AbstractGraph}

A wrapper on a graph that consider every edges as undirected.
"""
struct UndirectedView{T<:Integer,G<:AbstractGraph} <: AbstractGraph{T}
    g::G
    ne::Int
    @traitfn function UndirectedView{T,G}(
        g::::(IsDirected)
    ) where {T<:Integer,G<:AbstractGraph{T}}
        ne = count(e -> src(e) <= dst(e) || !has_edge(g, dst(e), src(e)), Graphs.edges(g))
        return new(g, ne)
    end

    @traitfn UndirectedView{T,G}(
        g::::(!IsDirected)
    ) where {T<:Integer,G<:AbstractGraph{T}} = error("Your graph need to be directed")
end

UndirectedView(g::G) where {T<:Integer,G<:AbstractGraph{T}} = UndirectedView{T,G}(g)

wrapped_graph(g::UndirectedView) = g.g

Graphs.is_directed(::UndirectedView) = false
Graphs.is_directed(::Type{<:UndirectedView}) = false

Graphs.edgetype(g::UndirectedView) = Graphs.edgetype(g.g)
Graphs.has_vertex(g::UndirectedView, v) = Graphs.has_vertex(g.g, v)
Graphs.ne(g::UndirectedView) = g.ne
Graphs.nv(g::UndirectedView) = Graphs.nv(g.g)
Graphs.vertices(g::UndirectedView) = Graphs.vertices(g.g)
function Graphs.has_edge(g::UndirectedView, s, d)
    return Graphs.has_edge(g.g, s, d) || Graphs.has_edge(g.g, d, s)
end
Graphs.inneighbors(g::UndirectedView, v) = Graphs.all_neighbors(g.g, v)
Graphs.outneighbors(g::UndirectedView, v) = Graphs.all_neighbors(g.g, v)
function Graphs.edges(g::UndirectedView)
    return (
        begin
            (u, v) = src(e), dst(e)
            if (v < u)
                (u, v) = (v, u)
            end
            Edge(u, v)
        end for
        e in Graphs.edges(g.g) if (src(e) <= dst(e) || !has_edge(g.g, dst(e), src(e)))
    )
end
