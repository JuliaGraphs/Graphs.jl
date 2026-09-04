"""
    canonical_color_refinement(g, alpha, S)

Refine the initial coloring `alpha` of `g` using the refining color set `S`. If `S`
is sufficient, return a canonical coloring of the unique coarsest stable partition
that refines `alpha`. `S` contains labels from `alpha` whose color classes are used
as the initial refiners.

`alpha` is an integer vector of length `nv(g)` assigning an initial color label to
every vertex. Labels may be arbitrary integers; they are ordered and mapped to a dense
internal numbering before refinement. The result is canonical in the sense of the
reference: a color-preserving isomorphism between two inputs preserves the output
color numbers. Thus, for an isomorphism `sigma` from `g1` to `g2`, the initial
colorings must satisfy `alpha2[sigma[v]] == alpha1[v]`; the resulting colorings then
satisfy `color2[sigma[v]] == color1[v]`. Two vertices receive the same color exactly
when the refinement does not distinguish them.

`S` is sufficient if every pair that can be distinguished by an initial color class
can also be distinguished by a class listed in `S`. Passing every distinct label of
`alpha` is always sufficient and produces the unique coarsest stable partition that
refines `alpha`. A smaller set can also be sufficient, but an arbitrary strict subset
may terminate before the coloring is stable. The overloads that omit `S` use every
distinct initial label.

An empty graph (equivalently an empty `alpha`) has no color classes to refine, so it
is returned unchanged as an empty vector regardless of `S`.

This implementation follows the partition-refinement algorithm described in
Berkholz, Bonsma, and Grohe, "Tight Lower and Upper Bounds for the Complexity of
Canonical Colour Refinement". For digraphs, as in the paper's primary stability
definition, color degrees count out-neighbors.

# References

- C. Berkholz, P. Bonsma, M. Grohe, *Tight Lower and Upper Bounds for the
  Complexity of Canonical Colour Refinement*,
  [arXiv:1509.08251](https://arxiv.org/abs/1509.08251)

# Examples
```jldoctest
julia> using Graphs

julia> g = path_graph(5);

julia> canonical_color_refinement(g, ones(Int, 5), [1])
5-element Vector{Int64}:
 1
 3
 2
 3
 1
```
"""
function canonical_color_refinement(
    g::AbstractGraph, alpha::AbstractVector{<:Integer}, S::AbstractVector{<:Integer}
)::Vector{Int}
    n = nv(g)

    length(alpha) == n ||
        throw(ArgumentError("Initial coloring alpha must have length nv(g)"))

    isempty(alpha) && return Int[]

    colour_labels = Int.(alpha)

    # Map labels in sorted order so the dense internal IDs do not depend on vertex
    # numbering.
    color_to_id = Dict(
        label => id for (id, label) in enumerate(sort(unique(colour_labels)))
    )
    colour = Vector{Int}(undef, n)
    for v in 1:n
        colour[v] = color_to_id[colour_labels[v]]
    end

    refining_color_ids = Int[]
    for c in S
        label = Int(c)
        if !haskey(color_to_id, label)
            throw(
                ArgumentError("Refining color set S must contain labels present in alpha")
            )
        end
        push!(refining_color_ids, color_to_id[label])
    end

    k = length(color_to_id)

    # `C[c]` stores color class `c` as a set, allowing each moved vertex to be removed
    # in O(1) time. During a refinement round, `A[c]` stores the vertices in class `c`
    # with nonzero color degree. `maxcdeg` and `mincdeg` track the color-degree range
    # of each affected class.
    C = [Set{Int}() for _ in 1:n]
    A = [Vector{Int}() for _ in 1:n]
    maxcdeg = zeros(Int, n)
    mincdeg = zeros(Int, n)

    cdeg = zeros(Int, n)

    for v in 1:n
        push!(C[colour[v]], v)
    end

    # Initialize the stack of refining color classes. Sorting gives a canonical
    # processing order, while deduplication treats `S` as a mathematical set.
    S_sorted = sort!(unique!(refining_color_ids))
    Srefine = Vector{Int}()
    in_stack = falses(n)
    for c in S_sorted
        push!(Srefine, c)
        in_stack[c] = true
    end

    # Buffers reused across iterations to avoid allocations.
    Colorsadj = Vector{Int}()
    in_Colorsadj = falses(n)
    Colorssplit = Vector{Int}()

    numcdeg = zeros(Int, n + 1)
    f = zeros(Int, n + 1)

    while !isempty(Srefine)
        r = pop!(Srefine)
        in_stack[r] = false

        # 1. For refining class `C[r]`, compute
        #    `cdeg[w] = |outneighbors(g, w) ∩ C[r]|`. Iterating over the
        #    in-neighbors of each vertex in `C[r]` counts exactly these outgoing
        #    edges. For undirected graphs, in- and out-neighbors coincide.
        for v in C[r]
            for w in inneighbors(g, v)
                cdeg[w] += 1
                if cdeg[w] == 1
                    push!(A[colour[w]], w)
                end

                if !in_Colorsadj[colour[w]]
                    push!(Colorsadj, colour[w])
                    in_Colorsadj[colour[w]] = true
                end

                if cdeg[w] > maxcdeg[colour[w]]
                    maxcdeg[colour[w]] = cdeg[w]
                end
            end
        end

        # 2. Find the color-degree range of every affected class. A class splits
        #    exactly when its minimum and maximum color degrees differ.
        empty!(Colorssplit)
        for c in Colorsadj
            if length(C[c]) != length(A[c])
                mincdeg[c] = 0
            else
                mincdeg[c] = maxcdeg[c]
                for v in A[c]
                    if cdeg[v] < mincdeg[c]
                        mincdeg[c] = cdeg[v]
                    end
                end
            end

            if mincdeg[c] < maxcdeg[c]
                push!(Colorssplit, c)
            end
        end

        sort!(Colorssplit)

        # 3. Split each affected class by color degree (Algorithm 3,
        #    SplitUpColour).
        for s in Colorssplit
            k = _split_up_colour!(
                s, k, C, A, colour, cdeg, maxcdeg, mincdeg, numcdeg, f, Srefine, in_stack
            )
        end

        # 4. Clear the state accumulated during this refinement round.
        for c in Colorsadj
            for v in A[c]
                cdeg[v] = 0
            end
            maxcdeg[c] = 0
            empty!(A[c])
            in_Colorsadj[c] = false
        end
        empty!(Colorsadj)
    end

    return colour
end

"""
    canonical_color_refinement(g)

Return the stable coloring of `g` using the unit coloring and refining color class 1.
"""
function canonical_color_refinement(g::AbstractGraph)
    canonical_color_refinement(g, ones(Int, nv(g)), [1])
end

"""
    canonical_color_refinement(g, alpha)

Return the coarsest stable coloring that refines `alpha`, using every distinct
initial label as the refining color set.
"""
function canonical_color_refinement(g::AbstractGraph, alpha::AbstractVector{<:Integer})
    canonical_color_refinement(g, alpha, sort(unique(alpha)))
end

"""
    canonical_color_refinement(g, alpha, S)

Refine `alpha` using the single refining color `S`.
"""
function canonical_color_refinement(
    g::AbstractGraph, alpha::AbstractVector{<:Integer}, S::Integer
)
    canonical_color_refinement(g, alpha, [S])
end

"""
    canonical_color_refinement(g, S)

Refine the unit coloring using the provided refining color.
"""
function canonical_color_refinement(g::AbstractGraph, S::Integer)
    canonical_color_refinement(g, ones(Int, nv(g)), [S])
end

"""
    color_refinement(g, alpha, S)

Convenience alias for [`canonical_color_refinement`](@ref) that returns the same
stable coloring with a shorter name.
"""
function color_refinement(
    g::AbstractGraph, alpha::AbstractVector{<:Integer}, S::AbstractVector{<:Integer}
)::Vector{Int}
    return canonical_color_refinement(g, alpha, S)
end

"""
    color_refinement(g)

Convenience wrapper that uses the unit coloring and refines color class 1.
"""
color_refinement(g::AbstractGraph) = color_refinement(g, ones(Int, nv(g)), [1])

"""
    color_refinement(g, alpha)

Convenience wrapper that uses every distinct label of `alpha` as the refining color
set.
"""
function color_refinement(g::AbstractGraph, alpha::AbstractVector{<:Integer})
    color_refinement(g, alpha, sort(unique(alpha)))
end

"""
    color_refinement(g, alpha, S)

Convenience wrapper that accepts one refining color and builds the corresponding
one-element refining color set.
"""
function color_refinement(g::AbstractGraph, alpha::AbstractVector{<:Integer}, S::Integer)
    color_refinement(g, alpha, [S])
end

"""
    color_refinement(g, S)

Convenience wrapper that uses the unit coloring and the provided refining color.
"""
color_refinement(g::AbstractGraph, S::Integer) = color_refinement(g, ones(Int, nv(g)), [S])

"""
    _split_up_colour!(s, k, C, A, colour, cdeg, maxcdeg, mincdeg, numcdeg, f, Srefine, in_stack)

Split color class `s` into one class for each distinct color degree (Algorithm 3,
SplitUpColour), updating the partition in place. If `s` is not already in the stack
of refining classes, its largest fragment is omitted from `Srefine`. This is
Hopcroft's smaller-half optimization: every added fragment then contains at most half
as many vertices as its parent, which yields the logarithmic complexity factor.

`k` is the current number of colors; new color IDs are assigned as `k + 1, k + 2, …`.
Returns the updated color counter `k`. `numcdeg` and `f` are scratch buffers (length
`≥ maxcdeg[s] + 1`) owned by the caller and reused across calls to avoid allocations.
"""
function _split_up_colour!(
    s::Int,
    k::Int,
    C::Vector{Set{Int}},
    A::Vector{Vector{Int}},
    colour::Vector{Int},
    cdeg::Vector{Int},
    maxcdeg::Vector{Int},
    mincdeg::Vector{Int},
    numcdeg::Vector{Int},
    f::Vector{Int},
    Srefine::Vector{Int},
    in_stack::AbstractVector{Bool},
)
    maxcdeg_s = maxcdeg[s]

    # Count the vertices at each color degree; index `i + 1` represents degree `i`.
    for i in 1:maxcdeg_s
        numcdeg[i + 1] = 0
    end
    numcdeg[1] = length(C[s]) - length(A[s]) # vertices of color degree zero

    for v in A[s]
        numcdeg[cdeg[v] + 1] += 1
    end

    # `b` is the smallest color degree whose fragment has maximum size. This
    # deterministic tie-break is required for canonical color assignment.
    b = 0
    for i in 1:maxcdeg_s
        if numcdeg[i + 1] > numcdeg[b + 1]
            b = i
        end
    end

    instack = in_stack[s] ? 1 : 0

    # Assign an internal color ID `f[i + 1]` to each occurring color degree `i`.
    for i in 0:maxcdeg_s
        if numcdeg[i + 1] >= 1
            if i == mincdeg[s]
                f[i + 1] = s
                if instack == 0 && b != i
                    push!(Srefine, f[i + 1])
                    in_stack[f[i + 1]] = true
                end
            else
                k += 1
                f[i + 1] = k
                if instack == 1 || i != b
                    push!(Srefine, f[i + 1])
                    in_stack[f[i + 1]] = true
                end
            end
        end
    end

    # Move vertices to their new color classes.
    for v in A[s]
        target_color = f[cdeg[v] + 1]
        if target_color != s
            delete!(C[s], v)
            push!(C[target_color], v)
            colour[v] = target_color
        end
    end

    return k
end
