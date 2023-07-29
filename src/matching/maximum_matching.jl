using Graphs

const UNMATCHED = -1

"""
Compute the length of the shortest augmenting path
"""
function _hk_augmenting_bfs!(
    graph::Graph,
    set1::Vector{Int},
    matching::Dict{Int, Int},
    distance::Dict{Int, Float64},
)::Bool
    # Initialize queue with the unmatched nodes in set1
    queue = Vector{Int}([n for n in set1 if matching[n] == UNMATCHED])

    distance[UNMATCHED] = Inf
    for n in set1
        if matching[n] == UNMATCHED
            distance[n] = 0.0
        else
            distance[n] = Inf
        end
    end

    while !isempty(queue)
        n1 = popfirst!(queue)

        # If n1 is (a) matched or (b) in set1
        if distance[n1] < Inf && n1 != UNMATCHED
            for n2 in neighbors(graph, n1)
                # If n2 has not been encountered
                if distance[matching[n2]] == Inf
                    # Give it a distance
                    distance[matching[n2]] = distance[n1] + 1

                    # Note that n2 could be unmatched
                    push!(queue, matching[n2])
                end
            end
        end
    end

    found_augmenting_path = (distance[UNMATCHED] < Inf)
    # The distance to UNMATCHED is the length of the shortest augmenting path
    return found_augmenting_path
end

"""
Compute augmenting paths
"""
function _hk_dfs!(
    graph::Graph,
    root::Int,
    matching::Dict{Int, Int},
    distance::Dict{Int, Float64},
)::Bool
    if root != UNMATCHED
        for n in neighbors(graph, root)
            # We traverse along matched edges
            if distance[matching[n]] == distance[root] + 1
                if _hk_dfs!(graph, matching[n], matching, distance)
                    matching[root] = n
                    matching[n] = root
                    return true
                end
            end
        end
        distance[root] = Inf
        return false
    end
    return true
end

"""
    hopcroft_karp_matching(graph::Graph, set1::Set)::Dict

Compute a maximum-cardinality matching of a bipartite graph via the
[Hopcroft-Karp algorithm](https://en.wikipedia.org/wiki/Hopcroft-Karp_algorithm).

The return type is a dict mapping nodes in `set1` to other nodes *and* other
nodes back to their matched nodes in `set`.

### Arguments

* `graph`: The bipartite `Graph` for which a maximum matching is computed

* `set1`: A set of vertices in a bipartition

"""
function hopcroft_karp_matching(graph::Graph, set1::Set)
    matching = Dict(n => UNMATCHED for n in vertices(graph))
    set1 = [n for n in vertices(graph) if n in set1]
    distance = Dict{Int, Float64}()
    while _hk_augmenting_bfs!(graph, set1, matching, distance)
        for n1 in set1
            if matching[n1] == UNMATCHED
                _hk_dfs!(graph, n1, matching, distance)
            end
        end
    end
    matching = Dict(i => j for (i, j) in matching if j != UNMATCHED)
    return matching
end
