"""
	```pmfg(g, dmtx = weights(g)```

Compete the Planar Maximally Filtered Graph (PMFG) of `g`, given an optional set of weights `dmtx` that form a distance matrix.

### Examples
```
using Graphs, SimpleWeightedGraphs
N = 20
M = Symmetric(randn(N, N))
g = SimpleWeightedGraph(M) 
p_g = pmfg(g)
```

### References 
- Tuminello et al. 2005
"""
function pmfg(g, dmtx=weights(g))
    T = eltype(g)
    N = nv(g)
    out = SimpleGraph{T}(N)
    #create list of edges w/ weights
    edge_list = collect(edges(g))
    sort!(edge_list; by=x -> x.weight) #leaves biggest weight last
    while !isempty(edge_list)
        new_edge_weighted = pop!(edge_list)
        new_edge = Edge(new_edge_weighted.src, new_edge_weighted.dst)
        add_edge!(out, new_edge)
        if !is_planar(out)
            rem_edge!(out, new_edge)
        end
    end
    return out
end
