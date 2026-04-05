"""
    FrozenVector(v::Vector) <: AbstractVector

A data structure that wraps a `Vector` but does not allow modifications.
"""
struct FrozenVector{T} <: AbstractVector{T}
    wrapped::Vector{T}
end

Base.size(v::FrozenVector) = Base.size(v.wrapped)

Base.@propagate_inbounds Base.getindex(v::FrozenVector, i::Int) = Base.getindex(
    v.wrapped, i
)

Base.IndexStyle(v::Type{FrozenVector{T}}) where {T} = Base.IndexStyle(Vector{T})

Base.iterate(v::FrozenVector) = Base.iterate(v.wrapped)
Base.iterate(v::FrozenVector, state) = Base.iterate(v.wrapped, state)

Base.similar(v::FrozenVector) = Base.similar(v.wrapped)
Base.similar(v::FrozenVector, T::Type) = Base.similar(v.wrapped, T)
Base.similar(v::FrozenVector, T::Type, dims::Base.Dims) = Base.similar(v.wrapped, T, dims)

Base.copy(v::FrozenVector) = Base.copy(v.wrapped)
