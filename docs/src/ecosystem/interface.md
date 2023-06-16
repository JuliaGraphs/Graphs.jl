# Creating your own graph format

This section is designed to guide developers who wish to write their own graph structures.

All Graphs.jl functions rely on a standard API to function. As long as your graph structure is a subtype of [`AbstractGraph`](@ref) and implements the following API functions with the given return values, all functions within the Graphs.jl package should just work:

- [`edges`](@ref)
- [`edgetype`](@ref) (example: `edgetype(g::CustomGraph) = Graphs.SimpleEdge{eltype(g)})`)
- [`has_edge`](@ref)
- [`has_vertex`](@ref)
- [`inneighbors`](@ref)
- [`ne`](@ref)
- [`nv`](@ref)
- [`outneighbors`](@ref)
- [`vertices`](@ref)
- [`is_directed`](@ref): Note that since Graphs uses traits to determine directedness, `is_directed` for a `CustomGraph` type should be implemented with **both** of the following signatures:
  - `is_directed(::Type{CustomGraph})::Bool` (example: `is_directed(::Type{<:CustomGraph}) = false`)
  - `is_directed(g::CustomGraph)::Bool`

If the graph structure is designed to represent weights on edges, the [`weights`](@ref) function should also be defined. Note that the output does not necessarily have to be a dense matrix, but it must be a subtype of `AbstractMatrix{<:Real}` and indexable via `[u, v]`.

**Note on inheriting from AbstractSimpleGraph**

Every subtype of `AbstractSimpleGraph` must have vertices forming a `UnitRange` starting from 1 and return `neighbors` in ascending order. The extend to which code for graph types other than subtypes of `AbstractSimpleGraph` does not rely on `AbstractSimpleGraph` assumptions needs to be carefully checked, though in principle the requirement is only part of the `AbstractSimpleGraph` API.
