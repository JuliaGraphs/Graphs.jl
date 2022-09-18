export RandomVertexCover

struct RandomVertexCover end

"""
    vertex_cover(g, RandomVertexCover(); rng=nothing, seed=nothing)

Find a set of vertices such that every edge in `g` has some vertex in the set as 
atleast one of its end point.

### Implementation Notes
Performs [Approximate Minimum Vertex Cover](https://en.wikipedia.org/wiki/Vertex_cover#Approximate_evaluation) once.
Returns a vector of vertices representing the vertices in the Vertex Cover.

### Performance
Runtime: O(|V|+|E|)
Memory: O(|E|)
Approximation Factor: 2

### Optional Arguments
- `rng=nothing`: set the Random Number Generator.
- If `seed >= 0`, a random generator is seeded with this value.
"""
function vertex_cover(
    g::AbstractGraph{T},
    alg::RandomVertexCover;
    rng::Union{Nothing, AbstractRNG}=nothing, seed::Union{Nothing, Integer}=nothing
) where T <: Integer 

    (ne(g) > 0) || return Vector{T}() #Shuffle raises error
    nvg = nv(g)  
    in_cover = falses(nvg)
    length_cover = 0

    rng = rng_from_rng_or_seed(rng, seed)
    @inbounds for e in shuffle(rng, collect(edges(g)))
        u = src(e)
        v = dst(e)
        if !(in_cover[u] || in_cover[v])
            in_cover[u] = in_cover[v] = true
            length_cover += (v != u ? 2 : 1)
        end
    end

    return Graphs.findall!(in_cover, Vector{T}(undef, length_cover))
end

