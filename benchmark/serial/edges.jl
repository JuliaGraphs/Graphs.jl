import Base: convert

const P = Pair{Int,Int}

convert(::Type{Tuple}, e::Pair) = (e.first, e.second)

function fille(n)
    return [Graphs.Edge(i, i + 1) for i in 1:n]
end

function fillp(n)
    t = Vector{P}(undef, n)
    for i in 1:n
        t[i] = P(i, i + 1)
    end
    return t
end

function tsum(t)
    x = 0
    for item in t
        u, v = Tuple(item)
        x += u
        x += v
    end
    return x
end

let
    n = 10_000

    SUITE["edges"] = BenchmarkGroup([])
    SUITE["edges"]["fille"] = @benchmarkable fille($n)
    SUITE["edges"]["fillp"] = @benchmarkable fille($n)

    a, b = fille(n), fillp(n)

    SUITE["edges"]["tsume"] = @benchmarkable tsum($a)
    SUITE["edges"]["tsump"] = @benchmarkable tsum($b)
end
