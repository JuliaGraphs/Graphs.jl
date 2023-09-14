
"""
    squash(g::Union{SimpleGraph, SimpleDiGraph}; alwayscopy=true)

Specialised version of `Graphs.squash` for `SimpleGraph` and `SimpleDiGraph`.
If `alwayscopy` is `true`, the resulting graph will always be a copy, otherwise
it can also be the original graph.
"""
function Graphs.squash(g::Union{SimpleGraph,SimpleDiGraph}; alwayscopy::Bool=true)
    G = is_directed(g) ? SimpleDiGraph : SimpleGraph
    T = eltype(g)

    (!alwayscopy && T <: Union{Int8,UInt8}) && return g
    nv(g) < typemax(Int8) && return G{Int8}(g)
    nv(g) < typemax(UInt8) && return G{UInt8}(g)
    (!alwayscopy && T <: Union{Int16,UInt16}) && return g
    nv(g) < typemax(Int16) && return G{Int16}(g)
    nv(g) < typemax(UInt16) && return G{UInt16}(g)
    (!alwayscopy && T <: Union{Int32,UInt32}) && return g
    nv(g) < typemax(Int32) && return G{Int32}(g)
    nv(g) < typemax(UInt32) && return G{UInt32}(g)
    (!alwayscopy && T <: Union{Int64,UInt64}) && return g
    nv(g) < typemax(Int64) && return G{Int64}(g)
    nv(g) < typemax(UInt64) && return G{UInt64}(g)

    return alwayscopy ? copy(g) : g
end
