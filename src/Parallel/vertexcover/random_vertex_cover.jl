"""
    vertex_cover(g, reps, RandomVertexCover(); parallel=:threads, rng=nothing, seed=nothing)

Perform [`Graphs.vertex_cover(g, RandomVertexCover())`](@ref) `reps` times in parallel 
and return the solution with the fewest vertices.

### Optional Arguements
- `parallel=:threads`: If `parallel=:distributed` then the multiprocessor implementation is
used. This implementation is more efficient if `reps` is large.
"""
function vertex_cover(
    g::AbstractGraph{T}, reps::Integer, alg::RandomVertexCover;
    parallel=:threads, rng::Union{Nothing, AbstractRNG}=nothing, seed::Union{Nothing, Integer}=nothing
) where T <: Integer
    Graphs.Parallel.generate_reduce(
        g,
        (g::AbstractGraph{T})->Graphs.vertex_cover(g, alg; rng=rng, seed=seed), 
        (x::Vector{T}, y::Vector{T})->length(x)<length(y),
        reps;
        parallel=parallel
    )
end
