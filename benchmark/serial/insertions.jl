SUITE["insertions"] = BenchmarkGroup([])

let 
    n = 10_000
    SUITE["insertions"]["SG(n,e) Generation"] = @benchmarkable SimpleGraph($n, 16 * $n)
end
