"""
    community_leiden(g::AbstractGraph; resolution=1.0, beta=0.01)

Find communities in a graph using the Leiden algorithm.
This algorithm is not implemented natively in Graphs.jl.
Please load `IGraphs.jl` to use this function.
"""
function community_leiden(g::AbstractGraph; kwargs...)
    error(
        "community_leiden is not implemented natively in Graphs.jl. Please use IGraphs.jl: `community_leiden(g; kwargs...)`",
    )
end

"""
    modularity_matrix(g::AbstractGraph)

Calculate the modularity matrix of a graph.
This algorithm is not implemented natively in Graphs.jl.
Please load `IGraphs.jl` to use this function.
"""
function modularity_matrix(g::AbstractGraph; kwargs...)
    error(
        "modularity_matrix is not implemented natively in Graphs.jl. Please use IGraphs.jl: `modularity_matrix(g; kwargs...)`",
    )
end

"""
    sir_model(g::AbstractGraph, beta, gamma; no_sim=100)

Simulate a SIR (Susceptible-Infected-Recovered) model on a graph.
This algorithm is not implemented natively in Graphs.jl.
Please load `IGraphs.jl` to use this function.
"""
function sir_model(g::AbstractGraph, beta, gamma; kwargs...)
    error(
        "sir_model is not implemented natively in Graphs.jl. Please use IGraphs.jl: `sir_model(g, beta, gamma; kwargs...)`",
    )
end

"""
    layout_kamada_kawai(g::AbstractGraph)

Calculate a graph layout using the Kamada-Kawai algorithm.
This algorithm is not implemented natively in Graphs.jl.
Please load `IGraphs.jl` to use this function.
"""
function layout_kamada_kawai(g::AbstractGraph; kwargs...)
    error(
        "layout_kamada_kawai is not implemented natively in Graphs.jl. Please use IGraphs.jl: `layout_kamada_kawai(g; kwargs...)`",
    )
end

"""
    layout_fruchterman_reingold(g::AbstractGraph)

Calculate a graph layout using the Fruchterman-Reingold algorithm.
This algorithm is not implemented natively in Graphs.jl.
Please load `IGraphs.jl` to use this function.
"""
function layout_fruchterman_reingold(g::AbstractGraph; kwargs...)
    error(
        "layout_fruchterman_reingold is not implemented natively in Graphs.jl. Please use IGraphs.jl: `layout_fruchterman_reingold(g; kwargs...)`",
    )
end
