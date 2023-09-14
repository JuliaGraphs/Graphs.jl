"""
    simplecycles_hawick_james(g)

Find circuits (including self-loops) in `g` using the algorithm
of Hawick & James.

### References
- Hawick & James, "Enumerating Circuits and Loops in Graphs with Self-Arcs and Multiple-Arcs", 2008
"""
function simplecycles_hawick_james end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function simplecycles_hawick_james(
    g::AG::IsDirected
) where {T,AG<:AbstractGraph{T}}
    nvg = nv(g)
    B = Vector{T}[Vector{T}() for i in vertices(g)]
    blocked = zeros(Bool, nvg)
    stack = Vector{T}()
    cycles = Vector{Vector{T}}()
    for v in vertices(g)
        circuit_recursive!(g, v, v, blocked, B, stack, cycles)
        resetblocked!(blocked)
        resetB!(B)
    end
    return cycles
end

"""
    resetB!(B)

Reset B work structure.
"""
resetB!(B) = map!(empty!, B, B)

"""
    resetblocked!(blocked)

Reset vector of `blocked` vertices.
"""
resetblocked!(blocked) = fill!(blocked, false)

"""
    circuit_recursive!(g, v1, v2, blocked, B, stack, cycles)

Find circuits in `g` recursively starting from v1.
"""
function circuit_recursive! end
@traitfn function circuit_recursive!(
    g::::IsDirected,
    v1::T,
    v2::T,
    blocked::AbstractVector,
    B::Vector{Vector{T}},
    stack::Vector{T},
    cycles::Vector{Vector{T}},
) where {T<:Integer}
    f = false
    push!(stack, v2)
    blocked[v2] = true

    Av = outneighbors(g, v2)
    for w in Av
        (w < v1) && continue
        if w == v1 # Found a circuit
            push!(cycles, copy(stack))
            f = true
        elseif !blocked[w]
            f |= circuit_recursive!(g, v1, w, blocked, B, stack, cycles)
        end
    end
    if f
        unblock!(v2, blocked, B)
    else
        for w in Av
            (w < v1) && continue
            if !(v2 in B[w])
                push!(B[w], v2)
            end
        end
    end
    pop!(stack)
    return f
end

"""
    unblock!(v, blocked, B)

Unblock the value `v` from the `blocked` list and remove from `B`.
"""
function unblock!(v::T, blocked::AbstractVector, B::Vector{Vector{T}}) where {T}
    blocked[v] = false
    wPos = 1
    Bv = B[v]
    while wPos <= length(Bv)
        w = Bv[wPos]
        old_length = length(Bv)
        filter!(v -> v != w, Bv)
        wPos += 1 - (old_length - length(Bv))
        if blocked[w]
            unblock!(w, blocked, B)
        end
    end
    return nothing
end
