# Floyd Warshall algorithm to find shortest paths between all pairs of vertices


function floyd_warshall!{W}(dists::AbstractMatrix{W}) # dists: minimum distance matrix (initialized to edge distances)

    # argument checking

    n = size(dists, 1)
    if size(dists, 2) != n
        throw(ArgumentError("dists should be a square matrix."))
    end

    # initialize

    for i = 1 : n
        dists[i,i] = 0
    end

    # main loop

    for k = 1 : n, i = 1 : n, j = 1 : n
        d = dists[i,k] + dists[k,j]
        if d < dists[i,j]
            dists[i,j] = d
        end
    end

    dists
end


function floyd_warshall!{W}(
    dists::AbstractMatrix{W},       # minimum distance matrix (initialized to edge distances)
    nexts::AbstractMatrix{Int})     # nexts(i,j) = the next hop from i when traveling from i to j via shortest path

    # argument checking

    n = size(dists, 1)
    if size(dists, 2) != n
        throw(ArgumentError("dists should be a square matrix."))
    end

    if size(nexts) != (n, n)
        throw(ArgumentError("nexts should be an n-by-n matrix."))
    end

    # initialize

    for i = 1 : n
        dists[i,i] = 0
    end

    for j = 1 : n, i = 1 : n
        nexts[i,j] = isfinite(dists[i,j]) ? j : 0
    end

    # main loop

    for k = 1 : n, i = 1 : n, j = 1 : n
        d = dists[i,k] + dists[k,j]
        if d < dists[i,j]
            dists[i,j] = d
            nexts[i,j] = nexts[i,k]
        end
    end

    dists
end


floyd_warshall(weights::AbstractMatrix) = floyd_warshall!(copy(weights))
