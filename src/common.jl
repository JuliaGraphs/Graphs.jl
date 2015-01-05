# Common facilities

typealias AttributeDict Dict{UTF8String, Any}

#################################################
#
#  vertex types
#
################################################

immutable KeyVertex{K}
    index::Int
    key::K
end

KeyVertex{K}(idx::Int, key::K) = KeyVertex{K}(idx, key)
make_vertex{V<:KeyVertex}(g::AbstractGraph{V}, key) = V(num_vertices(g) + 1, key)
vertex_index(v::KeyVertex) = v.index

type ExVertex
    index::Int
    label::UTF8String
    attributes::AttributeDict

    ExVertex(i::Int, label::String) = new(i, label, AttributeDict())
end

make_vertex(g::AbstractGraph{ExVertex}, label::String) = ExVertex(num_vertices(g) + 1, utf8(label))
vertex_index(v::ExVertex) = v.index
attributes(v::ExVertex, g::AbstractGraph) = v.attributes

typealias ProvidedVertexType Union(KeyVertex, ExVertex)

vertex_index{V<:ProvidedVertexType}(v::V, g::AbstractGraph{V}) = vertex_index(v)

function vertex_index{V}(v::V, g::AbstractGraph{V})
    @graph_requires g vertex_list
    if applicable(vertex_index, v)
        return vertex_index(v)
    end
    return vertex_index(v, vertices(g)) # slow linear search
end

vertex_index(v, vs::AbstractArray) = findfirst(vs, v)


#################################################
#
#  edge types
#
################################################

immutable Edge{V}
    index::Int
    source::V
    target::V
end
typealias IEdge Edge{Int}

Edge{V}(i::Int, s::V, t::V) = Edge{V}(i, s, t)
make_edge{V,E<:Edge}(g::AbstractGraph{V,E}, s::V, t::V) = Edge(num_edges(g) + 1, s, t)

revedge{V}(e::Edge{V}) = Edge(e.index, e.target, e.source)

edge_index(e::Edge) = e.index
source(e::Edge) = e.source
target(e::Edge) = e.target
source{V}(e::Edge{V}, g::AbstractGraph{V}) = e.source
target{V}(e::Edge{V}, g::AbstractGraph{V}) = e.target

type ExEdge{V}
    index::Int
    source::V
    target::V
    attributes::AttributeDict
end

=={V}(e1::ExEdge{V}, e2::ExEdge{V}) = (e1.index == e2.index &&
                                       e1.source == e2.source &&
                                       e1.target == e2.target)

ExEdge{V}(i::Int, s::V, t::V) = ExEdge{V}(i, s, t, AttributeDict())
ExEdge{V}(i::Int, s::V, t::V, attrs::AttributeDict) = ExEdge{V}(i, s, t, attrs)
make_edge{V}(g::AbstractGraph{V}, s::V, t::V) = ExEdge(num_edges(g) + 1, s, t)

revedge{V}(e::ExEdge{V}) = ExEdge{V}(e.index, e.target, e.source, e.attributes)

edge_index(e::ExEdge) = e.index
source(e::ExEdge) = e.source
target(e::ExEdge) = e.target
source{V}(e::ExEdge{V}, g::AbstractGraph{V}) = e.source
target{V}(e::ExEdge{V}, g::AbstractGraph{V}) = e.target
attributes(e::ExEdge, g::AbstractGraph) = e.attributes


#################################################
#
#  iteration
#
################################################

# general reindexed vector

immutable ReindexedVec{T, Vec<:AbstractVector, I<:AbstractVector{Int}}
    src::Vec
    inds::I
end

ReindexedVec{T}(a::AbstractVector{T}, inds::AbstractVector{Int}) =
    ReindexedVec{T,typeof(a),typeof(inds)}(a, inds)

length(a::ReindexedVec) = length(a.inds)
isempty(a::ReindexedVec) = isempty(a.inds)
getindex(a::ReindexedVec, i::Integer) = a.src[a.inds[i]]

start(a::ReindexedVec) = start(a.inds)
done(a::ReindexedVec, s) = done(a.inds, s)
next(a::ReindexedVec, s) = ((i, s) = next(a.inds); (a.src[i], s))

# iterating over targets

immutable TargetIterator{G<:AbstractGraph,EList}
    g::G
    lst::EList
end

TargetIterator{G<:AbstractGraph,EList}(g::G, lst::EList) =
    TargetIterator{G,EList}(g, lst)

length(a::TargetIterator) = length(a.lst)
isempty(a::TargetIterator) = isempty(a.lst)
getindex(a::TargetIterator, i::Integer) = target(a.lst[i], a.g)

start(a::TargetIterator) = start(a.lst)
done(a::TargetIterator, s) = done(a.lst, s)
next(a::TargetIterator, s::Int) = ((e, s) = next(a.lst, s); (target(e, a.g), s))

# iterating over sources

immutable SourceIterator{G<:AbstractGraph,EList}
    g::G
    lst::EList
end

SourceIterator{G<:AbstractGraph,EList}(g::G, lst::EList) =
    SourceIterator{G,EList}(g, lst)

length(a::SourceIterator) = length(a.lst)
isempty(a::SourceIterator) = isempty(a.lst)
getindex(a::SourceIterator, i::Integer) = source(a.lst[i], a.g)

start(a::SourceIterator) = start(a.lst)
done(a::SourceIterator, s) = done(a.lst, s)
next(a::SourceIterator, s::Int) = ((e, s) = next(a.lst, s); (source(e, a.g), s))

#################################################
#
#  Edge Length Visitors
#
################################################

abstract AbstractEdgePropertyInspector{T}

edge_property_requirement{T, V}(visitor::AbstractEdgePropertyInspector{T}, g::AbstractGraph{V}) = nothing

type ConstantEdgePropertyInspector{T} <: AbstractEdgePropertyInspector{T}
  value::T
end

edge_property{T}(visitor::ConstantEdgePropertyInspector{T}, e, g) = visitor.value


type VectorEdgePropertyInspector{T} <: AbstractEdgePropertyInspector{T}
  values::Vector{T}
end

edge_property{T,V}(visitor::VectorEdgePropertyInspector{T}, e, g::AbstractGraph{V}) = visitor.values[edge_index(e, g)]

edge_property_requirement{T, V}(visitor::AbstractEdgePropertyInspector{T}, g::AbstractGraph{V}) = @graph_requires g edge_map

type AttributeEdgePropertyInspector{T} <: AbstractEdgePropertyInspector{T}
  attribute::UTF8String
end

function edge_property{T}(visitor::AttributeEdgePropertyInspector{T},edge::ExEdge, g)
    convert(T,edge.attributes[visitor.attribute])
end
#################################################
#
#  convenient functions
#
################################################

isnz(x::Bool) = x
isnz(x::Number) = x != zero(x)

multivecs{T}(::Type{T}, n::Int) = [T[] for _ =1:n]

function collect_edges{V,E}(graph::AbstractGraph{V,E})
    local edge_list
    if implements_edge_list(graph)
        collect(edges(graph))

    elseif implements_vertex_list(graph) && implements_incidence_list(graph)
        edge_list = Array(E, 0)
        sizehint!(edge_list, num_edges(graph))

        for v in vertices(graph)
            for e in out_edges(v, graph)
                push!(edge_list, e)
            end
        end
        edge_list
    else
        throw(ArgumentError("graph must implement either edge_list or incidence_list."))
    end
end


immutable WeightedEdge{E,W}
    edge::E
    weight::W
end

isless{E,W}(a::WeightedEdge{E,W}, b::WeightedEdge{E,W}) = a.weight < b.weight

function collect_weighted_edges{V,E,W}(graph::AbstractGraph{V,E}, weights::AbstractEdgePropertyInspector{W})

    edge_property_requirement(weights, graph)

    wedges = Array(WeightedEdge{E,W}, 0)
    sizehint!(wedges, num_edges(graph))

    if implements_edge_list(graph)
        for e in edges(graph)
            w = edge_property(weights, e, graph)
            push!(wedges, WeightedEdge(e, w))
        end

    elseif implements_vertex_list(graph) && implements_incidence_list(graph)
        for v in vertices(graph)
            for e in out_edges(v, graph)
                w = edge_property(weights, e, graph)
                push!(wedges, WeightedEdge(e, w))
            end
        end
    else
        throw(ArgumentError("graph must implement either edge_list or incidence_list."))
    end

    return wedges
end

function collect_weighted_edges{V,E,W}(graph::AbstractGraph{V,E}, weights::AbstractVector{W})
    visitor::AbstractEdgePropertyInspector{D} = VectorEdgePropertyInspector(edge_dists)
    collect_weighted_edges(graph, visitor)
end
