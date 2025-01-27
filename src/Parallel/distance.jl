# used in shortest path calculations

function eccentricity(
    g::AbstractGraph, vs=vertices(g), distmx::AbstractMatrix{T}=weights(g)
) where {T<:Number}
    vlen = length(vs)
    eccs = SharedVector{T}(vlen)
    @sync @distributed for i in 1:vlen
        eccs[i] = maximum(Graphs.dijkstra_shortest_paths(g, vs[i], distmx).dists)
    end
    d = sdata(eccs)
    maximum(d) == typemax(T) && @warn("Infinite path length detected")
    return d
end

function eccentricity(g::AbstractGraph, distmx::AbstractMatrix)
    return eccentricity(g, vertices(g), distmx)
end

function diameter(g::AbstractGraph, distmx::AbstractMatrix=weights(g))
    return maximum(eccentricity(g, distmx))
end

function periphery(g::AbstractGraph, distmx::AbstractMatrix=weights(g))
    return Graphs.periphery(eccentricity(g, distmx))
end

function radius(g::AbstractGraph, distmx::AbstractMatrix=weights(g))
    return minimum(eccentricity(g, distmx))
end

function center(g::AbstractGraph, distmx::AbstractMatrix=weights(g))
    return Graphs.center(eccentricity(g, distmx))
end
