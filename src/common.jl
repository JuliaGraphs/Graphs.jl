# Common facilities

#typealias
const AttributeDict = Dict{String, Any}

#################################################
#
#  vertex types
#
################################################

struct KeyVertex{K}
    index::Int
    key::K
    KeyVertex(idx::Int, key::K) where {K} = new{K}(idx, key)
    KeyVertex{K}(idx::Int, key::K) where {K} = new{K}(idx, key)
end

# KeyVertex{K}(idx::Int, key::K) = KeyVertex{K}(idx, key)
make_vertex(g::AbstractGraph{V}, key) where {V<:KeyVertex} = V(num_vertices(g) + 1, key)
vertex_index(v::KeyVertex) = v.index

mutable struct ExVertex
    index::Int
    label::String
    attributes::AttributeDict

    ExVertex(i::Int, label::AbstractString) = new(i, label, AttributeDict())
end

make_vertex(g::AbstractGraph{ExVertex}, label::AbstractString) = ExVertex(num_vertices(g) + 1, String(label))
vertex_index(v::ExVertex) = v.index
attributes(v::ExVertex, g::AbstractGraph) = v.attributes

const ProvidedVertexType = Union{KeyVertex, ExVertex}

vertex_index(v::V, g::AbstractGraph{V}) where {V<:ProvidedVertexType} = vertex_index(v)

function vertex_index(v::V, g::AbstractGraph{V}) where {V}
    @graph_requires g vertex_list
    if applicable(vertex_index, v)
        return vertex_index(v)
    end
    return vertex_index(v, vertices(g)) # slow linear search
end

vertex_index(v, vs::AA) where {AA <: AbstractArray} = something(findfirst(isequal(v), vs), 0) # findfirst(vs, v)


#################################################
#
#  edge types
#
################################################

struct Edge{V}
    index::Int
    source::V
    target::V
    Edge(i::Int, s::V, t::V) where {V} = new{V}(i, s, t)
end
const IEdge = Edge{Int}

# Edge{V}(i::Int, s::V, t::V) = Edge{V}(i, s, t)
make_edge(g::AbstractGraph{V,E}, s::V, t::V) where {V,E<:Edge} = Edge(num_edges(g) + 1, s, t)

revedge(e::Edge{V}) where {V} = Edge(e.index, e.target, e.source)

edge_index(e::Edge) = e.index
source(e::Edge) = e.source
target(e::Edge) = e.target
source(e::Edge{V}, g::AbstractGraph{V}) where {V} = e.source
target(e::Edge{V}, g::AbstractGraph{V}) where {V} = e.target


mutable struct ExEdge{V}
    index::Int
    source::V
    target::V
    attributes::AttributeDict
    ExEdge(i::Int, s::V, t::V) where {V} = new{V}(i, s, t, AttributeDict())
    ExEdge(i::Int, s::V, t::V, attrs::AttributeDict) where {V} = new{V}(i, s, t, attrs)
    ExEdge{V}(i::Int, s::V, t::V) where {V} = new{V}(i, s, t, AttributeDict())
    ExEdge{V}(i::Int, s::V, t::V, attrs::AttributeDict) where {V} = new{V}(i, s, t, attrs)
end

==(e1::ExEdge{V}, e2::ExEdge{V}) where {V} = (e1.index == e2.index &&
                                       e1.source == e2.source &&
                                       e1.target == e2.target)

# ExEdge{V}(i::Int, s::V, t::V) = ExEdge{V}(i, s, t, AttributeDict())
# ExEdge{V}(i::Int, s::V, t::V, attrs::AttributeDict) = ExEdge{V}(i, s, t, attrs)
make_edge(g::AbstractGraph{V}, s::V, t::V) where {V} = ExEdge(num_edges(g) + 1, s, t)

revedge(e::ExEdge{V}) where {V} = ExEdge{V}(e.index, e.target, e.source, e.attributes)

edge_index(e::ExEdge) = e.index
source(e::ExEdge) = e.source
target(e::ExEdge) = e.target
source(e::ExEdge{V}, g::AbstractGraph{V}) where {V} = e.source
target(e::ExEdge{V}, g::AbstractGraph{V}) where {V} = e.target
attributes(e::ExEdge, g::AbstractGraph) = e.attributes


#################################################
#
#  iteration
#
################################################

# general reindexed vector

struct ReindexedVec{T, Vec<:AbstractVector, I<:AbstractVector{Int}}
    src::Vec
    inds::I
    ReindexedVec(a::AT, inds::I) where {T, AT <: AbstractVector{T}, I <: AbstractVector{Int}} =
        new{T,typeof(a),typeof(inds)}(a, inds)
    ReindexedVec{T}(a::AT, inds::I) where {T, AT <: AbstractVector{T}, I <: AbstractVector{Int}} =
        new{T,typeof(a),typeof(inds)}(a, inds)
end

# ReindexedVec{T}(a::AbstractVector{T}, inds::AbstractVector{Int}) =
#     ReindexedVec{T,typeof(a),typeof(inds)}(a, inds)

length(a::ReindexedVec) = length(a.inds)
isempty(a::ReindexedVec) = isempty(a.inds)
getindex(a::ReindexedVec, i::Integer) = a.src[a.inds[i]]

# start(a::ReindexedVec) = start(a.inds)
# done(a::ReindexedVec, s) = done(a.inds, s)
# next(a::ReindexedVec, s) = ((i, s) = next(a.inds); (a.src[i], s))


# iterating over targets

struct TargetIterator{G<:AbstractGraph,EList}
    g::G
    lst::EList
    TargetIterator(g::G, lst::EList) where {G<:AbstractGraph,EList} = new{G,EList}(g, lst)
    TargetIterator{G,EList}(g::G, lst::EList) where {G<:AbstractGraph,EList} = new{G,EList}(g, lst)
end

# TargetIterator{G<:AbstractGraph,EList}(g::G, lst::EList) =
#     TargetIterator{G,EList}(g, lst)

Base.length(a::TargetIterator) = length(a.lst)
isempty(a::TargetIterator) = isempty(a.lst)
getindex(a::TargetIterator, i::Integer) = target(a.lst[i], a.g)

# start(a::TargetIterator) = start(a.lst)
# done(a::TargetIterator, s) = done(a.lst, s)
# next(a::TargetIterator, s::Int) = ((e, s) = next(a.lst, s); (target(e, a.g), s)) # likely deprecated

# Base.length(iter::TargetIterator) = length(iter.lst)
# Base.eltype(iter::TargetIterator) = ??
function Base.iterate(it::TargetIterator, (el, i)=(0, 0))
	return i >= length(it) ? nothing : (target(it.lst[i+1], it.g), (target(it.lst[i+1], it.g), i + 1))
end

# iterating over sources

struct SourceIterator{G<:AbstractGraph,EList}
    g::G
    lst::EList
    SourceIterator(g::G, lst::EList) where {G<:AbstractGraph,EList} =
        new{G,EList}(g, lst)
    SourceIterator{G,EList}(g::G, lst::EList) where {G<:AbstractGraph,EList} =
        new{G,EList}(g, lst)
end

# SourceIterator{G<:AbstractGraph,EList}(g::G, lst::EList) =
#     SourceIterator{G,EList}(g, lst)

length(a::SourceIterator) = length(a.lst)
isempty(a::SourceIterator) = isempty(a.lst)
getindex(a::SourceIterator, i::Integer) = source(a.lst[i], a.g)

# start(a::SourceIterator) = start(a.lst)
# done(a::SourceIterator, s) = done(a.lst, s)
# next(a::SourceIterator, s::Int) = ((e, s) = next(a.lst, s); (source(e, a.g), s))


# Base.length(iter::SourceIterator) = length(iter.lst)
# Base.eltype(iter::SourceIterator) = ??
function Base.iterate(it::SourceIterator, (el, i)=(0, 0))
  return i >= length(it) ? nothing : (source(it.lst[i+1], it.g), (source(it.lst[i+1], it.g), i + 1))
end

#################################################
#
#  Edge Length Visitors
#
################################################

abstract type AbstractEdgePropertyInspector{T} end

# edge_property_requirement{T, V}(visitor::AbstractEdgePropertyInspector{T}, g::AbstractGraph{V}) = nothing

mutable struct ConstantEdgePropertyInspector{T} <: AbstractEdgePropertyInspector{T}
  value::T
end

edge_property(visitor::ConstantEdgePropertyInspector{T}, e, g) where {T} = visitor.value


mutable struct VectorEdgePropertyInspector{T} <: AbstractEdgePropertyInspector{T}
  values::Vector{T}
end

edge_property(visitor::VectorEdgePropertyInspector{T}, e, g::AbstractGraph{V}) where {T,V} = visitor.values[edge_index(e, g)]

edge_property_requirement(visitor::AbstractEdgePropertyInspector{T}, g::AbstractGraph{V}) where {T, V} = @graph_requires g edge_map

mutable struct AttributeEdgePropertyInspector{T} <: AbstractEdgePropertyInspector{T}
  attribute::String
end

function edge_property(visitor::AttributeEdgePropertyInspector{T},edge::ExEdge, g) where {T}
    convert(T,edge.attributes[visitor.attribute])
end
#################################################
#
#  convenient functions
#
################################################

isnz(x::Bool) = x
isnz(x::Number) = x != zero(x)

intrange(n::Integer) = 1:convert(Int,n)

multivecs(::Type{T}, n::Int) where {T} = [T[] for _ =1:n]

function collect_edges(graph::AbstractGraph{V,E}) where {V,E}
    local edge_list
    if implements_edge_list(graph)
        collect(edges(graph))

    elseif implements_vertex_list(graph) && implements_incidence_list(graph)
        edge_list = Array{E}(undef, 0)
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


struct WeightedEdge{E,W}
    edge::E
    weight::W
end

isless(a::WeightedEdge{E,W}, b::WeightedEdge{E,W}) where {E,W} = a.weight < b.weight

function collect_weighted_edges(graph::AbstractGraph{V,E}, weights::AbstractEdgePropertyInspector{W}) where {V,E,W}

    edge_property_requirement(weights, graph)

    wedges = Array{WeightedEdge{E,W}}(undef, 0)
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

function collect_weighted_edges(graph::AbstractGraph{V,E}, weights::AbstractVector{W}) where {V,E,W}
    visitor::AbstractEdgePropertyInspector{D} = VectorEdgePropertyInspector(edge_dists)
    collect_weighted_edges(graph, visitor)
end
