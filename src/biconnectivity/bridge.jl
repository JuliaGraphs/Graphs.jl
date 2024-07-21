"""
    bridges(g)

Compute the [bridges](https://en.wikipedia.org/wiki/Bridge_(graph_theory))
of a connected graph `g` and return an array containing all bridges, i.e edges
whose deletion increases the number of connected components of the graph.
# Examples
```jldoctest
julia> using Graphs

julia> bridges(star_graph(5))
4-element Vector{Graphs.SimpleGraphs.SimpleEdge{Int64}}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 1 => 4
 Edge 1 => 5

julia> bridges(path_graph(5))
4-element Vector{Graphs.SimpleGraphs.SimpleEdge{Int64}}:
 Edge 4 => 5
 Edge 3 => 4
 Edge 2 => 3
 Edge 1 => 2
```
"""
function bridges end
@traitfn function bridges(g::AG::(!IsDirected)) where {T,AG<:AbstractGraph{T}}
    s = Vector{Tuple{T,T,T}}()
    low = zeros(T, nv(g)) # keeps track of the earliest accessible time of a vertex in DFS-stack, effect of having back-edges is considered here
    pre = zeros(T, nv(g)) # checks the entry time of a vertex in the DFS-stack, pre[u] = 0 if a vertex isn't visited; non-zero, otherwise
    bridges = Edge{T}[]   # keeps record of the bridge-edges

    # We iterate over all vertices, and if they have already been visited (pre != 0), we don't start a DFS from that vertex.
    # The purpose is to create a DFS forest.
    @inbounds for u in vertices(g)
        pre[u] != 0 && continue
        v = u # currently visiting vertex
        wi::T = zero(T) # index of children of v
        w::T = zero(T) # children of v
        cnt::T = one(T) # keeps record of the time
        first_time = true

        # TODO the algorithm currently relies on the assumption that
        # outneighbors(g, v) is indexable. This assumption might not be true
        # in general, so in case that outneighbors does not produce a vector
        # we collect these vertices. This might lead to a large number of
        # allocations, so we should find a way to handle that case differently,
        # or require inneighbors, outneighbors and neighbors to always
        # return indexable collections.

        # start of DFS
        while !isempty(s) || first_time
            first_time = false
            if wi < 1 # initialisation for vertex v
                pre[v] = cnt
                cnt += 1
                low[v] = pre[v]
                v_neighbors = collect_if_not_vector(outneighbors(g, v))
                wi = 1
            else
                wi, u, v = pop!(s) # the stack states, explained later
                v_neighbors = collect_if_not_vector(outneighbors(g, v))
                w = v_neighbors[wi]
                low[v] = min(low[v], low[w]) # condition check for (v, w) being a tree-edge
                if low[w] > pre[v]
                    edge = v < w ? Edge(v, w) : Edge(w, v)
                    push!(bridges, edge)
                end
                wi += 1
            end

            # here, we're iterating of all the children of vertex v, if unvisited, we start a DFS from that child, else we update the low[v] as the edge is a back-edge.
            while wi <= length(v_neighbors)
                w = v_neighbors[wi]
                # If this is true , this indicates the vertex is still unvisited, then we push this on the stack.
                # Pushing onto the stack is analogous to visiting the vertex and starting DFS from that vertex.
                if pre[w] == 0
                    push!(s, (wi, u, v)) # the stack states are (index of child, currently visiting vertex, parent vertex of the child)
                    # updates the value for stimulating DFS from top of the stack
                    wi = 0
                    u = v
                    v = w
                    break
                elseif w != u # (v, w) is a back-edge
                    low[v] = min(low[v], pre[w]) # condition for back-edges
                end
                wi += 1
            end
            wi < 1 && continue
        end
    end

    return bridges
end
