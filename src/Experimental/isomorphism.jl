abstract type GraphMorphismProblem end
struct IsomorphismProblem <: GraphMorphismProblem end
struct SubGraphIsomorphismProblem <: GraphMorphismProblem end
struct InducedSubGraphIsomorphismProblem <: GraphMorphismProblem end

"""
    IsomorphismAlgorithm

An abstract type used for method dispatch on isomorphism functions.
"""
abstract type IsomorphismAlgorithm end

"""
    could_have_isomorph(g1, g2)

Run quick test to check if `g1 and `g2` could be isomorphic.

If the result is `false`, then `g1` and `g2` are definitely not isomorphic,
but if the result is `true` this is not guaranteed.

# Examples
```jldoctest
julia> using Graphs

julia> Graphs.Experimental.could_have_isomorph(path_graph(3), star_graph(4))
false

julia> Graphs.Experimental.could_have_isomorph(path_graph(3), star_graph(3))
true
```
"""
function could_have_isomorph(g1::AbstractGraph, g2::AbstractGraph)
    nv(g1) == nv(g2) || return false

    indegs1 = indegree(g1)
    indegs2 = indegree(g2)
    sort!(indegs1)
    sort!(indegs2)
    indegs1 == indegs2 || return false

    if Graphs.is_directed(g1) || Graphs.is_directed(g2)
        outdegs1 = outdegree(g1)
        outdegs2 = outdegree(g2)
        sort!(outdegs1)
        sort!(outdegs2)
        outdegs1 == outdegs2 || return false
    end

    return true
end

"""
    has_induced_subgraphisomorph(g1, g2, alg::IsomorphismAlgorithm=VF2(); vertex_relation=nothing, edge_relation=nothing)

Return `true` if the graph `g1` contains a vertex induced subgraph that is isomorphic to `g2`.

### Optional Arguments
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `VF2()` at the moment.
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.

### Examples
```doctest.jl
julia> has_induced_subgraphisomorph(complete_graph(5), complete_graph(4))
true
julia> has_induced_subgraphisomorph(complete_graph(5), cycle_graph(4))
false

julia> g1 = path_digraph(3); color1 = [1, 1, 1]
julia> g2 = path_digraph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> has_induced_subgraphisomorph(g1, g2)
true
julia> has_induced_subgraphisomorph(g1, g2, vertex_relation=color_rel)
false
```
### See also 
[`has_subgraphisomorph`](@ref), [`has_isomorph`](@ref), [`count_induced_subgraphisomorph`](@ref), [`all_induced_subgraphisomorph`](@ref)
"""
function has_induced_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    alg::IsomorphismAlgorithm=VF2();
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Bool
    return has_induced_subgraphisomorph(
        g1, g2, alg; vertex_relation=vertex_relation, edge_relation=edge_relation
    )
end

"""
    has_subgraphisomorph(g1, g2, alg::IsomorphismAlgorithm=VF2(); vertex_relation=nothing, edge_relation=nothing)

Return `true` if the graph `g1` contains a subgraph that is isomorphic to `g2`.

### Optional Arguments
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `VF2()` at the moment.
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.

### Examples
```doctest.jl
julia> has_subgraphisomorph(complete_graph(5), complete_graph(4))
true
julia> has_subgraphisomorph(complete_graph(5), cycle_graph(4))
true

julia> g1 = path_digraph(3); color1 = [1, 1, 1]
julia> g2 = path_digraph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> has_subgraphisomorph(g1, g2)
true
julia> has_subgraphisomorph(g1, g2, vertex_relation=color_rel)
false
```
### See also 
[`has_induced_subgraphisomorph`](@ref), [`has_isomorph`](@ref), [`count_subgraphisomorph`](@ref), [`all_subgraphisomorph`](@ref)
"""
function has_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    alg::IsomorphismAlgorithm=VF2();
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Bool
    return has_subgraphisomorph(
        g1, g2, alg; vertex_relation=vertex_relation, edge_relation=edge_relation
    )
end

"""
    has_isomorph(g1, g2, alg::IsomorphismAlgorithm=VF2(); vertex_relation=nothing, edge_relation=nothing)

Return `true` if the graph `g1` is isomorphic to `g2`.

### Optional Arguments
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `VF2()` at the moment.
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.

### Examples
```doctest.jl
julia> has_isomorph(complete_graph(3), cycle_graph(3))
true
julia> has_isomorph(complete_graph(4), cycle_graph(4))
false

julia> g1 = path_digraph(4); color1 = [1, 2, 1, 1]
julia> g2 = path_digraph(4); color2 = [1, 2, 2, 1]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> has_isomorph(g1, g2)
true
julia> has_isomorph(g1, g2, vertex_relation=color_rel)
false
```
### See also 
[`has_induced_subgraphisomorph`](@ref), [`has_subgraphisomorph`](@ref), [`count_subgraphisomorph`](@ref), [`all_subgraphisomorph`](@ref)
"""
function has_isomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    alg::IsomorphismAlgorithm=VF2();
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Bool
    return has_isomorph(
        g1, g2, alg; vertex_relation=vertex_relation, edge_relation=edge_relation
    )
end

"""
    count_induced_subgraphisomorph(g1, g2, alg::IsomorphismAlgorithm=VF2(); vertex_relation=nothing, edge_relation=nothing)

Return the number of vertex induced subgraphs of the graph `g1` that are isomorphic to `g2`.

### Optional Arguments
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.

### Examples
```doctest.jl
julia> count_induced_subgraphisomorph(complete_graph(5), complete_graph(4))
120
julia> count_induced_subgraphisomorph(complete_graph(5), cycle_graph(4))
0

julia> g1 = path_graph(3); color1 = [1, 1, 2]
julia> g2 = path_graph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> count_induced_subgraphisomorph(g1, g2)
2
julia> count_induced_subgraphisomorph(g1, g2, vertex_relation=color_rel)
1
```
### See also 
[`count_subgraphisomorph`](@ref), [`count_isomorph`](@ref), [`has_induced_subgraphisomorph`](@ref), [`all_induced_subgraphisomorph`](@ref)
"""
function count_induced_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    alg::IsomorphismAlgorithm=VF2();
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Int
    return count_induced_subgraphisomorph(
        g1, g2, alg; vertex_relation=vertex_relation, edge_relation=edge_relation
    )
end

"""
    count_subgraphisomorph(g1, g2, alg::IsomorphismAlgorithm=VF2(); vertex_relation=nothing, edge_relation=nothing)

Return the number of subgraphs of the graph `g1` that are isomorphic to `g2`.

### Optional Arguments
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `VF2()` at the moment.
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.

### Examples
```doctest.jl
julia> count_subgraphisomorph(complete_graph(5), complete_graph(4))
120
julia> count_subgraphisomorph(complete_graph(5), cycle_graph(4))
120

julia> g1 = cycle_digraph(3); color1 = [1, 1, 2]
julia> g2 = SimpleDiGraph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> count_subgraphisomorph(g1, g2)
6
julia> count_subgraphisomorph(g1, g2, vertex_relation=color_rel)
2
```
### See also 
[`count_induced_subgraphisomorph`](@ref), [`count_isomorph`](@ref), [`has_subgraphisomorph`](@ref), [`all_subgraphisomorph`](@ref)
"""
function count_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    alg::IsomorphismAlgorithm=VF2();
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Int
    return count_subgraphisomorph(
        g1::AbstractGraph,
        g2::AbstractGraph,
        VF2();
        vertex_relation=vertex_relation,
        edge_relation=edge_relation,
    )
end

"""
    count_isomorph(g1, g2, alg::IsomorphismAlgorithm=VF2(); vertex_relation=nothing, edge_relation=nothing)

Return the number of isomorphism from graph `g1` to `g2`.

### Optional Arguments
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `VF2()` at the moment.
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.

### Examples
```doctest.jl
julia> count_isomorph(cycle_graph(5), cycle_graph(5))
10
julia> count_isomorph(complete_graph(5), cycle_graph(5))
0

julia> g1 = cycle_digraph(3); color1 = [1, 1, 2]
julia> g2 = cycle_digraph(3); color2 = [1, 1, 1]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> count_isomorph(g1, g2)
3
julia> count_isomorph(g1, g2, vertex_relation=color_rel)
0
```
### See also 
[`count_induced_subgraphisomorph`](@ref), [`count_subgraphisomorph`](@ref), [`has_isomorph`](@ref), [`all_isomorph`](@ref)
"""
function count_isomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    alg::IsomorphismAlgorithm=VF2();
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Int
    return count_isomorph(
        g1, g2, alg; vertex_relation=vertex_relation, edge_relation=edge_relation
    )
end

"""
    all_induced_subgraphisomorph(g1, g2, alg::IsomorphismAlgorithm=VF2(); vertex_relation=nothing, edge_relation=nothing)

Return all isomorphism from vertex induced subgraphs of `g1` to `g2`.
The isomorphisms are returned as an iterator of vectors of tuples, where the i-th vector is 
the i-th isomorphism and a tuple (u, v) in this vector means that u ∈ g1 is
mapped to v ∈ g2.

### Optional Arguments
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `VF2()` at the moment.
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.

### Examples
```doctest.jl
julia> all_induced_subgraphisomorph(path_graph(3), SimpleGraph(2)) |> collect
2-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (3, 2)]
 [(3, 1), (1, 2)]

julia> g1 = path_digraph(3); color1 = [1, 1, 2]
julia> g2 = path_digraph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> all_induced_subgraphisomorph(g1, g2) |> collect
2-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2)]
 [(2, 1), (3, 2)]
julia> all_induced_subgraphisomorph(g1, g2, vertex_relation=color_rel) |> collect
1-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2)]
```
### See also 
[`all_subgraphisomorph`](@ref), [`all_isomorph`](@ref), [`has_induced_subgraphisomorph`](@ref), [`count_induced_subgraphisomorph`](@ref)
"""
function all_induced_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    alg::IsomorphismAlgorithm=VF2();
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}
    return all_induced_subgraphisomorph(
        g1, g2, alg; vertex_relation=vertex_relation, edge_relation=edge_relation
    )
end

"""
    all_subgraphisomorph(g1, g2, alg::IsomorphismAlgorithm=VF2(); vertex_relation=nothing, edge_relation=nothing)

Return all isomorphism from  subgraphs of `g1` to `g2`.
The isomorphisms are returned as an iterator of vectors of tuples, where the i-th vector is 
the i-th isomorphism and a tuple (u, v) in this vector means that u ∈ g1 is
mapped to v ∈ g2.

### Optional Arguments
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `VF2()` at the moment.
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.

### Examples
```doctest.jl
julia> all_subgraphisomorph(path_graph(3), path_graph(2)) |> collect
4-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2)]
 [(2, 1), (1, 2)]
 [(2, 1), (3, 2)]
 [(3, 1), (2, 2)]

julia> g1 = path_digraph(3); color1 = [1, 1, 2]
julia> g2 = path_digraph(2); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> all_subgraphisomorph(g1, g2) |> collect
2-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2)]
 [(2, 1), (3, 2)]
julia> all_subgraphisomorph(g1, g2, vertex_relation=color_rel)
1-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(2, 1), (3, 2)]
```
### See also 
[`all_induced_subgraphisomorph`](@ref), [`all_isomorph`](@ref), [`has_subgraphisomorph`](@ref), [`count_subgraphisomorph`](@ref)
"""
function all_subgraphisomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    alg::IsomorphismAlgorithm=VF2();
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}
    return all_subgraphisomorph(
        g1, g2, alg; vertex_relation=vertex_relation, edge_relation=edge_relation
    )
end

"""
    all_isomorph(g1, g2, alg::IsomorphismAlgorithm=VF2(); vertex_relation=nothing, edge_relation=nothing)

Return all isomorphism from `g1` to `g2`.
The isomorphisms are returned as an iterator of vectors of tuples, where the i-th vector is 
the i-th isomorphism and a tuple (u, v) in this vector means that u ∈ g1 is
mapped to v ∈ g2.

### Optional Arguments
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `VF2()` at the moment.
- `vertex_relation`: A binary function that takes a vertex from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched vertices.
- `edge_relation`: A binary function that takes an edge from `g1` and one from `g2`. An
    isomorphism only exists if this function returns `true` for all matched edges.

### Examples
```doctest.jl
julia> all_isomorph(star_graph(4), star_graph(4)) |> collect
6-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2), (3, 3), (4, 4)]
 [(1, 1), (2, 2), (4, 3), (3, 4)]
 [(1, 1), (3, 2), (2, 3), (4, 4)]
 [(1, 1), (3, 2), (4, 3), (2, 4)]
 [(1, 1), (4, 2), (2, 3), (3, 4)]
 [(1, 1), (4, 2), (3, 3), (2, 4)]
 
julia> g1 = cycle_digraph(3); color1 = [1, 1, 2]
julia> g2 = cycle_digraph(3); color2 = [2, 1, 1]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> all_isomorph(g1, g2) |> collect
3-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2), (3, 3)]
 [(2, 1), (3, 2), (1, 3)]
 [(3, 1), (1, 2), (2, 3)]
julia> all_subgraphisomorph(g1, g2, vertex_relation=color_rel)
1-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(3, 1), (1, 2), (2, 3)]
```
### See also 
[`all_induced_subgraphisomorph`](@ref), [`all_subgraphisomorph`](@ref), [`has_isomorph`](@ref), [`count_isomorph`](@ref)
"""
function all_isomorph(
    g1::AbstractGraph,
    g2::AbstractGraph,
    alg::IsomorphismAlgorithm=VF2();
    vertex_relation::Union{Nothing,Function}=nothing,
    edge_relation::Union{Nothing,Function}=nothing,
)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}
    return all_isomorph(
        g1, g2, alg; vertex_relation=vertex_relation, edge_relation=edge_relation
    )
end
