SUITE["distance"] = BenchmarkGroup()

let
    n_bench = 300

    symmetric_weights(n) = (W=rand(n, n); (W + W') / 2)

    # Erdős-Rényi Setup
    p = 10 / n_bench
    g_er = erdos_renyi(n_bench, p)
    while !is_connected(g_er)
        g_er = erdos_renyi(n_bench, p)
    end
    distmx_er = symmetric_weights(n_bench)

    # Barabási-Albert Setup
    g_ba = barabasi_albert(n_bench, 5)
    while !is_connected(g_ba)
        g_ba = barabasi_albert(n_bench, 5)
    end
    distmx_ba = symmetric_weights(n_bench)

    SUITE["distance"]["weighted_diameter"] = BenchmarkGroup()

    # Erdős-Rényi
    SUITE["distance"]["weighted_diameter"]["erdos_renyi_optimized"] = @benchmarkable diameter(
        $g_er, $distmx_er
    )

    SUITE["distance"]["weighted_diameter"]["erdos_renyi_naive"] = @benchmarkable maximum(
        eccentricity($g_er, vertices($g_er), $distmx_er)
    )

    # Barabási-Albert
    SUITE["distance"]["weighted_diameter"]["barabasi_albert_optimized"] = @benchmarkable diameter(
        $g_ba, $distmx_ba
    )

    SUITE["distance"]["weighted_diameter"]["barabasi_albert_naive"] = @benchmarkable maximum(
        eccentricity($g_ba, vertices($g_ba), $distmx_ba)
    )
end
