"""
    IGraphAlgorithm <: AbstractGraphAlgorithm

A trait to specify that an algorithm is implemented via the `IGraphs.jl` package.
"""
struct IGraphAlgorithm <: AbstractGraphAlgorithm end

# This list will hold functions that are defined in Graphs.jl but require
# IGraphs.jl for their implementation.
const _IGRAPH_REQUIRED_FUNCTIONS = Function[]

macro igraph_declare(name, doc)
    return quote
        @doc $doc
        function $(esc(name)) end
        push!(_IGRAPH_REQUIRED_FUNCTIONS, $(esc(name)))
    end
end

@igraph_declare sir_model """
    sir_model(g, beta, gamma, no_steps)

Simulate an SIR (Susceptible-Infected-Recovered) model on graph `g`.
This function requires the `IGraphs.jl` package to be loaded.
"""

@igraph_declare layout_kamada_kawai """
    layout_kamada_kawai(g)

Calculate the Kamada-Kawai layout for graph `g`.
This function requires the `IGraphs.jl` package to be loaded.
"""

@igraph_declare layout_fruchterman_reingold """
    layout_fruchterman_reingold(g)

Calculate the Fruchterman-Reingold layout for graph `g`.
This function requires the `IGraphs.jl` package to be loaded.
"""

@igraph_declare community_leiden """
    community_leiden(g)

Calculate communities in graph `g` using the Leiden algorithm.
This function requires the `IGraphs.jl` package to be loaded.
"""

@igraph_declare modularity_matrix """
    modularity_matrix(g)

Calculate the modularity matrix for graph `g`.
This function requires the `IGraphs.jl` package to be loaded.
"""

# --- Conversion and Interface Support ---

"""
    AbstractIGraph{T} <: AbstractGraph{T}

Abstract type for graphs that are backed by the `igraph` C library.
Implementations should live in `IGraphs.jl`.
"""
abstract type AbstractIGraph{T} <: AbstractGraph{T} end

"""
    igraph(g::AbstractGraph)

Convert a `Graphs.jl` graph to an `igraph` representation.
The specific implementation should be provided by `IGraphs.jl`.
"""
function igraph end

# --- Dispatch Overrides for Existing Algorithms ---

"""
    betweenness_centrality(g, ::IGraphAlgorithm; kwargs...)

Dispatch `betweenness_centrality` to the `igraph` implementation.
This requires `IGraphs.jl` to be loaded.
"""
function betweenness_centrality end

"""
    pagerank(g, ::IGraphAlgorithm; kwargs...)

Dispatch `pagerank` to the `igraph` implementation.
This requires `IGraphs.jl` to be loaded.
"""
function pagerank end
