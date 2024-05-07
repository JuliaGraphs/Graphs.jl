"""
    ReverseView{G} <: AbstractWrappedGraph{G} where {G <: AbstractGraph}

A wrapper on a graph that reverse the direction of every edge.
"""
# @traitfn struct ReverseView{G<:AbstractGraph{T}::IsDirected} <: AbstractWrappedGraph{T, G}
struct ReverseView{T<:Integer, G<:AbstractGraph} <: AbstractWrappedGraph{T, G}
    g::G
end

ReverseView(g::G) where {T<:Integer, G<:AbstractGraph{T}} = ReverseView{T, G}(g)

Graphs.wrapped_graph(g::ReverseView) = g.g

Graphs.edges(g::ReverseView) = (reverse(e) for e in Graphs.edges(wrapped_graph(g)))

Graphs.has_edge(g::ReverseView, s, d) = Graphs.has_edge(wrapped_graph(g), d, s)

Graphs.inneighbors(g::ReverseView, v) = Graphs.outneighbors(wrapped_graph(g), v)

Graphs.outneighbors(g::ReverseView, v) = Graphs.inneighbors(wrapped_graph(g), v)

"""
    UndirectedView{G} <: AbstractWrappedGraph{G} where {G <: AbstractGraph}

A wrapper on a graph that consider every edges as undirected.
"""
struct UndirectedView{T<:Integer, G<:AbstractGraph} <: AbstractWrappedGraph{T, G}
    g::G
end

UndirectedView(g::G) where {T<:Integer, G<:AbstractGraph{T}} = UndirectedView{T, G}(g)

Graphs.wrapped_graph(g::UndirectedView) = g.g

Graphs.edges(g::UndirectedView) = (
    begin 
        (u, v) = src(e), dst(e);
        if (v < u)
            (u, v) = (v, u)
        end;
        Edge(u, v)
    end
    for e in Graphs.edges(wrapped_graph(g)) 
    if (src(e) <= dst(e) || !has_edge(g, dst(e), src(e)))
)

Graphs.is_directed(::UndirectedView) = false
Graphs.is_directed(::Type{<:UndirectedView}) = false

Graphs.has_edge(g::UndirectedView, s, d) = Graphs.has_edge(wrapped_graph(g), s, d) || Graphs.has_edge(wrapped_graph(g), d, s)

Graphs.inneighbors(g::UndirectedView, v) = Graphs.all_neighbors(wrapped_graph(g), v)

Graphs.outneighbors(g::UndirectedView, v) = Graphs.all_neighbors(wrapped_graph(g), v)








