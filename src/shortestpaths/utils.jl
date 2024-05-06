function path_from_parents(target::Integer, parents::AbstractVector)
    v = target
    path = [v]
    while parents[v] != v && parents[v] != zero(v)
        v = parents[v]
        pushfirst!(path, v)
    end
    return path
end
