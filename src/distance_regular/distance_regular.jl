"""
    is_distance_regular(G::AbstractGraph) -> Bool

Return `true` if graph `G` is distance regular, `false` otherwise.

A connected graph ``G`` is distance-regular if for any nodes ``x,y``
and any integers ``i, j= 0, …, d`` (where ``d`` is the graph
diameter), the number of vertices at distance ``i`` from ``x`` and
distance ``j`` from ``y`` depends only on ``i,j`` and the graph distance
between ``x`` and ``y``, independently of the choice of ``x`` and ``y``.

# Examples
```jldoctest
julia> G = smallgraph(:icosahedral);

julia> is_distance_regular(G)
true
```

See Also: [`intersection_array`](@ref), [`global_parameters`](@ref)

# References
1. Brouwer, A. E.; Cohen, A. M.; and Neumaier, A.
    Distance-Regular Graphs. New York: Springer-Verlag, 1989.
2. Weisstein, Eric W. "Distance-Regular Graph."
    http://mathworld.wolfram.com/Distance-RegularGraph.html
"""
function is_distance_regular(G::AbstractGraph)
    isgood, _ = _intersection_array(G; check=true)
    return isgood
end


"""
    intersection_array(G::AbstractGraph) -> (b, c)

Return the intersection array of a distance-regular graph `G`.

Given a distance-regular graph G with integers ``b_i, c_i, i = 0, …, d``
such that for any 2 vertices ``x, y`` in ``G`` at a distance ``i = d(x, y)``,
there are exactly ``c_i`` neighbors of ``y`` at a distance of ``i-1`` from
``x`` and ``b_i`` neighbors of ``y`` at a distance of ``i+1`` from ``x``.

A distance regular graph's intersection array is given by
```math
\\{b_0, b_1, …, b_{d-1}; c_1, c_2, …, c_d\\}
```

# Examples
```jldoctest
julia> G = smallgraph(:icosahedral);

julia> intersection_array(G)
([5, 2, 1], [1, 2, 5])
```
"""
function intersection_array(G::AbstractGraph; check::Bool=true)
    isgood, int_arr = _intersection_array(G; check=check)
    check && !isgood && throw(ArgumentError("graph is not distance regular."))
    return int_arr
end


function _intersection_array(G::AbstractGraph; check::Bool=true)
    check && !allequal(degree(G)) && isempty(vertices(G)) &&
        is_connected(G) && return (false, (Int[], Int[]))
    paths_matrix = mapreduce(hcat, vertices(G)) do vertex
        dijkstra_shortest_paths(G, vertex).dists
    end
    diameter = maximum(paths_matrix)
    bv = zeros(Int, diameter+1)  # b intersection array
    cv = copy(bv)  # c intersection array
    for u in vertices(G), v in vertices(G)
        i = paths_matrix[u, v]
        # number of neighbors of v at a distance of i-1 from u
        c = count(neighbors(G, v)) do n
            paths_matrix[n, u] == i - 1
        end
        # number of neighbors of v at a distance of i+1 from u
        b = count(neighbors(G, v)) do n
            paths_matrix[n, u] == i + 1
        end
        # b and c cannot be zero
        # hence if any of bv[i+1] or cv[i+1]
        # is not zero nor corresponding b, c
        # the graph is not distance-regular
        if check && (bv[i+1] != 0 || bv[i+1] != b || cv[i+1] != 0 || cv[i+1] != c)
            return (false, (Int[], Int[]))
        end
        bv[i+1] = b
        cv[i+1] = c
    end
    pop!(bv); popfirst!(cv)
    return (true, (bv, cv))
end


"""
    global_parameters(b, c)

Returns global parameters for a given intersection array `b, c`.

Given a distance-regular graph ``G`` with integers ``b_i, c_i, i = 0, …, d``
such that for any 2 vertices ``x,y`` in ``G`` at a distance ``i = d(x,y)``, there
are exactly ``c_i`` neighbors of ``y`` at a distance of ``i-1`` from ``x`` and
``b_i`` neighbors of ``y`` at a distance of ``i+1`` from ``x``.

Thus, a distance regular graph has the global parameters,
```math
[[c_0, a_0, b_0], [c_1, a_1, b_1], …, [c_d, a_d, b_d]]
```
for the intersection array
```math
[b_0, b_1, …, b_{d-1}; c_1, c_2, …, c_d]
````
where ``a_i + b_i + c_i = k`` , ``k`` is the degree of every vertex.

# Returns
iterable
   An iterable over three tuples.

# Examples
```jldoctest
julia> G = smallgraph(:dodecahedral);

julia> b, c = intersection_array(G);

julia> collect(global_parameters(b, c))
[(0, 0, 3), (1, 0, 2), (1, 1, 1), (1, 1, 1), (2, 0, 1), (3, 0, 0)]
```
# References
.. [1] Weisstein, Eric W. "Global Parameters."
   From MathWorld--A Wolfram Web Resource.
   http://mathworld.wolfram.com/GlobalParameters.html

See Also [`intersection_array`](@ref)
"""
function global_parameters(b::AbstractVector{<:Integer}, c::AbstractVector{<:Integer})
    return ((y, b[begin] - x - y, x) for (x, y) in zip([b; 0], [0; c]))
end


"""
    global_parameters(G; check=false)
 
Returns global parameters for a given distance-regular graph G.
"""
function global_parameters(G::AbstractGraph; check::Bool=true)
    return global_parameters(intersection_array(G; check=check)...)
end


"""
    is_strongly_regular(G)

Returns `true` if and only if the given graph `G` is strongly regular.

An undirected graph is *strongly regular* if

* it is regular,
* each pair of adjacent vertices has the same number of neighbors in common,
* each pair of nonadjacent vertices has the same number of neighbors in common.

Each strongly regular graph is a distance-regular graph.
Conversely, if a distance-regular graph has diameter two, then it is
a strongly regular graph. For more information on distance-regular
graphs, see [`is_distance_regular`](@ref).

# Examples

The cycle graph on five vertices is strongly regular. It is
two-regular, each pair of adjacent vertices has no shared neighbors,
and each pair of nonadjacent vertices has one shared neighbor:

```jldoctest
julia> G = cycle_graph(5);

julia> is_strongly_regular(G)
true
```
"""
is_strongly_regular(G::AbstractGraph) = is_distance_regular(G) && diameter(G) == 2

