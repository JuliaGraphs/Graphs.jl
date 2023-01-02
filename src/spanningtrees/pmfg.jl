"""
	pmfg(g)

Compete the Planar Maximally Filtered Graph (PMFG) of weighted graph `g`.

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
function better_mst(
    g::AG, distmx::AbstractMatrix{T}=weights(g); minimize=true
) where {T<:Real,U,AG<:AbstractGraph{U}}
    #check graph is not directed
    if is_directed(g)
        error("PMFG only supports non-directed graphs")
    end

    #construct a list of edge weights
    weights = Vector{T}()
    sizehint!(weights, ne(g))
    edge_list = collect(edges(g))
    for e in edge_list
        push!(weights, distmx[src(e), dst(e)])
    end
    #sort the set of edges by weight
    #we try to maximally filter the graph and assume that weights
    #represent distances. Thus we want to add edges with the 
    #smallest distances first. Given that we pop the edge list, 
    #we want the smallest weight edges at the end of the edge list
    #after sorting, which means reversing the usual direction of
    #the sort.
    edge_list .= edge_list[sortperm(weights, rev = !minimize)]

    #construct an initial graph
    test_graph = SimpleGraph(nv(g))

    #go through the edge list 
    while !isempty(edge_list)
        e = pop!(edge_list) #get most weighted edge
        add_edge!(test_graph, e.src, e.dst) #add it to graph
        if !is_planar(test_graph) #if resulting graph is not planar, remove it again
            rem_edge!(test_graph, e.src, e.dst)
        end
        (ne(test_graph) >= 3*nv(test_graph) - 6) && break #break if limit reached
    end

    return test_graph
end

#= 
This could be improved a lot by not reallocating
the LRP construct. 
Things to reset on each planarity retest:
heights 
lowpts(2)
nesting_depth 
parent_edge
DG (shame...)
adjs (could just be re-edited?)
ordered_adjs (same)
Ref
side 
S 
stack_bottom 
lowpt_edge =#
