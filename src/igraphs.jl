"""
   IGraphs integration hooks (proof of concept)

Declares the interface pattern for dispatching `Graphs.jl` operations to the
C `igraph` library via the `IGraphs.jl` package, without taking a hard
dependency on it (see JuliaGraphs/Graphs.jl#446).

Pattern:

1. `Graphs.jl` declares a lightweight algorithm trait, e.g.
  `IGraphAlgorithm <: AbstractGraphAlgorithm`, and generic stubs for
  igraph-only algorithms that throw an informative error.
2. `IGraphs.jl` defines concrete subtypes (e.g. `IGraphLouvain()`) and
  methods `f(g::AbstractGraph, alg::IGraphAlgorithm)` that convert `g`
  to an `IGraph` view/copy when needed and `ccall` into `libigraph`.
"""

"""Trait for algorithms whose reference implementation lives in `IGraphs.jl`."""
abstract type IGraphAlgorithm end

_igraphs_hint(fname::Symbol) = error(
   "`Graphs.$(fname)` requires the `IGraphs.jl` package, " *
   "the idiomatic Julia wrapper around the C `igraph` library. " *
   "Install it with `using Pkg; Pkg.add(\"IGraphs\")`, then `using IGraphs` " *
   "and retry. See https://github.com/JuliaGraphs/IGraphs.jl. " *
   "(JuliaGraphs/Graphs.jl#446)",
)

"""
   community_detection_igraph(g::AbstractGraph, alg::IGraphAlgorithm)

Placeholder for igraph-provided community-detection algorithms (e.g. Louvain,
Leiden, Walktrap) not implemented natively in `Graphs.jl`.
The concrete `alg` subtypes and methods are defined in `IGraphs.jl`, which
converts `g` to an `IGraph` graph if necessary before dispatching to C.
"""
function community_detection_igraph end
community_detection_igraph(::AbstractGraph, ::IGraphAlgorithm) =
   _igraphs_hint(:community_detection_igraph)
community_detection_igraph(::AbstractGraph) =
   _igraphs_hint(:community_detection_igraph)

"""
   isomorphism_igraph(g::AbstractGraph, h::AbstractGraph, alg::IGraphAlgorithm)

Placeholder for igraph-provided (sub)graph-isomorphism routines (e.g. VF2/BLISS
variants). Implemented in `IGraphs.jl` via `ccall` to `libigraph`.
"""
function isomorphism_igraph end
isomorphism_igraph(::AbstractGraph, ::AbstractGraph, ::IGraphAlgorithm) =
   _igraphs_hint(:isomorphism_igraph)
isomorphism_igraph(::AbstractGraph, ::AbstractGraph) =
   _igraphs_hint(:isomorphism_igraph)

"""
   to_igraph(g::AbstractGraph) -> Any

Convert `g` to the corresponding `IGraphs.jl` graph type (copy by default;
`IGraphs.jl` may provide zero-copy views). This stub throws an informative
error until `IGraphs.jl` is loaded, which defines the actual method.
"""
function to_igraph end
to_igraph(::AbstractGraph) = _igraphs_hint(:to_igraph)
