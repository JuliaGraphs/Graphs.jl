"""
    generate_reduce(g, gen_func, comp, reps; parallel=:threads)

Compute `gen_func(g)` `reps` times and return the instance `best` for which
`comp(best, v)` is true where `v` is all the other instances of `gen_func(g)`.

For example, `comp(x, y) = length(x) < length(y) ? x : y` then instance with the smallest
length will be returned.
"""
function generate_reduce(
    g::AbstractGraph{T}, gen_func::Function, comp::Comp, reps::Integer; parallel=:threads
) where {T<:Integer,Comp}
    return if parallel == :threads
        threaded_generate_reduce(g, gen_func, comp, reps)
    else
        distr_generate_reduce(g, gen_func, comp, reps)
    end
end

"""
    distr_generate_min_set(g, gen_func, comp, reps)

Distributed implementation of [`generate_reduce`](@ref).
"""
function distr_generate_reduce(
    g::AbstractGraph{T}, gen_func::Function, comp::Comp, reps::Integer
) where {T<:Integer,Comp}
    # Type assert required for type stability
    min_set::Vector{T} = @distributed ((x, y) -> comp(x, y) ? x : y) for _ in 1:reps
        gen_func(g)
    end
    return min_set
end

"""
    threaded_generate_reduce(g, gen_func, comp reps)

Multi-threaded implementation of [`generate_reduce`](@ref).
"""
function threaded_generate_reduce(
    g::AbstractGraph{T}, gen_func::Function, comp::Comp, reps::Integer
) where {T<:Integer,Comp}
    d, r = divrem(reps, Threads.nthreads())
    ntasks = d == 0 ? r : Threads.nthreads()
    min_set = [Vector{T}() for _ in 1:ntasks]
    is_undef = ones(Bool, ntasks)
    task_size = cld(reps, ntasks)

    @sync for (t, task_range) in enumerate(Iterators.partition(1:reps, task_size))
        Threads.@spawn for _ in task_range
            next_set = gen_func(g)
            if is_undef[t] || comp(next_set, min_set[t])
                min_set[t] = next_set
                is_undef[t] = false
            end
        end
    end

    min_ind = 0
    for i in filter((j) -> !is_undef[j], 1:ntasks)
        if min_ind == 0 || comp(min_set[i], min_set[min_ind])
            min_ind = i
        end
    end

    return min_set[min_ind]
end
