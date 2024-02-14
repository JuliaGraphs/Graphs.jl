"""
    edit_distance(G₁::AbstractGraph, G₂::AbstractGraph)

Compute the edit distance between graphs `G₁` and `G₂`. Return the minimum
edit cost and edit path to transform graph `G₁` into graph `G₂``.
An edit path consists of a sequence of pairs of vertices ``(u,v) ∈ [0,|G₁|] × [0,|G₂|]``
representing vertex operations:

- ``(0,v)``: insertion of vertex ``v ∈ G₂``
- ``(u,0)``: deletion of vertex ``u ∈ G₁``
- ``(u>0,v>0)``: substitution of vertex ``u ∈ G₁`` by vertex ``v ∈ G₂``


### Optional Arguments
- `vertex_insert_cost::Function=v->0.`
- `vertex_delete_cost::Function=u->0.`
- `vertex_subst_cost::Function=(u, v)->0.`
- `edge_insert_cost::Function=e->1.`
- `edge_delete_cost::Function=e->1.`
- `edge_subst_cost::Function=(e1, e2)->0.`

The algorithm will always try to match two edges if it can, so if it is
preferrable to delete two edges rather than match these, it should be
reflected in the `edge_subst_cost` function.

By default, the algorithm uses constant operation costs. The
user can provide classical Minkowski costs computed from vertex
labels μ₁ (for G₁) and μ₂ (for G₂) in order to further guide the
search, for example:

```
edit_distance(G₁, G₂, subst_cost=MinkowskiCost(μ₁, μ₂))
```
- `heuristic::Function=DefaultEditHeuristic`: a custom heuristic provided to the A*
search in case the default heuristic is not satisfactory.

### Performance
- Given two graphs ``|G₁| < |G₂|``, `edit_distance(G₁, G₂)` is faster to
compute than `edit_distance(G₂, G₁)`. Consider swapping the arguments
if involved costs are equivalent.
- The use of a heuristic can improve performance considerably.
- Exploit vertex attributes when designing operation costs.

### References
- RIESEN, K., 2015. Structural Pattern Recognition with Graph Edit Distance: Approximation Algorithms and Applications. (Chapter 2)

### Author
- Júlio Hoffimann Mendes (juliohm@stanford.edu)

# Examples
```jldoctest
julia> using Graphs

julia> g1 = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> g2 = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> edit_distance(g1, g2)
(3.0, Tuple[(1, 3), (2, 1), (3, 2), (4, 0), (5, 0)])
```
"""
function edit_distance(
    G₁::AbstractGraph,
    G₂::AbstractGraph;
    vertex_insert_cost=nothing,
    vertex_delete_cost=nothing,
    vertex_subst_cost=nothing,
    edge_insert_cost=nothing,
    edge_delete_cost=nothing,
    edge_subst_cost=nothing,
    heuristic=nothing,
)
    if isnothing(vertex_insert_cost) &&
        isnothing(vertex_delete_cost) &&
        isnothing(vertex_subst_cost) &&
        isnothing(edge_insert_cost) &&
        isnothing(edge_delete_cost) &&
        isnothing(edge_subst_cost) &&
        isnothing(heuristic)
        heuristic = default_edit_heuristic
    end
    vertex_insert_cost = something(vertex_insert_cost, v -> 0.0)
    vertex_delete_cost = something(vertex_delete_cost, v -> 0.0)
    vertex_subst_cost = something(vertex_subst_cost, (u, v) -> 0.0)
    edge_insert_cost = something(edge_insert_cost, e -> 1.0)
    edge_delete_cost = something(edge_delete_cost, e -> 1.0)
    edge_subst_cost = something(edge_subst_cost, (e1, e2) -> 0.0)
    heuristic = something(heuristic, (λ, G₁, G₂) -> 0.0)
    return _edit_distance(
        G₁::AbstractGraph,
        G₂::AbstractGraph,
        vertex_insert_cost,
        vertex_delete_cost,
        vertex_subst_cost,
        edge_insert_cost,
        edge_delete_cost,
        edge_subst_cost,
        heuristic,
    )
end

function _edit_distance(
    G₁::AbstractGraph{T},
    G₂::AbstractGraph{U},
    vertex_insert_cost::Function,
    vertex_delete_cost::Function,
    vertex_subst_cost::Function,
    edge_insert_cost::Function,
    edge_delete_cost::Function,
    edge_subst_cost::Function,
    heuristic::Function,
) where {T<:Integer,U<:Integer}
    isdirected = is_directed(G₁) || is_directed(G₂)

    # compute the cost on edges due to associate u1 to v1 and u2 to v2
    # u2 and v2 can eventually be 0
    function association_cost(u1, u2, v1, v2)
        cost = 0.0
        if has_edge(G₁, u1, u2)
            if has_edge(G₂, v1, v2)
                cost += edge_subst_cost(Edge(u1, u2), Edge(v1, v2))
            else
                cost += edge_delete_cost(Edge(u1, u2))
            end
        else
            if has_edge(G₂, v1, v2)
                cost += edge_insert_cost(Edge(v1, v2))
            end
        end
        if isdirected && u1 != u2
            if has_edge(G₁, u2, u1)
                if has_edge(G₂, v2, v1)
                    cost += edge_subst_cost(Edge(u2, u1), Edge(v2, v1))
                else
                    cost += edge_delete_cost(Edge(u2, u1))
                end
            else
                if has_edge(G₂, v2, v1)
                    cost += edge_insert_cost(Edge(v2, v1))
                end
            end
        end
        return cost
    end

    # A* search heuristic
    h(λ) = heuristic(λ, G₁, G₂)

    # initialize open set
    OPEN = PriorityQueue{Vector{Tuple},Float64}()
    for v in vertices(G₂)
        enqueue!(OPEN, [(T(1), v)], vertex_subst_cost(1, v) + h([(T(1), v)]))
    end
    enqueue!(OPEN, [(T(1), U(0))], vertex_delete_cost(1) + h([(T(1), U(0))]))

    c = 0
    while true
        # minimum (partial) edit path
        λ, cost = peek(OPEN)
        c += 1
        dequeue!(OPEN)

        if is_complete_path(λ, G₁, G₂)
            return cost, λ
        else
            u1, _ = λ[end]
            u1 += T(1)
            vs = setdiff(vertices(G₂), [v for (u, v) in λ])

            if u1 <= nv(G₁) # there are still vertices to process in G₁?
                # we try every possible assignment of v1
                for v1 in vs
                    λ⁺ = [λ; (u1, v1)]
                    new_cost = cost + vertex_subst_cost(u1, v1) + h(λ⁺) - h(λ)
                    for (u2, v2) in λ
                        new_cost += association_cost(u1, u2, v1, v2)
                    end
                    new_cost += association_cost(u1, u1, v1, v1) # handle self-loops

                    enqueue!(OPEN, λ⁺, new_cost)
                end
                # we try deleting v1
                λ⁺ = [λ; (u1, U(0))]
                new_cost = cost + vertex_delete_cost(u1) + h(λ⁺) - h(λ)
                for u2 in outneighbors(G₁, u1)
                    # edges deleted later when assigning v2
                    u2 > u1 && continue
                    new_cost += edge_delete_cost(Edge(u1, u2))
                end
                if isdirected
                    for u2 in inneighbors(G₁, u1)
                        # edges deleted later when assigning v2, and we should not count a self loop twice
                        u2 >= u1 && continue
                        new_cost += edge_delete_cost(Edge(u2, u1))
                    end
                end
                enqueue!(OPEN, λ⁺, new_cost)
            else
                # add remaining vertices of G₂ to the path by deleting them
                λ⁺ = [λ; [(T(0), v) for v in vs]]
                new_cost = cost + sum(vertex_insert_cost, vs)
                for v1 in vs
                    for v2 in outneighbors(G₂, v1)
                        (v2 > v1 && v2 in vs) && continue # these edges will be deleted later
                        new_cost += edge_insert_cost(Edge(v1, v2))
                    end
                    if isdirected
                        for v2 in inneighbors(G₂, v1)
                            (v2 > v1 && v2 in vs) && continue # these edges will be deleted later
                            v1 == v2 && continue # we should not count a self loop twice
                            new_cost += edge_insert_cost(Edge(v2, v1))
                        end
                    end
                end
                enqueue!(OPEN, λ⁺, new_cost + h(λ⁺) - h(λ))
            end
        end
    end
end

function is_complete_path(λ, G₁, G₂)
    us = Set()
    vs = Set()
    for (u, v) in λ
        push!(us, u)
        push!(vs, v)
    end
    delete!(us, 0)
    delete!(vs, 0)

    return length(us) == nv(G₁) && length(vs) == nv(G₂)
end

# edit_distance(G₁::AbstractGraph, G₂::AbstractGraph) =
#         edit_distance(G₁, G₂,
#             vertex_insert_cost=v -> 0.,
#             vertex_delete_cost=u -> 0.,
#             vertex_subst_cost=(u, v) -> 0.,
#             edge_insert_cost=e -> 1.,
#             edge_delete_cost=e -> 1.,
#             edge_subst_cost=(e1, e2) -> 0.,
#             heuristic=default_edit_heuristic)

"""
compute an upper bound on the number of edges that can still be affected
"""
function default_edit_heuristic(λ, G₁::AbstractGraph, G₂::AbstractGraph)
    us = setdiff(1:nv(G₁), [u for (u, v) in λ])
    vs = setdiff(1:nv(G₂), [v for (u, v) in λ])
    total_free_edges_g1 = 0
    total_free_edges_g2 = 0
    if !isempty(us)
        total_free_edges_g1 = sum(u -> outdegree(G₁, u), us)
    end
    if !isempty(vs)
        total_free_edges_g2 = sum(v -> outdegree(G₂, v), vs)
    end
    for (u1, v1) in λ
        (u1 == 0 || v1 == 0) && continue
        total_free_edges_g1 += count(u2 -> u2 in us, outneighbors(G₁, u1))
        total_free_edges_g2 += count(v2 -> v2 in vs, outneighbors(G₂, v1))
    end
    if !is_directed(G₁) && !is_directed(G₂)
        total_free_edges_g1 = total_free_edges_g1 / 2
        total_free_edges_g2 = total_free_edges_g2 / 2
    end
    return abs(total_free_edges_g1 - total_free_edges_g2)
end

#-------------------------
# Edit path cost functions
#-------------------------

"""
    MinkowskiCost(μ₁, μ₂; p::Real=1)

For labels μ₁ on the vertices of graph G₁ and labels μ₂ on the vertices
of graph G₂, compute the p-norm cost of substituting vertex u ∈ G₁ by
vertex v ∈ G₂.

### Optional Arguments
`p=1`: the p value for p-norm calculation.
"""
function MinkowskiCost(μ₁::AbstractVector, μ₂::AbstractVector; p::Real=1)
    return (u, v) -> norm(μ₁[u] - μ₂[v], p)
end

"""
    BoundedMinkowskiCost(μ₁, μ₂)

Return value similar to [`MinkowskiCost`](@ref), but ensure costs smaller than 2τ.

### Optional Arguments
`p=1`: the p value for p-norm calculation.
`τ=1`: value specifying half of the upper limit of the Minkowski cost.
"""
function BoundedMinkowskiCost(μ₁::AbstractVector, μ₂::AbstractVector; p::Real=1, τ::Real=1)
    return (u, v) -> 1 / (1 / (2τ) + exp(-norm(μ₁[u] - μ₂[v], p)))
end
