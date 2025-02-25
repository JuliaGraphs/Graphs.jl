module NautyGraphsExt

using Graphs, NautyGraphs
using Graphs.Experimental: AlgNautyGraphs

function Graphs.Experimental.has_induced_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    ::AlgNautyGraphs;
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Bool
    error(
        "Induced subgraph isomorphims are currently not supported by `NautyGraphs`. Please use a different isomorphism algorithm.",
    )
    return nothing
end

function Graphs.Experimental.has_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    ::AlgNautyGraphs;
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Bool
    error(
        "Subgraph isomorphims are currently not supported by `NautyGraphs`. Please use a different isomorphism algorithm.",
    )
    return nothing
end

function Graphs.Experimental.has_isomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    ::AlgNautyGraphs;
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Bool
    if !isnothing(edge_relation)
        error(
            "Edge relations are currently not supported by `NautyGraphs`. Please use a different isomorphism algorithm.",
        )
    end
    if !isnothing(vertex_relation)
        error(
            "Vertex relations are currently not supported by `NautyGraphs`. Please use a different isomorphism algorithm.",
        )
    end
    return NautyGraph(g1) ≃ NautyGraph(g2)
end

function Graphs.Experimental.canonize!(g::AbstractGraph, ::AlgNautyGraphs)
    ng = is_directed(g) ? NautyDiGraph(g) : NautyGraph(g)
    perm = convert(Vector{eltype(g)}, NautyGraphs.canonical_permutation(ng))
    permute!(g, perm)
    return perm
end

function Graphs.Experimental.count_induced_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    ::AlgNautyGraphs;
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Int
    error(
        "Counting induced subgraph isomorphims is currently not supported by `NautyGraphs`. Please use a different isomorphism algorithm.",
    )
    return nothing
end

function Graphs.Experimental.count_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    ::AlgNautyGraphs;
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Int
    error(
        "Counting subgraph isomorphims is currently not supported by `NautyGraphs`. Please use a different isomorphism algorithm.",
    )
    return nothing
end

function Graphs.Experimental.count_isomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    ::AlgNautyGraphs;
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Int
    error(
        "Counting isomorphims is currently not supported by `NautyGraphs`. Please use a different isomorphism algorithm.",
    )
    return nothing
end

function Graphs.Experimental.all_induced_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    ::AlgNautyGraphs;
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}
    error(
        "Generating all induced subgraph isomorphims is currently not supported by `NautyGraphs`. Please use a different isomorphism algorithm.",
    )
    return nothing
end

function Graphs.Experimental.all_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    ::AlgNautyGraphs;
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}
    error(
        "Generating all subgraph isomorphims is currently not supported by `NautyGraphs`. Please use a different isomorphism algorithm.",
    )
    return nothing
end

function Graphs.Experimental.all_isomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    ::AlgNautyGraphs;
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}
    error(
        "Generating all isomorphims is currently not supported by `NautyGraphs`. Please use a different isomorphism algorithm.",
    )
    return nothing
end

end