"""
    canonical_color_refinement(g, alpha, S)

Return the stable coloring of `g` produced by the 1-dimensional Weisfeiler-Leman
(color refinement) algorithm, starting from the initial coloring `alpha` and refining
only the color classes whose ids are listed in `S`.

`alpha` is an integer vector of length `nv(g)` assigning an initial color label to
every vertex. The labels may be arbitrary integers; the implementation maps them to a
dense internal numbering for the refinement steps. `S` lists the initial color labels
that seed the refinement worklist. The output is a canonical relabeling of the stable
partition: colors are assigned `1, 2, …` in order of first appearance over the
vertices, independent of the values of `alpha`. Two vertices share a color iff color
refinement cannot distinguish them.

`S` lists the labels of the initial color classes (from `alpha`) that seed the
refinement worklist; any classes those seeds later split into are refined as well.
Seeding `S` with every distinct label of `alpha` always produces the coarsest stable
coloring — the partition that no further refinement can change. Seeding a strict
subset may stop the worklist early: classes that are neither seeded nor split are
never processed, so the result may not be fully stable. To guarantee the coarsest
stable coloring, pass every distinct label of `alpha` in `S`.

An empty graph (equivalently an empty `alpha`) has no color classes to refine, so it
is returned unchanged as an empty vector regardless of `S`.

This implementation follows the worklist-based refinement strategy described in
Berkholz, Bonsma, and Grohe, "Tight Lower and Upper Bounds for the Complexity of
Canonical Colour Refinement", which defines the algorithm for undirected graphs.
On a directed graph, each refinement step only splits classes by out-edge
structure (how many out-edges a vertex has into the class being processed); it
does not split on in-edge structure, so two vertices with identical
out-neighbors but different in-neighbors are not distinguished.

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
 2
 3
 2
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
    color_to_id = Dict{Int,Int}()
    colour = Vector{Int}(undef, n)
    for v in 1:n
        label = colour_labels[v]
        id = get(color_to_id, label, 0)
        if id == 0
            id = length(color_to_id) + 1
            color_to_id[label] = id
        end
        colour[v] = id
    end

    seed_ids = Int[]
    for c in S
        label = Int(c)
        if !haskey(color_to_id, label)
            throw(ArgumentError("Refinement seeds S must contain color ids present in alpha"))
        end
        push!(seed_ids, color_to_id[label])
    end

    k = length(color_to_id)

    # Core data structures. `C[c]` stores the vertices of color `c` as a set so that
    # splits can be performed in O(1) time per moved vertex. `A[c]` collects the
    # vertices of color `c` that have been observed in the current refinement round.
    # `maxcdeg` and `mincdeg` track the color-degree range for each color class.
    # The internal color ids are dense and may grow up to `n`, so the work arrays are
    # sized for the full vertex count.
    C = [Set{Int}() for _ in 1:n]
    A = [Vector{Int}() for _ in 1:n]
    maxcdeg = zeros(Int, n)
    mincdeg = zeros(Int, n)

    cdeg = zeros(Int, n)

    for v in 1:n
        push!(C[colour[v]], v)
    end

    # Worklist of colors to refine, with a parallel boolean array for O(1) membership.
    S_sorted = sort(seed_ids)
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

    # Scratch arrays used by the split routine; degrees range over 0:n, hence n + 1.
    numcdeg = zeros(Int, n + 1)
    f = zeros(Int, n + 1)

    while !isempty(Srefine)
        r = pop!(Srefine)
        in_stack[r] = false

        # 1. Compute the color degree of each vertex adjacent to a vertex of color `r`.
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

        # 2. Determine the minimum and maximum color-degree values per adjacent color
        #    and identify which colors actually split.
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

        # 3. Split each color class by color degree (SplitUpColour).
        for s in Colorssplit
            k = _split_up_colour!(
                s,
                k,
                C,
                A,
                colour,
                cdeg,
                maxcdeg,
                mincdeg,
                numcdeg,
                f,
                Srefine,
                in_stack,
            )
        end

        # 4. Reset the per-iteration state for the next refinement round.
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

    # Canonical relabel: colors 1, 2, … in order of first appearance over the
    # vertices, so the output depends only on the stable partition, not on `alpha`.
    remap = Dict{Int,Int}()
    out = Vector{Int}(undef, n)
    for v in 1:n
        c = colour[v]
        id = get(remap, c, 0)
        if id == 0
            id = length(remap) + 1
            remap[c] = id
        end
        out[v] = id
    end
    return out
end

"""
    canonical_color_refinement(g)

Return the stable coloring of `g` using the unit coloring and refining color class 1.
"""
canonical_color_refinement(g::AbstractGraph) = canonical_color_refinement(g, ones(Int, nv(g)), [1])

"""
    canonical_color_refinement(g, alpha)

Return the stable coloring of `g` using the provided initial coloring `alpha` and the
unit refinement seed `[1]`.
"""
canonical_color_refinement(g::AbstractGraph, alpha::AbstractVector{<:Integer}) =
    canonical_color_refinement(g, alpha, [1])

"""
    canonical_color_refinement(g, alpha, S)

Return the stable coloring of `g` using the provided initial coloring `alpha` and a
scalar refinement seed `S`.
"""
canonical_color_refinement(
    g::AbstractGraph, alpha::AbstractVector{<:Integer}, S::Integer
) = canonical_color_refinement(g, alpha, [S])

"""
    canonical_color_refinement(g, S)

Return the stable coloring of `g` using the unit coloring and refining the provided
seed color.
"""
canonical_color_refinement(g::AbstractGraph, S::Integer) =
    canonical_color_refinement(g, ones(Int, nv(g)), [S])

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

Convenience wrapper that uses the provided initial coloring `alpha` and the unit
refinement seed `[1]`.
"""
color_refinement(g::AbstractGraph, alpha::AbstractVector{<:Integer}) =
    color_refinement(g, alpha, [1])

"""
    color_refinement(g, alpha, S)

Convenience wrapper that accepts a scalar refinement seed and builds the
corresponding one-element seed vector.
"""
color_refinement(g::AbstractGraph, alpha::AbstractVector{<:Integer}, S::Integer) =
    color_refinement(g, alpha, [S])

"""
    color_refinement(g, S)

Convenience wrapper that uses the unit coloring and refines the provided seed color.
"""
color_refinement(g::AbstractGraph, S::Integer) = color_refinement(g, ones(Int, nv(g)), [S])

"""
    _split_up_colour!(s, k, C, A, colour, cdeg, maxcdeg, mincdeg, numcdeg, f, Srefine, in_stack)

Split color class `s` into one new class per distinct color degree (Algorithm 3,
SplitUpColour), updating the partition in place and pushing the resulting fragments
onto the refinement worklist as needed.

`k` is the current number of colors in use; new color ids are minted as `k + 1, k + 2, …`.
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

    # Count how many vertices fall into each color degree (index i+1 holds degree i).
    for i in 1:maxcdeg_s
        numcdeg[i + 1] = 0
    end
    numcdeg[1] = length(C[s]) - length(A[s]) # vertices with color degree 0

    for v in A[s]
        numcdeg[cdeg[v] + 1] += 1
    end

    # Majority color-degree class b keeps the most vertices.
    b = 0
    for i in 1:maxcdeg_s
        if numcdeg[i + 1] > numcdeg[b + 1]
            b = i
        end
    end

    instack = in_stack[s] ? 1 : 0

    # Assign new color labels f[i] to each occurring color degree i.
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
