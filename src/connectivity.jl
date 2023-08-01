# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.
"""
    connected_components!(label, g)

Fill `label` with the `id` of the connected component in the undirected graph
`g` to which it belongs. Return a vector representing the component assigned
to each vertex. The component value is the smallest vertex ID in the component.

### Performance
This algorithm is linear in the number of edges of the graph.
"""
function connected_components!(label::AbstractVector, g::AbstractGraph{T}) where {T}
    for u in vertices(g)
        label[u] != zero(T) && continue
        label[u] = u
        Q = Vector{T}()
        push!(Q, u)
        while !isempty(Q)
            src = popfirst!(Q)
            for vertex in all_neighbors(g, src)
                if label[vertex] == zero(T)
                    push!(Q, vertex)
                    label[vertex] = u
                end
            end
        end
    end
    return label
end

"""
    components_dict(labels)

Convert an array of labels to a map of component id to vertices, and return
a map with each key corresponding to a given component id
and each value containing the vertices associated with that component.
"""
function components_dict(labels::Vector{T}) where {T<:Integer}
    d = Dict{T,Vector{T}}()
    for (v, l) in enumerate(labels)
        vec = get(d, l, Vector{T}())
        push!(vec, v)
        d[l] = vec
    end
    return d
end

"""
    components(labels)

Given a vector of component labels, return a vector of vectors representing the vertices associated
with a given component id.
"""
function components(labels::Vector{T}) where {T<:Integer}
    d = Dict{T,T}()
    c = Vector{Vector{T}}()
    i = one(T)
    for (v, l) in enumerate(labels)
        index = get!(d, l, i)
        if length(c) >= index
            push!(c[index], v)
        else
            push!(c, [v])
            i += 1
        end
    end
    return c, d
end

"""
    connected_components(g)

Return the [connected components](https://en.wikipedia.org/wiki/Connectivity_(graph_theory))
of an undirected graph `g` as a vector of components, with each element a vector of vertices
belonging to the component.

For directed graphs, see [`strongly_connected_components`](@ref) and
[`weakly_connected_components`](@ref).

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleGraph([0 1 0; 1 0 1; 0 1 0]);

julia> connected_components(g)
1-element Vector{Vector{Int64}}:
 [1, 2, 3]

julia> g = SimpleGraph([0 1 0 0 0; 1 0 1 0 0; 0 1 0 0 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> connected_components(g)
2-element Vector{Vector{Int64}}:
 [1, 2, 3]
 [4, 5]
```
"""
function connected_components(g::AbstractGraph{T}) where {T}
    label = zeros(T, nv(g))
    connected_components!(label, g)
    c, d = components(label)
    return c
end

"""
    is_connected(g)

Return `true` if graph `g` is connected. For directed graphs, return `true`
if graph `g` is weakly connected.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleGraph([0 1 0; 1 0 1; 0 1 0]);

julia> is_connected(g)
true

julia> g = SimpleGraph([0 1 0 0 0; 1 0 1 0 0; 0 1 0 0 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> is_connected(g)
false

julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_connected(g)
true
```
"""
function is_connected(g::AbstractGraph)
    mult = is_directed(g) ? 2 : 1
    return mult * ne(g) + 1 >= nv(g) && length(connected_components(g)) == 1
end

"""
    weakly_connected_components(g)

Return the weakly connected components of the graph `g`. This
is equivalent to the connected components of the undirected equivalent of `g`.
For undirected graphs this is equivalent to the [`connected_components`](@ref) of `g`.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleDiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> weakly_connected_components(g)
1-element Vector{Vector{Int64}}:
 [1, 2, 3]
```
"""
weakly_connected_components(g) = connected_components(g)

"""
    is_weakly_connected(g)

Return `true` if the graph `g` is weakly connected. If `g` is undirected,
this function is equivalent to [`is_connected(g)`](@ref).

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_weakly_connected(g)
true

julia> g = SimpleDiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> is_connected(g)
true

julia> is_strongly_connected(g)
false

julia> is_weakly_connected(g)
true
```
"""
is_weakly_connected(g) = is_connected(g)

"""
    strongly_connected_components(g)

Compute the strongly connected components of a directed graph `g`.

Return an array of arrays, each of which is the entire connected component.

### Implementation Notes
The order of the components is not part of the API contract.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleDiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> strongly_connected_components(g)
2-element Vector{Vector{Int64}}:
 [3]
 [1, 2]

julia> g = SimpleDiGraph(11)
{11, 0} directed simple Int64 graph

julia> edge_list=[(1,2),(2,3),(3,4),(4,1),(3,5),(5,6),(6,7),(7,5),(5,8),(8,9),(9,8),(10,11),(11,10)];

julia> g = SimpleDiGraph(Edge.(edge_list))
{11, 13} directed simple Int64 graph

julia> strongly_connected_components(g)
4-element Vector{Vector{Int64}}:
 [8, 9]
 [5, 6, 7]
 [1, 2, 3, 4]
 [10, 11]
```
"""
function strongly_connected_components end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function strongly_connected_components(
    g::AG::IsDirected
) where {T<:Integer,AG<:AbstractGraph{T}}
    zero_t = zero(T)
    one_t = one(T)
    nvg = nv(g)
    count = one_t

    index = zeros(T, nvg)         # first time in which vertex is discovered
    stack = Vector{T}()           # stores vertices which have been discovered and not yet assigned to any component
    onstack = zeros(Bool, nvg)    # false if a vertex is waiting in the stack to receive a component assignment
    lowlink = zeros(T, nvg)       # lowest index vertex that it can reach through back edge (index array not vertex id number)
    parents = zeros(T, nvg)       # parent of every vertex in dfs
    components = Vector{Vector{T}}()    # maintains a list of scc (order is not guaranteed in API)

    dfs_stack = Vector{T}()

    @inbounds for s in vertices(g)
        if index[s] == zero_t
            index[s] = count
            lowlink[s] = count
            onstack[s] = true
            parents[s] = s
            push!(stack, s)
            count = count + one_t

            # start dfs from 's'
            push!(dfs_stack, s)

            while !isempty(dfs_stack)
                v = dfs_stack[end] # end is the most recently added item
                u = zero_t
                @inbounds for v_neighbor in outneighbors(g, v)
                    if index[v_neighbor] == zero_t
                        # unvisited neighbor found
                        u = v_neighbor
                        break
                        # GOTO A push u onto DFS stack and continue DFS
                    elseif onstack[v_neighbor]
                        # we have already seen n, but can update the lowlink of v
                        # which has the effect of possibly keeping v on the stack until n is ready to pop.
                        # update lowest index 'v' can reach through out neighbors
                        lowlink[v] = min(lowlink[v], index[v_neighbor])
                    end
                end
                if u == zero_t
                    # All out neighbors already visited or no out neighbors
                    # we have fully explored the DFS tree from v.
                    # time to start popping.
                    popped = pop!(dfs_stack)
                    lowlink[parents[popped]] = min(
                        lowlink[parents[popped]], lowlink[popped]
                    )

                    if index[v] == lowlink[v]
                        # found a cycle in a completed dfs tree.
                        component = Vector{T}()

                        while !isempty(stack) # break when popped == v
                            # drain stack until we see v.
                            # everything on the stack until we see v is in the SCC rooted at v.
                            popped = pop!(stack)
                            push!(component, popped)
                            onstack[popped] = false
                            # popped has been assigned a component, so we will never see it again.
                            if popped == v
                                # we have drained the stack of an entire component.
                                break
                            end
                        end

                        reverse!(component)
                        push!(components, component)
                    end

                else # LABEL A
                    # add unvisited neighbor to dfs
                    index[u] = count
                    lowlink[u] = count
                    onstack[u] = true
                    parents[u] = v
                    count = count + one_t

                    push!(stack, u)
                    push!(dfs_stack, u)
                    # next iteration of while loop will expand the DFS tree from u.
                end
            end
        end
    end

    return components
end

"""
    strongly_connected_components_kosaraju(g)

Compute the strongly connected components of a directed graph `g` using Kosaraju's Algorithm.
(https://en.wikipedia.org/wiki/Kosaraju%27s_algorithm).

Return an array of arrays, each of which is the entire connected component.

### Performance
Time Complexity : O(|E|+|V|)
Space Complexity : O(|V|) {Excluding the memory required for storing graph}

|V| = Number of vertices
|E| = Number of edges

### Examples
```jldoctest
julia> using Graphs

julia> g=SimpleDiGraph(3)
{3, 0} directed simple Int64 graph

julia> g = SimpleDiGraph([0 1 0 ; 0 0 1; 0 0 0])
{3, 2} directed simple Int64 graph

julia> strongly_connected_components_kosaraju(g)
3-element Vector{Vector{Int64}}:
 [1]
 [2]
 [3]


julia> g=SimpleDiGraph(11)
{11, 0} directed simple Int64 graph

julia> edge_list=[(1,2),(2,3),(3,4),(4,1),(3,5),(5,6),(6,7),(7,5),(5,8),(8,9),(9,8),(10,11),(11,10)]
13-element Vector{Tuple{Int64, Int64}}:
 (1, 2)
 (2, 3)
 (3, 4)
 (4, 1)
 (3, 5)
 (5, 6)
 (6, 7)
 (7, 5)
 (5, 8)
 (8, 9)
 (9, 8)
 (10, 11)
 (11, 10)

julia> g = SimpleDiGraph(Edge.(edge_list))
{11, 13} directed simple Int64 graph

julia> strongly_connected_components_kosaraju(g)
4-element Vector{Vector{Int64}}:
 [11, 10]
 [2, 3, 4, 1]
 [6, 7, 5]
 [9, 8]

```
"""
function strongly_connected_components_kosaraju end
@traitfn function strongly_connected_components_kosaraju(
    g::AG::IsDirected
) where {T<:Integer,AG<:AbstractGraph{T}}
    nvg = nv(g)

    components = Vector{Vector{T}}()    # Maintains a list of strongly connected components

    order = Vector{T}()         # Vector which will store the order in which vertices are visited
    sizehint!(order, nvg)

    color = zeros(UInt8, nvg)       # Vector used as for marking the colors during dfs

    dfs_stack = Vector{T}()   # Stack used for dfs

    # dfs1
    @inbounds for v in vertices(g)
        color[v] != 0 && continue
        color[v] = 1

        # Start dfs from v
        push!(dfs_stack, v)   # Push v to the stack

        while !isempty(dfs_stack)
            u = dfs_stack[end]
            w = zero(T)

            for u_neighbor in outneighbors(g, u)
                if color[u_neighbor] == 0
                    w = u_neighbor
                    break
                end
            end

            if w != 0
                push!(dfs_stack, w)
                color[w] = 1
            else
                push!(order, u)  # Push back in vector to store the order in which the traversal finishes(Reverse Topological Sort)
                color[u] = 2
                pop!(dfs_stack)
            end
        end
    end

    @inbounds for i in vertices(g)
        color[i] = 0    # Marking all the vertices from 1 to n as unvisited for dfs2
    end

    # dfs2
    @inbounds for i in 1:nvg
        v = order[end - i + 1]   # Reading the order vector in the decreasing order of finish time
        color[v] != 0 && continue
        color[v] = 1

        component = Vector{T}()   # Vector used to store the vertices of one component temporarily

        # Start dfs from v
        push!(dfs_stack, v)   # Push v to the stack

        while !isempty(dfs_stack)
            u = dfs_stack[end]
            w = zero(T)

            for u_neighbor in inneighbors(g, u)
                if color[u_neighbor] == 0
                    w = u_neighbor
                    break
                end
            end

            if w != 0
                push!(dfs_stack, w)
                color[w] = 1
            else
                color[u] = 2
                push!(component, u)   # Push u to the vector component
                pop!(dfs_stack)
            end
        end

        push!(components, component)
    end

    return components
end

"""
    is_strongly_connected(g)

Return `true` if directed graph `g` is strongly connected.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_strongly_connected(g)
true
```
"""
function is_strongly_connected end
@traitfn function is_strongly_connected(g::::IsDirected)
    return length(strongly_connected_components(g)) == 1
end

"""
    period(g)

Return the (common) period for all vertices in a strongly connected directed graph.
Will throw an error if the graph is not strongly connected.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> period(g)
3
```
"""
function period end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function period(g::AG::IsDirected) where {T,AG<:AbstractGraph{T}}
    !is_strongly_connected(g) && throw(ArgumentError("Graph must be strongly connected"))

    # First check if there's a self loop
    has_self_loops(g) && return 1

    g_bfs_tree = bfs_tree(g, 1)
    levels = gdistances(g_bfs_tree, 1)
    edge_values = Vector{T}()

    divisor = 0
    for e in edges(g)
        has_edge(g_bfs_tree, src(e), dst(e)) && continue
        @inbounds value = levels[src(e)] - levels[dst(e)] + 1
        divisor = gcd(divisor, value)
        isequal(divisor, 1) && return 1
    end

    return divisor
end

"""
    condensation(g[, scc])

Return the condensation graph of the strongly connected components `scc`
in the directed graph `g`. If `scc` is missing, generate the strongly
connected components first.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0])
{5, 6} directed simple Int64 graph

julia> strongly_connected_components(g)
2-element Vector{Vector{Int64}}:
 [4, 5]
 [1, 2, 3]

julia> foreach(println, edges(condensation(g)))
Edge 2 => 1
```
"""
function condensation end
@traitfn function condensation(g::::IsDirected, scc::Vector{Vector{T}}) where {T<:Integer}
    h = DiGraph{T}(length(scc))

    component = Vector{T}(undef, nv(g))

    for (i, s) in enumerate(scc)
        @inbounds component[s] .= i
    end

    @inbounds for e in edges(g)
        s, d = component[src(e)], component[dst(e)]
        if (s != d)
            add_edge!(h, s, d)
        end
    end
    return h
end
@traitfn condensation(g::::IsDirected) = condensation(g, strongly_connected_components(g))

"""
    attracting_components(g)

Return a vector of vectors of integers representing lists of attracting
components in the directed graph `g`.

The attracting components are a subset of the strongly
connected components in which the components do not have any leaving edges.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0])
{5, 6} directed simple Int64 graph

julia> strongly_connected_components(g)
2-element Vector{Vector{Int64}}:
 [4, 5]
 [1, 2, 3]

julia> attracting_components(g)
1-element Vector{Vector{Int64}}:
 [4, 5]
```
"""
function attracting_components end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function attracting_components(g::AG::IsDirected) where {T,AG<:AbstractGraph{T}}
    scc = strongly_connected_components(g)
    cond = condensation(g, scc)

    attracting = Vector{T}()

    for v in vertices(cond)
        if outdegree(cond, v) == 0
            push!(attracting, v)
        end
    end
    return scc[attracting]
end

"""
    neighborhood(g, v, d, distmx=weights(g))

Return a vector of each vertex in `g` at a geodesic distance less than or equal to `d`, where distances
may be specified by `distmx`.

### Optional Arguments
- `dir=:out`: If `g` is directed, this argument specifies the edge direction
with respect to `v` of the edges to be considered. Possible values: `:in` or `:out`.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> neighborhood(g, 1, 2)
3-element Vector{Int64}:
 1
 2
 3

julia> neighborhood(g, 1, 3)
4-element Vector{Int64}:
 1
 2
 3
 4

julia> neighborhood(g, 1, 3, [0 1 0 0 0; 0 0 1 0 0; 1 0 0 0.25 0; 0 0 0 0 0.25; 0 0 0 0.25 0])
5-element Vector{Int64}:
 1
 2
 3
 4
 5
```
"""
function neighborhood(
    g::AbstractGraph{T}, v::Integer, d, distmx::AbstractMatrix{U}=weights(g); dir=:out
) where {T<:Integer} where {U<:Real}
    return first.(neighborhood_dists(g, v, d, distmx; dir=dir))
end

"""
    neighborhood_dists(g, v, d, distmx=weights(g))

Return a a vector of tuples representing each vertex which is at a geodesic distance less than or equal to `d`, along with
its distance from `v`. Non-negative distances may be specified by `distmx`.

### Optional Arguments
- `dir=:out`: If `g` is directed, this argument specifies the edge direction
with respect to `v` of the edges to be considered. Possible values: `:in` or `:out`.

# Examples
```jldoctest
julia> using Graphs

julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> neighborhood_dists(g, 1, 3)
4-element Vector{Tuple{Int64, Int64}}:
 (1, 0)
 (2, 1)
 (3, 2)
 (4, 3)

julia> neighborhood_dists(g, 1, 3, [0 1 0 0 0; 0 0 1 0 0; 1 0 0 0.25 0; 0 0 0 0 0.25; 0 0 0 0.25 0])
5-element Vector{Tuple{Int64, Float64}}:
 (1, 0.0)
 (2, 1.0)
 (3, 2.0)
 (4, 2.25)
 (5, 2.5)

julia> neighborhood_dists(g, 4, 3)
2-element Vector{Tuple{Int64, Int64}}:
 (4, 0)
 (5, 1)

julia> neighborhood_dists(g, 4, 3, dir=:in)
5-element Vector{Tuple{Int64, Int64}}:
 (4, 0)
 (3, 1)
 (5, 1)
 (2, 2)
 (1, 3)
```
"""
function neighborhood_dists(
    g::AbstractGraph{T}, v::Integer, d, distmx::AbstractMatrix{U}=weights(g); dir=:out
) where {T<:Integer} where {U<:Real}
    return if (dir == :out)
        _neighborhood(g, v, d, distmx, outneighbors)
    else
        _neighborhood(g, v, d, distmx, inneighbors)
    end
end

function _neighborhood(
    g::AbstractGraph{T},
    v::Integer,
    d::Real,
    distmx::AbstractMatrix{U},
    neighborfn::Function,
) where {T<:Integer} where {U<:Real}
    Q = Vector{Tuple{T,U}}()
    d < zero(U) && return Q
    push!(Q, (v, zero(U)))
    seen = fill(false, nv(g))
    seen[v] = true # Bool Vector benchmarks faster than BitArray
    for (src, currdist) in Q
        currdist >= d && continue
        for dst in neighborfn(g, src)
            if !seen[dst]
                seen[dst] = true
                if currdist + distmx[src, dst] <= d
                    push!(Q, (dst, currdist + distmx[src, dst]))
                end
            end
        end
    end
    return Q
end

"""
    isgraphical(degs)

Return true if the degree sequence `degs` is graphical.
A sequence of integers is called graphical, if there exists a graph where the degrees of its vertices form that same sequence.

### Performance
Time complexity: ``\\mathcal{O}(|degs|*\\log(|degs|))``.

### Implementation Notes
According to Erdös-Gallai theorem, a degree sequence ``\\{d_1, ...,d_n\\}`` (sorted in descending order) is graphic iff the sum of vertex degrees is even and the sequence obeys the property -
```math
\\sum_{i=1}^{r} d_i \\leq r(r-1) + \\sum_{i=r+1}^n min(r,d_i)
```
for each integer r <= n-1. 

See also: [`isdigraphical`](@ref)
"""
function isgraphical(degs::AbstractVector{<:Integer})
    # Check whether the degree sequence is empty
    !isempty(degs) || return true
    # Check whether the sum of degrees is even
    iseven(sum(degs)) || return false
    # Check that all degrees are non negative and less than n-1
    n = length(degs)
    all(0 .<= degs .<= n - 1) || return false
    # Sort the degree sequence in non-increasing order
    sorted_degs = sort(degs; rev=true)
    # Compute the length of the degree sequence
    cur_sum = zero(UInt64)
    # Compute the minimum of each degree and the corresponding index
    mindeg = Vector{UInt64}(undef, n)
    @inbounds for i in 1:n
        mindeg[i] = min(i, sorted_degs[i])
    end
    # Check if the degree sequence satisfies the Erdös-Gallai condition
    cum_min = sum(mindeg)
    @inbounds for r in 1:(n - 1)
        cur_sum += sorted_degs[r]
        cum_min -= mindeg[r]
        cond = cur_sum <= (r * (r - 1) + cum_min)
        cond || return false
    end
    return true
end

"""
    isdigraphical(indegree_sequence, outdegree_sequence)

Check whether the given indegree sequence and outdegree sequence are digraphical, that is whether they can be the indegree and outdegree sequence of a simple digraph (i.e. a directed graph with no loops). This implies that `indegree_sequence` and `outdegree_sequence` are not independent, as their elements respectively represent the indegrees and outdegrees that the vertices shall have.

### Implementation Notes
According to Fulkerson-Chen-Anstee theorem, a sequence ``\\{(a_1, b_1), ...,(a_n, b_n)\\}`` (sorted in descending order of a) is graphic iff ``\\sum_{i = 1}^{n} a_i = \\sum_{i = 1}^{n} b_i\\}`` and the sequence obeys the property -
```math
\\sum_{i=1}^{r} a_i \\leq \\sum_{i=1}^n min(r-1,b_i) + \\sum_{i=r+1}^n min(r,b_i)
```
for each integer 1 <= r <= n-1. 

See also: [`isgraphical`](@ref)
"""
function isdigraphical(
    indegree_sequence::AbstractVector{<:Integer},
    outdegree_sequence::AbstractVector{<:Integer},
)
    # Check whether the degree sequences have the same length 
    n = length(indegree_sequence)
    n == length(outdegree_sequence) || throw(
        ArgumentError("The indegree and outdegree sequences must have the same length.")
    )
    # Check whether the degree sequence is empty
    !(isempty(indegree_sequence) && isempty(outdegree_sequence)) || return true
    # Check all degrees are non negative and less than n-1
    all(0 .<= indegree_sequence .<= n - 1) || return false
    all(0 .<= outdegree_sequence .<= n - 1) || return false

    sum(indegree_sequence) == sum(outdegree_sequence) || return false

    _sortperm = sortperm(indegree_sequence; rev=true)

    sorted_indegree_sequence = indegree_sequence[_sortperm]
    sorted_outdegree_sequence = outdegree_sequence[_sortperm]

    indegree_sum = zero(Int64)
    outdegree_min_sum = zero(Int64)

    cum_min = zero(Int64)

    # The following approach, which requires substituting the line
    # cum_min = sum([min(sorted_outdegree_sequence[i], r) for i in (1+r):n])
    # with the line
    # cum_min -= mindeg[r]
    # inside the for loop below, work as well, but the values of `cum_min` at each iteration differ. To be on the safe side we implemented it as in https://en.wikipedia.org/wiki/Fulkerson%E2%80%93Chen%E2%80%93Anstee_theorem
    #=     mindeg = Vector{Int64}(undef, n)
        @inbounds for i = 1:n
            mindeg[i] = min(i, sorted_outdegree_sequence[i])
        end
        cum_min = sum(mindeg) =#
    # Similarly for `outdegree_min_sum`.

    @inbounds for r in 1:n
        indegree_sum += sorted_indegree_sequence[r]
        outdegree_min_sum = sum([min(sorted_outdegree_sequence[i], r - 1) for i in 1:r])
        cum_min = sum([min(sorted_outdegree_sequence[i], r) for i in (1 + r):n])
        cond = indegree_sum <= (outdegree_min_sum + cum_min)
        cond || return false
    end

    return true
end
