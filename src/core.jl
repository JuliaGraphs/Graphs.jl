"""
    AbstractPathState

An abstract type that provides information from shortest paths calculations.
"""
abstract type AbstractPathState end

"""
    is_ordered(e)

Return true if the source vertex of edge `e` is less than or equal to
the destination vertex.

# Examples
```jldoctest
julia> using Graphs

julia> g = DiGraph(2);

julia> add_edge!(g, 2, 1);

julia> is_ordered(first(edges(g)))
false
```
"""
is_ordered(e::AbstractEdge) = src(e) <= dst(e)

"""
    add_vertices!(g, n)

Add `n` new vertices to the graph `g`.
Return the number of vertices that were added successfully.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleGraph()
{0, 0} undirected simple Int64 graph

julia> add_vertices!(g, 2)
2
```
"""
add_vertices!(g::AbstractGraph, n::Integer) = sum([add_vertex!(g) for i in 1:n])

# TODO the behaviour of indegree (and as well outdegree and degree) is very
# badly documented for the case indegree(g, vs) where vs is not a single vertex
# but rather a collection of vertices

"""
    indegree(g[, v])

Return a vector corresponding to the number of edges which end at each vertex in
graph `g`. If `v` is specified, only return degrees for vertices in `v`.

# Examples
```jldoctest
julia> using Graphs

julia> g = DiGraph(3);

julia> add_edge!(g, 2, 3);

julia> add_edge!(g, 3, 1);

julia> indegree(g)
3-element Vector{Int64}:
 1
 0
 1
```
"""
indegree(g::AbstractGraph, v::Integer) = length(inneighbors(g, v))
indegree(g::AbstractGraph, vs=vertices(g)) = [indegree(g, x) for x in vs]

"""
    outdegree(g[, v])

Return a vector corresponding to the number of edges which start at each vertex in
graph `g`. If `v` is specified, only return degrees for vertices in `v`.

# Examples
```jldoctest
julia> using Graphs

julia> g = DiGraph(3);

julia> add_edge!(g, 2, 3);

julia> add_edge!(g, 3, 1);

julia> outdegree(g)
3-element Vector{Int64}:
 0
 1
 1
```
"""
outdegree(g::AbstractGraph, v::Integer) = length(outneighbors(g, v))
outdegree(g::AbstractGraph, vs=vertices(g)) = [outdegree(g, x) for x in vs]

"""
    degree(g[, v])

Return a vector corresponding to the number of edges which start or end at each
vertex in graph `g`. If `v` is specified, only return degrees for vertices in `v`.
For directed graphs, this value equals the incoming plus outgoing edges.
For undirected graphs, it equals the connected edges.

# Examples
```jldoctest
julia> using Graphs

julia> g = DiGraph(3);

julia> add_edge!(g, 2, 3);

julia> add_edge!(g, 3, 1);

julia> degree(g)
3-element Vector{Int64}:
 1
 1
 2
```
"""
function degree end

function degree(g::AbstractGraph, v::Integer)
    if !is_directed(g)
        return outdegree(g, v)
    end
    return indegree(g, v) + outdegree(g, v)
end

degree(g::AbstractGraph, vs=vertices(g)) = [degree(g, x) for x in vs]

"""
    Δout(g)

Return the maximum [`outdegree`](@ref) of vertices in `g`.
"""
Δout(g) = noallocextreme(outdegree, (>), typemin(Int), g)
"""
    δout(g)

Return the minimum [`outdegree`](@ref) of vertices in `g`.
"""
δout(g) = noallocextreme(outdegree, (<), typemax(Int), g)

"""
    Δin(g)

Return the maximum [`indegree`](@ref) of vertices in `g`.
"""
Δin(g) = noallocextreme(indegree, (>), typemin(Int), g)

"""
    δin(g)

Return the minimum [`indegree`](@ref) of vertices in `g`.
"""
δin(g) = noallocextreme(indegree, (<), typemax(Int), g)

"""
    Δ(g)

Return the maximum [`degree`](@ref) of vertices in `g`.
"""
Δ(g) = noallocextreme(degree, (>), typemin(Int), g)

"""
    δ(g)

Return the minimum [`degree`](@ref) of vertices in `g`.
"""
δ(g) = noallocextreme(degree, (<), typemax(Int), g)

"""
    noallocextreme(f, comparison, initial, g)

Compute the extreme value of `[f(g,i) for i=i:nv(g)]` without gathering them all
"""
function noallocextreme(f, comparison, initial, g)
    value = initial
    for i in vertices(g)
        funci = f(g, i)
        if comparison(funci, value)
            value = funci
        end
    end
    return value
end

"""
    degree_histogram(g, degfn=degree)

Return a `Dict` with values representing the number of vertices that have degree
represented by the key.

Degree function (for example, [`indegree`](@ref) or [`outdegree`](@ref)) may be specified by
overriding `degfn`.
"""
function degree_histogram(g::AbstractGraph{T}, degfn=degree) where {T}
    hist = Dict{T,Int}()
    for v in vertices(g)        # minimize allocations by
        for d in degfn(g, v)    # iterating over vertices
            hist[d] = get(hist, d, 0) + 1
        end
    end
    return hist
end

"""
    neighbors(g, v)

Return a list of all neighbors reachable from vertex `v` in `g`.
For directed graphs, the default is equivalent to [`outneighbors`](@ref);
use [`all_neighbors`](@ref) to list inbound and outbound neighbors.

### Implementation Notes
Returns a reference to the current graph's internal structures, not a copy.
Do not modify result. If the graph is modified, the behavior is undefined:
the array behind this reference may be modified too, but this is not guaranteed.

# Examples
```jldoctest
julia> using Graphs

julia> g = DiGraph(3);

julia> add_edge!(g, 2, 3);

julia> add_edge!(g, 3, 1);

julia> neighbors(g, 1)
Int64[]

julia> neighbors(g, 2)
1-element Vector{Int64}:
 3

julia> neighbors(g, 3)
1-element Vector{Int64}:
 1
```
"""
neighbors(g::AbstractGraph, v::Integer) = outneighbors(g, v)

"""
    all_neighbors(g, v)

Return a list of all inbound and outbound neighbors of `v` in `g`.
For undirected graphs, this is equivalent to both [`outneighbors`](@ref)
and [`inneighbors`](@ref).

### Implementation Notes
Returns a reference to the current graph's internal structures, not a copy.
Do not modify result. If the graph is modified, the behavior is undefined:
the array behind this reference may be modified too, but this is not guaranteed.

# Examples
```jldoctest
julia> using Graphs

julia> g = DiGraph(3);

julia> add_edge!(g, 2, 3);

julia> add_edge!(g, 3, 1);

julia> all_neighbors(g, 1)
1-element Vector{Int64}:
 3

julia> all_neighbors(g, 2)
1-element Vector{Int64}:
 3

julia> all_neighbors(g, 3)
2-element Vector{Int64}:
 1
 2
```
"""
function all_neighbors end
@traitfn function all_neighbors(g::::IsDirected, v::Integer)
    return union(outneighbors(g, v), inneighbors(g, v))
end
@traitfn all_neighbors(g::::(!IsDirected), v::Integer) = neighbors(g, v)

"""
    common_neighbors(g, u, v)

Return the neighbors common to vertices `u` and `v` in `g`.

### Implementation Notes
Returns a reference to the current graph's internal structures, not a copy.
Do not modify result. If the graph is modified, the behavior is undefined:
the array behind this reference may be modified too, but this is not guaranteed.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleGraph(4);

julia> add_edge!(g, 1, 2);

julia> add_edge!(g, 2, 3);

julia> add_edge!(g, 3, 4);

julia> add_edge!(g, 4, 1);

julia> add_edge!(g, 1, 3);

julia> common_neighbors(g, 1, 3)
2-element Vector{Int64}:
 2
 4

julia> common_neighbors(g, 1, 4)
1-element Vector{Int64}:
 3
```
"""
function common_neighbors(g::AbstractGraph, u::Integer, v::Integer)
    return intersect(neighbors(g, u), neighbors(g, v))
end

"""
    has_self_loops(g)

Return true if `g` has any self loops.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleGraph(2);

julia> add_edge!(g, 1, 2);

julia> has_self_loops(g)
false

julia> add_edge!(g, 1, 1);

julia> has_self_loops(g)
true
```
"""
function has_self_loops(g::AbstractGraph)
    return nv(g) == 0 ? false : any(v -> has_edge(g, v, v), vertices(g))
end

"""
    num_self_loops(g)

Return the number of self loops in `g`.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleGraph(2);

julia> add_edge!(g, 1, 2);

julia> num_self_loops(g)
0

julia> add_edge!(g, 1, 1);

julia> num_self_loops(g)
1
```
"""
num_self_loops(g::AbstractGraph) = nv(g) == 0 ? 0 : sum(v -> has_edge(g, v, v), vertices(g))

"""
    density(g)

Return the density of `g`.
Density is defined as the ratio of the number of actual edges to the
number of possible edges (``|V|×(|V|-1)`` for directed graphs and
``\\frac{|V|×(|V|-1)}{2}`` for undirected graphs).
"""
function density end
@traitfn density(g::::IsDirected) = ne(g) / (nv(g) * (nv(g) - 1))
@traitfn density(g::::(!IsDirected)) = (2 * ne(g)) / (nv(g) * (nv(g) - 1))

"""
    squash(g)

Return a copy of a graph with the smallest practical eltype that
can accommodate all vertices.

May also return the original graph if the eltype does not change.
"""
function squash(g::AbstractGraph)

    # TODO this version check can be removed when we increase the required Julia version
    deprecation_msg = "squash(::AbstractGraph) is deprecated in favor of methods that specialize on the graph type."
    if VERSION >= v"1.5.2"
        Base.depwarn(deprecation_msg, :squash; force=true)
    else
        Base.depwarn(deprecation_msg, :squash)
    end

    gtype = is_directed(g) ? DiGraph : Graph
    validtypes = [UInt8, UInt16, UInt32, UInt64, Int64]
    nvg = nv(g)
    for T in validtypes
        nvg < typemax(T) && return gtype{T}(g)
    end
end

"""
    weights(g)

Return the weights of the edges of a graph `g` as a matrix. Defaults
to [`Graphs.DefaultDistance`](@ref).

### Implementation Notes
In general, referencing the weight of a nonexistent edge is undefined behavior. Do not rely on the `weights` matrix
as a substitute for the graph's [`adjacency_matrix`](@ref).
"""
weights(g::AbstractGraph) = DefaultDistance(nv(g))
