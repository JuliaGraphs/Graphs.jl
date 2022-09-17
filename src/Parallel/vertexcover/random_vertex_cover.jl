"""
    vertex_cover(g, reps, RandomVertexCover(); parallel=:threads, kw...)

Perform [`Graphs.vertex_cover(g, RandomVertexCover())`](@ref) `reps` times in parallel 
and return the solution with the fewest vertices.

### Optional Arguements
- `parallel=:threads`: If `parallel=:distributed` then the multiprocessor implementation is
used. This implementation is more efficient if `reps` is large.
"""
function vertex_cover(
    g::AbstractGraph{T}, reps::Integer, alg::RandomVertexCover;
    parallel=:threads, kw...
) where T <: Integer
    Graphs.Parallel.generate_reduce(
        g,
        (g::AbstractGraph{T})->Graphs.vertex_cover(g, alg; kw...), 
        (x::Vector{T}, y::Vector{T})->length(x)<length(y),
        reps;
        parallel=parallel
    )
end
