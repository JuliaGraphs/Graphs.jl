# used in shortest path calculations

function eccentricity(
    g::AbstractGraph,
    vs=vertices(g),
    distmx::AbstractMatrix{T}=weights(g);
    parallel::Symbol=:threads,
) where {T<:Number}
    return if parallel === :threads
        threaded_eccentricity(g, vs, distmx)
    elseif parallel === :distributed
        distr_eccentricity(g, vs, distmx)
    else
        throw(
            ArgumentError(
                "Unsupported parallel argument '$(repr(parallel))' (supported: ':threads' or ':distributed')",
            ),
        )
    end
end

function distr_eccentricity(args...; kwargs...)
    return error(
        "`parallel = :distributed` requested, but SharedArrays or Distributed is not loaded"
    )
end

function threaded_eccentricity(
    g::AbstractGraph, vs=vertices(g), distmx::AbstractMatrix{T}=weights(g)
) where {T<:Number}
    vlen = length(vs)
    eccs = Vector{T}(undef, vlen)
    Base.Threads.@threads for i in 1:vlen
        d = Graphs.dijkstra_shortest_paths(g, vs[i], distmx)
        eccs[i] = maximum(d.dists)
    end
    maximum(eccs) == typemax(T) && @warn("Infinite path length detected")
    return eccs
end

function eccentricity(g::AbstractGraph, distmx::AbstractMatrix; parallel::Symbol=:threads)
    return eccentricity(g, vertices(g), distmx; parallel)
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
