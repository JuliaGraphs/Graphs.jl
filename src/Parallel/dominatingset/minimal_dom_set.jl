"""
    dominating_set(g, reps, MinimalDominatingSet(); parallel=:threads, kw...)

Perform [`Graphs.dominating_set(g, MinimalDominatingSet())`](@ref) `reps` times in parallel 
and return the solution with the fewest vertices.

### Optional Arguements
- `parallel=:threads`: If `parallel=:distributed` then the multiprocessor implementation is
used. This implementation is more efficient if `reps` is large.
- If `seed >= 0`, a random generator of each process/thread is seeded with this value.
"""
function dominating_set(
    g::AbstractGraph{T}, reps::Integer, alg::MinimalDominatingSet;
    parallel=:threads, kw...
) where T <: Integer
    Graphs.Parallel.generate_reduce(
        g,
        (g::AbstractGraph{T})->Graphs.dominating_set(g, alg; kw...), 
        (x::Vector{T}, y::Vector{T})->length(x)<length(y),
        reps;
        parallel=parallel
    )
end
