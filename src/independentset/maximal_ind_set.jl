export MaximalIndependentSet

struct MaximalIndependentSet end

"""
    independent_set(g, MaximalIndependentSet(); rng=nothing, seed=nothing)

Find a random set of vertices that are independent (no two vertices are adjacent to each other) and 
it is not possible to insert a vertex into the set without sacrificing the independence property.

### Implementation Notes
Performs [Approximate Maximum Independent Set](https://en.wikipedia.org/wiki/Maximal_independent_set#Sequential_algorithm) once.
Returns a vector of vertices representing the vertices in the independent set.

### Performance
Runtime: O(|V|+|E|)
Memory: O(|V|)
Approximation Factor: maximum(degree(g))+1

### Optional Arguments
- `rng=nothing`: set the Random Number Generator.
- If `seed >= 0`, a random generator is seeded with this value.
"""
function independent_set(
    g::AbstractGraph{T},
    alg::MaximalIndependentSet;
    rng::Union{Nothing, AbstractRNG}=nothing, seed::Union{Nothing, Integer}=nothing
    ) where T <: Integer 
  
    rng = rng_from_rng_or_seed(rng, seed)
    nvg = nv(g)
    ind_set = Vector{T}()
    sizehint!(ind_set, nvg)  
    deleted = falses(nvg)

    for v in randperm(rng, nvg)
        (deleted[v] || has_edge(g, v, v)) && continue

        deleted[v] = true
        push!(ind_set, v)
        deleted[neighbors(g, v)] .= true
    end

    return ind_set
end
