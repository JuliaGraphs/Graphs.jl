"""
	planar_maximally_filtered_graph(g)

Compute the Planar Maximally Filtered Graph (PMFG) of weighted graph `g`. Returns a `SimpleGraph{eltype(g)}`.

### Examples
```
using Graphs, SimpleWeightedGraphs
N = 20
M = Symmetric(randn(N, N))
g = SimpleWeightedGraph(M) 
p_g = planar_maximally_filtered_graph(g)
```

### References 
- [Tuminello et al. 2005](https://doi.org/10.1073/pnas.0500298102)
"""
function planar_maximally_filtered_graph(
    g::AG, distmx::AbstractMatrix{T}=weights(g); minimize=true
) where {T<:Real,U,AG<:AbstractGraph{U}}

    #if graph has <= 6 edges, just return it
    if ne(g) <= 6
        test_graph = SimpleGraph{U}(nv(g))
        for e in edges(g)
            add_edge!(test_graph, e)
        end
        return test_graph
    end

    #construct a list of edge weights
    edge_list = collect(edges(g))
    weights = [distmx[src(e), dst(e)] for e in edge_list]
    #sort the set of edges by weight
    #we try to maximally filter the graph and assume that weights
    #represent distances. Thus we want to add edges with the 
    #smallest distances first. We sort edges in ascending order
    #of weight (if minimize=true) and iterate from the start of
    #the list.
    edge_list .= edge_list[sortperm(weights; rev=(!minimize))]

    #construct an initial graph
    test_graph = SimpleGraph{U}(nv(g))

    for e in edge_list[1:min(6, length(edge_list))]
        #we can always add the first six edges of a graph 
        add_edge!(test_graph, src(e), dst(e))
    end

    #go through the rest of the edge list 
    for e in edge_list[7:end]
        add_edge!(test_graph, src(e), dst(e)) #add it to graph
        if !is_planar(test_graph) #if resulting graph is not planar, remove it again
            rem_edge!(test_graph, src(e), dst(e))
        end
        (ne(test_graph) >= 3 * nv(test_graph) - 6) && break #break if limit reached
    end

    return test_graph
end
