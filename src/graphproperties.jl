"""
    graph_property(graph::AbstractGraph, property_specification::GraphProperty{T}, [options = nothing])::Union{Nothing,Some{<:T}}

Get the graph property specified by `property_specification` of the graph `graph`.

Only some properties are implemented currently.

A `nothing` return value may be returned in some cases, such as when a time limit specified in `options` was reached.

Third-party packages may add methods. Only add three-argument methods, and only if you own the third argument, `options`.
"""
function graph_property end

function graph_property(graph::AbstractGraph, prop_spec::GraphProperty)
    return graph_property(graph, prop_spec, nothing)
end

function graph_property(graph::AbstractGraph, ::GraphProperties.NumberOfVertices, ::Nothing)
    return Some(nv(graph))
end

function graph_property(graph::AbstractGraph, ::GraphProperties.DegreeSequence, ::Nothing)
    if is_directed(graph)
        throw(ArgumentError("expected undirected graph"))
    end
    return Some(sort(degree(graph)))
end

function graph_property(graph::AbstractGraph, ::GraphProperties.NumberOfEdges, ::Nothing)
    if is_directed(graph)
        throw(ArgumentError("expected undirected graph"))
    end
    return Some(ne(graph))
end

function graph_property(graph::AbstractGraph, ::GraphProperties.NumberOfArcs, ::Nothing)
    if !is_directed(graph)
        throw(ArgumentError("expected directed graph"))
    end
    return Some(ne(graph))
end

function graph_property(
    graph::AbstractGraph, ::GraphProperties.NumberOfConnectedComponents, ::Nothing
)
    if is_directed(graph)
        throw(ArgumentError("expected undirected graph"))
    end
    # TODO: performance: avoid allocating the components
    return Some(length(connected_components(graph)))
end

function graph_property(
    graph::AbstractGraph, ::GraphProperties.NumberOfWeaklyConnectedComponents, ::Nothing
)
    if !is_directed(graph)
        throw(ArgumentError("expected directed graph"))
    end
    # TODO: performance: avoid allocating the components
    return Some(length(weakly_connected_components(graph)))
end

function graph_property(
    graph::AbstractGraph, ::GraphProperties.NumberOfStronglyConnectedComponents, ::Nothing
)
    if !is_directed(graph)
        throw(ArgumentError("expected directed graph"))
    end
    # TODO: performance: avoid allocating the components
    return Some(length(strongly_connected_components(graph)))
end
