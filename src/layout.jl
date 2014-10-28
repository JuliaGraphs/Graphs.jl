
# Various graph layouts.

function layout_random(g::GenericGraph, dim=2)
    # Generate random locations in unit-square.
    #
    # Each node is associated with a dim-dimensional random vector in
    # [0,1]^{dim}.
    #
    # g : graph to embed
    # dim : number of dimensions to use
    #
    # Returns: Dict keyed by vertices with positions as values.
    #
    # Ported from networkx.

    n = num_vertices(g)
    pos = rand(n, dim)

    return Dict(g.vertices, pos)
end

function layout_circular(g::GenericGraph, dim=2)
    error("Circular layout not implemented yet!")
end

function layout_shell(g::GenericGraph, dim=2)
    error("Shell layout not implemented yet!")
end

function layout_fruchterman_reingold(g::GenericGraph, dim=2)
    error("Fruchterman-Reingold layout not implemented yet!")
end

function layout_kamada_kawai(g::GenericGraph, dim=2)
    error("Kamada-Kawai layout not implemented yet!")
end

function _spectral_dense{T<:Number}(L::Matrix{T}, dim=2)
    # Helper function for spectral embedding
end

function _spectral_sparse{T<:Real}(L::CSCMatrix{T}, dim=2)
    # Helper function for spectral embedding
end

function layout_spectral(g::GenericGraph, dim=2, scale=1)
    # Use eigenvectors of graph Laplacian as coordinates of
    # nodes.
    #
    # g : graph to embed
    # dim : number of dimensions to use
    #
    # Returns: Dict keyed by vertices with positions as values.
    #
    # Notes:
    #   * Sparse eigen-solver used for large graphs.
    #
    # Based on networkx version.

    error("Spectral not done yet")

end

function layout_spectral{W}(g::GenericGraph, eweights::AbstractVector{W},
                         dim=2, scale=1)
    # Use eigenvectors of weighted graph Laplacian as coordinates of
    # nodes.
    #
    # g : graph to embed
    # dim : number of dimensions to use
    #
    # Returns: Dict keyed by vertices with positions as values.
    #
    # Notes:
    #   * Sparse eigen-solver used for large graphs.
    #
    # Based on networkx version.

    error("Weighted spectral not done yet")

end
