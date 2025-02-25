"""
    AlgNautyGraphs

An empty concrete type used to dispatch to [`NautyGraphs`](@ref) isomorphism functions.
"""
struct AlgNautyGraphs <: IsomorphismAlgorithm end

# The implementation of NautyGraph methods for graph isomorphism is done as a package extension in /ext/NautyGraphsExt.jl