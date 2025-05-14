function random_greedy_color(
    g::AbstractGraph{T}, reps::Integer; parallel=:threads
) where {T<:Integer}
    return if parallel === :threads
        threaded_random_greedy_color(g, reps)
    elseif parallel === :distributed
        distr_random_greedy_color(g, reps)
    else
        error(
            "Unsupported parallel argument '$(repr(parallel))' (supported: ':threads' or ':distributed')",
        )
    end
end

function threaded_random_greedy_color(g::AbstractGraph{T}, reps::Integer) where {T<:Integer}
    local_best = Any[nothing for _ in 1:reps]
    Base.Threads.@threads for i in 1:reps
        seq = shuffle(vertices(g))
        local_best[i] = Graphs.perm_greedy_color(g, seq)
    end
    best = reduce(Graphs.best_color, local_best)

    return convert(Graphs.Coloring{T}, best)
end

function distr_random_greedy_color(args...; kwargs...)
    return error(
        "`parallel = :distributed` requested, but SharedArrays or Distributed is not loaded"
    )
end

function greedy_color(
    g::AbstractGraph{U}; sort_degree::Bool=false, reps::Integer=1, parallel=:threads
) where {U<:Integer}
    return if sort_degree
        Graphs.degree_greedy_color(g)
    else
        Parallel.random_greedy_color(g, reps; parallel)
    end
end
