"""
    clique_percolation(g, k=3)

Community detection using the clique percolation algorithm. Communities are potentially overlapping.
Return a vector of vectors `c` such that `c[i]` is the set of vertices in community `i`.
The parameter `k` defines the size of the clique to use in percolation.

### References
- [Palla G, Derenyi I, Farkas I J, et al.] (https://www.nature.com/articles/nature03607)

# Examples
```jldoctest
julia> using Graphs

julia> clique_percolation(clique_graph(3, 2))
2-element Vector{BitSet}:
 BitSet([4, 5, 6])
 BitSet([1, 2, 3])

julia> clique_percolation(clique_graph(3, 2), k=2)
1-element Vector{BitSet}:
 BitSet([1, 2, 3, 4, 5, 6])

julia> clique_percolation(clique_graph(3, 2), k=4)
BitSet[]
```
"""
function clique_percolation end

@traitfn function clique_percolation(g::::(!IsDirected); k=3)
    kcliques = filter(x -> length(x) >= k, maximal_cliques(g))
    nc = length(kcliques)
    # graph with nodes represent k-cliques
    h = Graph(nc)
    # vector for counting common nodes between two cliques efficiently
    x = falses(nv(g))
    for i in 1:nc
        x[kcliques[i]] .= true
        for j in (i + 1):nc
            sum(x[kcliques[j]]) >= k - 1 && add_edge!(h, i, j)
        end
        # reset status
        x[kcliques[i]] .= false
    end
    components = connected_components(h)
    communities = [BitSet() for i in 1:length(components)]
    for (i, component) in enumerate(components)
        push!(communities[i], vcat(kcliques[component]...)...)
    end
    return communities
end
