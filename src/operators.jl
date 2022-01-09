"""
    complement(g)

Return the [graph complement](https://en.wikipedia.org/wiki/Complement_graph)
of a graph

### Implementation Notes
Preserves the `eltype` of the input graph.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> foreach(println, edges(complement(g)))
Edge 1 => 3
Edge 1 => 4
Edge 1 => 5
Edge 2 => 1
Edge 2 => 4
Edge 2 => 5
Edge 3 => 2
Edge 3 => 5
Edge 4 => 1
Edge 4 => 2
Edge 4 => 3
Edge 5 => 1
Edge 5 => 2
Edge 5 => 3
```
"""
function complement(g::Graph)
    gnv = nv(g)
    h = SimpleGraph(gnv)
    for i = 1:gnv
        for j = (i + 1):gnv
            if !has_edge(g, i, j)
                add_edge!(h, i, j)
            end
        end
    end
    return h
end

function complement(g::DiGraph)
    gnv = nv(g)
    h = SimpleDiGraph(gnv)
    for i in vertices(g), j in vertices(g)
        if i != j && !has_edge(g, i, j)
            add_edge!(h, i, j)
        end
    end
    return h
end

"""
    reverse(g)

Return a directed graph where all edges are reversed from the
original directed graph.

### Implementation Notes
Preserves the eltype of the input graph.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> foreach(println, edges(reverse(g)))
Edge 1 => 3
Edge 2 => 1
Edge 3 => 2
Edge 4 => 3
Edge 4 => 5
Edge 5 => 4
```
"""
function reverse end
@traitfn function reverse(g::G::IsDirected) where G<:AbstractSimpleGraph
    gnv = nv(g)
    gne = ne(g)
    h = SimpleDiGraph(gnv)
    h.fadjlist = deepcopy_adjlist(g.badjlist)
    h.badjlist = deepcopy_adjlist(g.fadjlist)
    h.ne = gne
    return h
end

"""
    reverse!(g)

In-place reverse of a directed graph (modifies the original graph).
See [`reverse`](@ref) for a non-modifying version.
"""
function reverse! end
@traitfn function reverse!(g::G::IsDirected) where G<:AbstractSimpleGraph
    g.fadjlist, g.badjlist = g.badjlist, g.fadjlist
    return g
end

"""
    blockdiag(g, h)

Return a graph with ``|V(g)| + |V(h)|`` vertices and ``|E(g)| + |E(h)|``
edges where the vertices and edges from graph `h` are appended to graph `g`.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the
number of vertices in the generated graph exceeds the `eltype`.

# Examples
```jldoctest
julia> g1 = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> g2 = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> blockdiag(g1, g2)
{8, 9} directed simple Int64 graph

julia> foreach(println, edges(blockdiag(g1, g2)))
Edge 1 => 2
Edge 2 => 3
Edge 3 => 1
Edge 3 => 4
Edge 4 => 5
Edge 5 => 4
Edge 6 => 7
Edge 7 => 8
Edge 8 => 6
```
"""
function blockdiag(g::T, h::T) where T <: AbstractGraph
    gnv = nv(g)
    r = T(gnv + nv(h))
    for e in edges(g)
        add_edge!(r, e)
    end
    for e in edges(h)
        add_edge!(r, gnv + src(e), gnv + dst(e))
    end
    return r
end

"""
    intersect(g, h)

Return a graph with edges that are only in both graph `g` and graph `h`.

### Implementation Notes
This function may produce a graph with 0-degree vertices.
Preserves the eltype of the input graph.

# Examples
```jldoctest
julia> g1 = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> g2 = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> foreach(println, edges(intersect(g1, g2)))
Edge 1 => 2
Edge 2 => 3
Edge 3 => 1
```
"""
function intersect(g::T, h::T) where T <: AbstractGraph
    gnv = nv(g)
    hnv = nv(h)

    r = T(min(gnv, hnv))
    for e in intersect(edges(g), edges(h))
        add_edge!(r, e)
    end
    return r
end

"""
    difference(g, h)

Return a graph with edges in graph `g` that are not in graph `h`.

### Implementation Notes
Note that this function may produce a graph with 0-degree vertices.
Preserves the `eltype` of the input graph.

# Examples
```jldoctest
julia> g1 = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> g2 = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> foreach(println, edges(difference(g1, g2)))
Edge 3 => 4
Edge 4 => 5
Edge 5 => 4
```
"""
function difference(g::T, h::T) where T <: AbstractGraph
    gnv = nv(g)
    hnv = nv(h)

    r = T(gnv)
    for e in edges(g)
        !has_edge(h, e) && add_edge!(r, e)
    end
    return r
end

"""
    symmetric_difference(g, h)

Return a graph with edges from graph `g` that do not exist in graph `h`,
and vice versa.

### Implementation Notes
Note that this function may produce a graph with 0-degree vertices.
Preserves the eltype of the input graph. Will error if the
number of vertices in the generated graph exceeds the eltype.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleGraph(3); h = SimpleGraph(3);

julia> add_edge!(g, 1, 2);

julia> add_edge!(h, 1, 3);

julia> add_edge!(h, 2, 3);

julia> f = symmetric_difference(g, h);

julia> collect(edges(f))
3-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 2 => 3
```
"""
function symmetric_difference(g::T, h::T) where T <: AbstractGraph
    gnv = nv(g)
    hnv = nv(h)

    r = T(max(gnv, hnv))
    for e in edges(g)
        !has_edge(h, e) && add_edge!(r, e)
    end
    for e in edges(h)
        !has_edge(g, e) && add_edge!(r, e)
    end
    return r
end

"""
    union(g, h)

Return a graph that combines graphs `g` and `h` by taking the set union
of all vertices and edges.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the
number of vertices in the generated graph exceeds the eltype.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleGraph(3); h = SimpleGraph(5);

julia> add_edge!(g, 1, 2);

julia> add_edge!(g, 1, 3);

julia> add_edge!(h, 3, 4);

julia> add_edge!(h, 3, 5);

julia> add_edge!(h, 4, 5);

julia> f = union(g, h);

julia> collect(edges(f))
5-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 3 => 4
 Edge 3 => 5
 Edge 4 => 5
```
"""
function union(g::T, h::T) where T <: AbstractSimpleGraph
    gnv = nv(g)
    hnv = nv(h)

    r = T(max(gnv, hnv))
    r.ne = ne(g)
    for i in vertices(g)
        r.fadjlist[i] = deepcopy(g.fadjlist[i])
        if is_directed(g)
            r.badjlist[i] = deepcopy(g.badjlist[i])
        end
    end
    for e in edges(h)
        add_edge!(r, e)
    end
    return r
end


"""
    join(g, h)

Return a graph that combines graphs `g` and `h` using `blockdiag` and then
adds all the edges between the vertices in `g` and those in `h`.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the number of vertices
in the generated graph exceeds the eltype.

# Examples
```jldoctest
julia> using Graphs

julia> g = join(star_graph(3), path_graph(2))
{5, 9} undirected simple Int64 graph

julia> collect(edges(g))
9-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 1 => 4
 Edge 1 => 5
 Edge 2 => 4
 Edge 2 => 5
 Edge 3 => 4
 Edge 3 => 5
 Edge 4 => 5
```
"""
function join(g::T, h::T) where T <: AbstractGraph
    r = blockdiag(g, h)
    for i in vertices(g)
        for j = (nv(g) + 1):(nv(g) + nv(h))
            add_edge!(r, i, j)
        end
    end
    return r
end


"""
    crosspath(len::Integer, g::Graph)

Return a graph that duplicates `g` `len` times and connects each vertex
with its copies in a path.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the number of vertices
in the generated graph exceeds the eltype.

# Examples
```jldoctest
julia> using Graphs

julia> g = crosspath(3, path_graph(3))
{9, 12} undirected simple Int64 graph

julia> collect(edges(g))
12-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 4
 Edge 2 => 3
 Edge 2 => 5
 Edge 3 => 6
 Edge 4 => 5
 Edge 4 => 7
 Edge 5 => 6
 Edge 5 => 8
 Edge 6 => 9
 Edge 7 => 8
 Edge 8 => 9
```
"""
function crosspath end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function crosspath(len::Integer, g::AG::(!IsDirected)) where {T, AG <: AbstractGraph{T}}
    p = path_graph(len)
    h = Graph{T}(p)
    return cartesian_product(h, g)
end

# The following operators allow one to use a Graphs.Graph as a matrix in eigensolvers for spectral ranking and partitioning.
# """Provides multiplication of a graph `g` by a vector `v` such that spectral
# graph functions in [GraphMatrices.jl](https://github.com/jpfairbanks/GraphMatrices.jl) can utilize Graphs natively.
# """
function *(g::Graph, v::Vector{T}) where T <: Real
    length(v) == nv(g) || throw(ArgumentError("Vector size must equal number of vertices"))
    y = zeros(T, nv(g))
    for e in edges(g)
        i = src(e)
        j = dst(e)
        y[i] += v[j]
        y[j] += v[i]
    end
    return y
end

function *(g::DiGraph, v::Vector{T}) where T <: Real
    length(v) == nv(g) || throw(ArgumentError("Vector size must equal number of vertices"))
    y = zeros(T, nv(g))
    for e in edges(g)
        i = src(e)
        j = dst(e)
        y[i] += v[j]
    end
    return y
end

"""
    sum(g, i)

Return a vector of indegree (`i`=1) or outdegree (`i`=2) values for graph `g`.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> sum(g, 2)
5-element Array{Int64,1}:
 1
 1
 2
 1
 1

julia> sum(g, 1)
5-element Array{Int64,1}:
 1
 1
 1
 2
 1
```
"""
function sum(g::AbstractGraph, dim::Int)
    dim == 1 && return indegree(g, vertices(g))
    dim == 2 && return outdegree(g, vertices(g))
    throw(ArgumentError("dimension must be <= 2"))
end


size(g::AbstractGraph) = (nv(g), nv(g))
"""
    size(g, i)

Return the number of vertices in `g` if `i`=1 or `i`=2, or `1` otherwise.

# Examples
```jldoctest
julia> using Graphs

julia> g = cycle_graph(4);

julia> size(g, 1)
4

julia> size(g, 2)
4

julia> size(g, 3)
1
```
"""
size(g::Graph, dim::Int) = (dim == 1 || dim == 2) ? nv(g) : 1

"""
    sum(g)

Return the number of edges in `g`.

# Examples
```jldoctest
julia> g = SimpleGraph([0 1 0; 1 0 1; 0 1 0]);

julia> sum(g)
2
```
"""
sum(g::AbstractGraph) = ne(g)

"""
    sparse(g)

Return the default adjacency matrix of `g`.
"""
sparse(g::AbstractGraph) = adjacency_matrix(g)

length(g::AbstractGraph) = widen(nv(g)) * widen(nv(g))
ndims(g::AbstractGraph) = 2
issymmetric(g::AbstractGraph) = !is_directed(g)

"""
    cartesian_product(g, h)

Return the [cartesian product](https://en.wikipedia.org/wiki/Cartesian_product_of_graphs)
of `g` and `h`.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the number of vertices
in the generated graph exceeds the eltype.

# Examples
```jldoctest
julia> using Graphs

julia> g = cartesian_product(star_graph(3), path_graph(3))
{9, 12} undirected simple Int64 graph

julia> collect(edges(g))
12-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 4
 Edge 1 => 7
 Edge 2 => 3
 Edge 2 => 5
 Edge 2 => 8
 Edge 3 => 6
 Edge 3 => 9
 Edge 4 => 5
 Edge 5 => 6
 Edge 7 => 8
 Edge 8 => 9
```
"""
function cartesian_product(g::G, h::G) where G <: AbstractGraph
    z = G(nv(g) * nv(h))
    id(i, j) = (i - 1) * nv(h) + j
    for e in edges(g)
        i1, i2 = Tuple(e)
        for j = 1:nv(h)
            add_edge!(z, id(i1, j), id(i2, j))
        end
    end

    for e in edges(h)
        j1, j2 = Tuple(e)
        for i in vertices(g)
            add_edge!(z, id(i, j1), id(i, j2))
        end
    end
    return z
end

"""
    tensor_product(g, h)

Return the [tensor product](https://en.wikipedia.org/wiki/Tensor_product_of_graphs)
of `g` and `h`.

### Implementation Notes
Preserves the eltype of the input graph. Will error if the number of vertices
in the generated graph exceeds the eltype.

# Examples
```jldoctest
julia> using Graphs

julia> g = tensor_product(star_graph(3), path_graph(3))
{9, 8} undirected simple Int64 graph

julia> collect(edges(g))
8-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 5
 Edge 1 => 8
 Edge 2 => 4
 Edge 2 => 6
 Edge 2 => 7
 Edge 2 => 9
 Edge 3 => 5
 Edge 3 => 8
```
"""
function tensor_product(g::G, h::G) where G <: AbstractGraph
    z = G(nv(g) * nv(h))
    id(i, j) = (i - 1) * nv(h) + j
    undirected = !is_directed(g)
    for e1 in edges(g)
        i1, i2 = Tuple(e1)
        for e2 in edges(h)
            j1, j2 = Tuple(e2)
            add_edge!(z, id(i1, j1), id(i2, j2))
            if undirected
                add_edge!(z, id(i1, j2), id(i2, j1))
            end
        end
    end
    return z
end


## subgraphs ###

"""
    induced_subgraph(g, vlist)
    induced_subgraph(g, elist)

Return the subgraph of `g` induced by the vertices in  `vlist` or edges in `elist`
along with a vector mapping the new vertices to the old ones
(the  vertex `i` in the subgraph corresponds to the vertex `vmap[i]` in `g`.)

The returned graph has `length(vlist)` vertices, with the new vertex `i`
corresponding to the vertex of the original graph in the `i`-th position
of `vlist`.

### Usage Examples
```doctestjl
julia> g = complete_graph(10)

julia> sg, vmap = induced_subgraph(g, 5:8)

julia> @assert g[5:8] == sg

julia> @assert nv(sg) == 4

julia> @assert ne(sg) == 6

julia> @assert vm[4] == 8

julia> sg, vmap = induced_subgraph(g, [2,8,3,4])

julia> @assert sg == g[[2,8,3,4]]

julia> elist = [Edge(1,2), Edge(3,4), Edge(4,8)]

julia> sg, vmap = induced_subgraph(g, elist)

julia> @assert sg == g[elist]
```
"""
function induced_subgraph(g::T, vlist::AbstractVector{U}) where T <: AbstractGraph where U <: Integer
    allunique(vlist) || throw(ArgumentError("Vertices in subgraph list must be unique"))
    h = T(length(vlist))
    newvid = Dict{U,U}()
    vmap = Vector{U}(undef, length(vlist))
    for (i, v) in enumerate(vlist)
        newvid[v] = U(i)
        vmap[i] = v
    end

    vset = Set(vlist)
    for s in vlist
        for d in outneighbors(g, s)
            # println("s = $s, d = $d")
            if d in vset && has_edge(g, s, d)
                newe = Edge(newvid[s], newvid[d])
                add_edge!(h, newe)
            end
        end
    end
    return h, vmap
end

function induced_subgraph(g::AbstractGraph, vlist::AbstractVector{Bool})
    length(vlist) == length(g) || throw(BoundsError(g, vlist))
    return induced_subgraph(g, findall(vlist))
end

function induced_subgraph(g::AG, elist::AbstractVector{U}) where AG <: AbstractGraph{T} where T where U <: AbstractEdge
    h = zero(g)
    newvid = Dict{T,T}()
    vmap = Vector{T}()

    for e in elist
        u, v = Tuple(e)
        for i in (u, v)
            if !haskey(newvid, i)
                add_vertex!(h)
                newvid[i] = nv(h)
                push!(vmap, i)
            end
        end
        add_edge!(h, newvid[u], newvid[v])
    end
    return h, vmap
end


"""
    g[iter]

Return the subgraph induced by `iter`.
Equivalent to [`induced_subgraph`](@ref)`(g, iter)[1]`.
"""
getindex(g::AbstractGraph, iter) = induced_subgraph(g, iter)[1]


"""
    egonet(g, v, d, distmx=weights(g))

Return the subgraph of `g` induced by the neighbors of `v` up to distance
`d`, using weights (optionally) provided by `distmx`.
This is equivalent to [`induced_subgraph`](@ref)`(g, neighborhood(g, v, d, dir=dir))[1].`

### Optional Arguments
- `dir=:out`: if `g` is directed, this argument specifies the edge direction
with respect to `v` (i.e. `:in` or `:out`).
"""
egonet(g::AbstractGraph{T}, v::Integer, d::Integer, distmx::AbstractMatrix{U}=weights(g); dir=:out) where T <: Integer where U <: Real =
    g[neighborhood(g, v, d, distmx, dir=dir)]



"""
    compute_shifts(n::Int, x::AbstractArray)

Determine how many elements of `x` are less than `i` for all `i` in `1:n`.
"""
function compute_shifts(n::Integer, x::AbstractArray)
    tmp = zeros(eltype(x), n)
    tmp[x] .= 1
    return cumsum!(tmp, tmp)
end

"""
    merge_vertices(g::AbstractGraph, vs)

Create a new graph where all vertices in `vs` have been aliased to the same vertex `minimum(vs)`.

# Examples
```jldoctest
julia> using Graphs

julia> g = path_graph(5);

julia> collect(edges(g))
4-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
 Edge 3 => 4
 Edge 4 => 5

julia> h = merge_vertices(g, [2, 3]);

julia> collect(edges(h))
3-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
 Edge 3 => 4
```
"""
function merge_vertices(g::AbstractSimpleGraph, vs)
    # Use lowest value as new vertex id.
    vs = unique!(sort(vs))
    merged_vertex = popfirst!(vs)

    nvnew = nv(g) - length(vs)
    nvnew <= nv(g) || return g
    merged_vertex > 0 || throw(ArgumentError("invalid vertex ID: $merged_vertex in list of vertices to be merged"))
    vs[end] <= nv(g) || throw(ArgumentError("vertex $(vs[end]) not found in graph")) # TODO 0.7: change to DomainError?

    new_vertex_ids = collect(vertices(g)) .- compute_shifts(nv(g), vs)
    new_vertex_ids[vs] .= merged_vertex

    #if v in vs then labels[v] == v0 else labels[v] == v
    newg = SimpleGraph(nvnew)
    for e in edges(g)
        u, w = src(e), dst(e)
        if new_vertex_ids[u] != new_vertex_ids[w] #not a new self loop
            add_edge!(newg, new_vertex_ids[u], new_vertex_ids[w])
        end
    end
    return newg
end

"""
    merge_vertices!(g, vs)

Combine vertices specified in `vs` into single vertex whose
index will be the lowest value in `vs`. All edges connected to vertices in `vs`
connect to the new merged vertex.

Return a vector with new vertex values are indexed by the original vertex indices.

### Implementation Notes
Supports [`SimpleGraph`](@ref) only.

# Examples
```jldoctest
julia> using Graphs

julia> g = path_graph(5);

julia> collect(edges(g))
4-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
 Edge 3 => 4
 Edge 4 => 5

julia> merge_vertices!(g, [2, 3])
5-element Array{Int64,1}:
 1
 2
 2
 3
 4

julia> collect(edges(g))
3-element Array{Graphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
 Edge 3 => 4
```
"""
function merge_vertices!(g::Graph{T}, vs::Vector{U} where U <: Integer) where T
    vs = unique!(sort(vs))
    (merged_vertex, vm) = extrema(vs)

    merged_vertex > 0 || throw(ArgumentError("invalid vertex ID: $merged_vertex in list of vertices to be merged"))
    vm <= nv(g) || throw(ArgumentError("vertex $vm not found in graph")) # TODO 0.7: change to DomainError?

    new_vertex_ids = collect(vertices(g)) .- compute_shifts(nv(g), vs[2:end])
    new_vertex_ids[vs] .= merged_vertex

    for i in vertices(g)
        # Adjust connections to merged vertices
        if new_vertex_ids[i] != merged_vertex
            nbrs_to_rewire = Set{T}()
            for j in outneighbors(g, i)
                push!(nbrs_to_rewire, new_vertex_ids[j])
            end
            g.fadjlist[new_vertex_ids[i]] = sort!(collect(nbrs_to_rewire))

        # Collect connections to new merged vertex
        else
            nbrs_to_merge = Set{T}()
            for j in vs, e in outneighbors(g, j)
                if new_vertex_ids[e] != merged_vertex
                    push!(nbrs_to_merge, new_vertex_ids[e])
                end
            end
            g.fadjlist[i] = sort(collect(nbrs_to_merge))
        end
    end


    # Drop excess vertices
    g.fadjlist = g.fadjlist[begin:(end - length(vs)+1)]

    # Correct edge counts
    g.ne = sum(degree(g, i) for i in vertices(g)) / 2

    return new_vertex_ids
end
