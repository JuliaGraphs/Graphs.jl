function random_greedy_color(g::AbstractGraph{T}, reps::Integer) where {T <: Integer}
    best = @distributed (Graphs.best_color) for i in 1:reps
        seq = shuffle(vertices(g))
        Graphs.perm_greedy_color(g, seq)
    end

    return convert(Graphs.Coloring{T}, best)
end

greedy_color(g::AbstractGraph{U}; sort_degree::Bool=false, reps::Integer=1) where {U <: Integer} =
    sort_degree ? Graphs.degree_greedy_color(g) : Parallel.random_greedy_color(g, reps)
