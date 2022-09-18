"""
    independent_set(g, reps, MaximalIndependentSet(); parallel=:threads, rng=nothing, seed=nothing)

Perform [`Graphs.independent_set(g, MaximalIndependentSet())`](@ref) `reps` times in parallel 
and return the solution with the most vertices.

### Optional Arguements
- `parallel=:threads`: If `parallel=:distributed` then the multiprocessor implementation is
used. This implementation is more efficient if `reps` is large.
"""
function independent_set(
    g::AbstractGraph{T}, reps::Integer, alg::MaximalIndependentSet;
    parallel=:threads, rng::Union{Nothing, AbstractRNG}=nothing, seed::Union{Nothing, Integer}=nothing
) where T <: Integer
    Graphs.Parallel.generate_reduce(
        g,
        (g::AbstractGraph{T})->Graphs.independent_set(g, alg; rng=rng, seed=seed), 
        (x::Vector{T}, y::Vector{T})->length(x)>length(y),
        reps;
        parallel=parallel
    )
end
