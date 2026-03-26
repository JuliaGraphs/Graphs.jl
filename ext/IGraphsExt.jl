module IGraphsExt

using Graphs
using IGraphs
using LinearAlgebra
using IGraphs: LibIGraph

import Graphs: igraph, IGraphAlgorithm
import Graphs:
    sir_model,
    layout_kamada_kawai,
    layout_fruchterman_reingold,
    community_leiden,
    modularity_matrix

function _check_ret(ret, funcname)
    if ret != LibIGraph.IGRAPH_SUCCESS
        error("$funcname failed with error code $ret")
    end
end

# --- Conversion ---

"""
    igraph(g::AbstractSimpleGraph)

Fast conversion from `Graphs.SimpleGraph`/`SimpleDiGraph` to `IGraphs.IGraph`.
Uses `igraph_add_edges` for high performance.
"""
function igraph(g::Graphs.AbstractSimpleGraph)
    n = Graphs.nv(g)
    ig = IGraphs.IGraph(; _uninitialized=Val(true))
    _check_ret(LibIGraph.igraph_empty(ig.objref, n, Graphs.is_directed(g)), "igraph_empty")
    m = Graphs.ne(g)
    if m > 0
        edges_vec = Vector{Int64}(undef, 2*m)
        for (i, e) in enumerate(Graphs.edges(g))
            edges_vec[2 * i - 1] = Graphs.src(e) - 1
            edges_vec[2 * i] = Graphs.dst(e) - 1
        end
        v_edges = IGraphs.IGVectorInt(edges_vec)
        ret = LibIGraph.igraph_add_edges(ig.objref, v_edges.objref, IGraphs.IGNull().objref)
        _check_ret(ret, "igraph_add_edges")
    end
    return ig
end

# Identity conversion
igraph(g::IGraphs.IGraph) = g

# Fallback for other AbstractGraph types
igraph(g::Graphs.AbstractGraph) = IGraphs.IGraph(g)

# --- Missing Graphs.jl interface methods for IGraph ---
# IGraphs.jl already provides: nv, ne, has_edge, has_vertex, vertices, edgetype, eltype
# We add the missing ones: edges, inneighbors, outneighbors, is_directed (instance method)

function Graphs.edges(g::IGraphs.IGraph)
    m = Graphs.ne(g)
    if m == 0
        return Graphs.SimpleGraphs.SimpleEdge{eltype(g)}[]
    end
    v_edges = IGraphs.IGVectorInt(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_int_init(v_edges.objref, 2 * m)
    LibIGraph.igraph_get_edgelist(g.objref, v_edges.objref, false)
    edge_list = Vector(v_edges)
    ET = Graphs.edgetype(g)
    return [ET(edge_list[2 * i - 1]+1, edge_list[2 * i]+1) for i in 1:m]
end

# Instance method for is_directed (IGraphs only defines the Type method)
Graphs.is_directed(g::IGraphs.IGraph) = Bool(LibIGraph.igraph_is_directed(g.objref))

function Graphs.outneighbors(g::IGraphs.IGraph, v::Integer)
    res = IGraphs.IGVectorInt(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_int_init(res.objref, 0)
    mode = Graphs.is_directed(g) ? LibIGraph.IGRAPH_OUT : LibIGraph.IGRAPH_ALL
    ret = LibIGraph.igraph_neighbors(
        g.objref,
        res.objref,
        v-1,
        mode,
        LibIGraph.IGRAPH_NO_LOOPS,
        LibIGraph.IGRAPH_NO_MULTIPLE,
    )
    _check_ret(ret, "igraph_neighbors (out)")
    return sort!([Int(x) + 1 for x in Vector(res)])
end

function Graphs.inneighbors(g::IGraphs.IGraph, v::Integer)
    res = IGraphs.IGVectorInt(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_int_init(res.objref, 0)
    mode = Graphs.is_directed(g) ? LibIGraph.IGRAPH_IN : LibIGraph.IGRAPH_ALL
    ret = LibIGraph.igraph_neighbors(
        g.objref,
        res.objref,
        v-1,
        mode,
        LibIGraph.IGRAPH_NO_LOOPS,
        LibIGraph.IGRAPH_NO_MULTIPLE,
    )
    _check_ret(ret, "igraph_neighbors (in)")
    return sort!([Int(x) + 1 for x in Vector(res)])
end

# Helper to handle weights
function _handle_weights(weights)
    if weights === nothing
        return IGraphs.IGNull()
    else
        return IGraphs.IGVectorFloat(weights)
    end
end

# --- Algorithm Implementations ---

function sir_model(
    g::Graphs.AbstractGraph, ::IGraphAlgorithm; beta=0.1, gamma=0.1, no_sim=100
)
    ig = igraph(g)

    ptr_vec = Ref{LibIGraph.igraph_vector_ptr_t}()
    LibIGraph.igraph_vector_ptr_init(ptr_vec, 0)

    try
        ret = LibIGraph.igraph_sir(ig.objref, beta, gamma, no_sim, ptr_vec)
        _check_ret(ret, "igraph_sir")

        n_sim = LibIGraph.igraph_vector_ptr_size(ptr_vec)
        results = Vector{Vector{Float64}}(undef, n_sim)

        for i in 1:n_sim
            v_ptr = LibIGraph.igraph_vector_ptr_get(ptr_vec, i-1)
            v_ptr_typed = reinterpret(Ptr{LibIGraph.igraph_vector_t}, v_ptr)
            v_size = Int(LibIGraph.igraph_vector_size(v_ptr_typed))
            res_v = Vector{Float64}(undef, v_size)
            for j in 1:v_size
                res_v[j] = Float64(LibIGraph.igraph_vector_get(v_ptr_typed, j-1))
            end
            results[i] = res_v
        end
        return results
    finally
        LibIGraph.igraph_vector_ptr_destroy_all(ptr_vec)
    end
end

function modularity_matrix(g::Graphs.AbstractGraph, ::IGraphAlgorithm; kwargs...)
    ig = igraph(g)
    return IGraphs.modularity_matrix(ig; kwargs...)
end

function community_leiden(
    g::Graphs.AbstractGraph,
    ::IGraphAlgorithm;
    resolution=1.0,
    beta=0.01,
    n_iterations=10,
    kwargs...,
)
    ig = igraph(g)
    membership = IGraphs.IGVectorInt(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_int_init(membership.objref, 0)

    nb_clusters = Ref{LibIGraph.igraph_int_t}(0)
    quality = Ref{LibIGraph.igraph_real_t}(0.0)

    ret = LibIGraph.igraph_community_leiden_simple(
        ig.objref,
        IGraphs.IGNull().objref,
        0,
        resolution,
        beta,
        IGraphs.IGNull().objref,
        n_iterations,
        membership.objref,
        nb_clusters,
        quality,
    )
    _check_ret(ret, "igraph_community_leiden_simple")
    return Vector(membership)
end

function layout_kamada_kawai(
    g::Graphs.AbstractGraph,
    ::IGraphAlgorithm;
    maxiter=100,
    epsilon=0.0,
    kkconst=0.0,
    kwargs...,
)
    ig = igraph(g)
    n = Graphs.nv(g)
    res = IGraphs.IGMatrixFloat(; _uninitialized=Val(true))
    LibIGraph.igraph_matrix_init(res.objref, n, 2)
    ret = LibIGraph.igraph_layout_kamada_kawai(
        ig.objref,
        res.objref,
        false,
        maxiter,
        epsilon,
        kkconst,
        IGraphs.IGNull().objref,
        -100.0,
        100.0,
        -100.0,
        100.0,
    )
    _check_ret(ret, "igraph_layout_kamada_kawai")
    return Matrix(res)
end

function layout_fruchterman_reingold(
    g::Graphs.AbstractGraph, ::IGraphAlgorithm; niter=500, kwargs...
)
    ig = igraph(g)
    n = Graphs.nv(g)
    res = IGraphs.IGMatrixFloat(; _uninitialized=Val(true))
    LibIGraph.igraph_matrix_init(res.objref, n, 2)
    ret = LibIGraph.igraph_layout_fruchterman_reingold(
        ig.objref,
        res.objref,
        false,
        niter,
        IGraphs.IGNull().objref,
        -100.0,
        100.0,
        -100.0,
        100.0,
    )
    _check_ret(ret, "igraph_layout_fruchterman_reingold")
    return Matrix(res)
end

function Graphs.betweenness_centrality(
    g::Graphs.AbstractGraph, ::IGraphAlgorithm; weights=nothing, normalized=true, kwargs...
)
    ig = igraph(g)
    n = Graphs.nv(g)
    res = IGraphs.IGVectorFloat(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_init(res.objref, n)
    w = _handle_weights(weights)

    ret = LibIGraph.igraph_betweenness(
        ig.objref,
        w.objref,
        res.objref,
        LibIGraph.igraph_vss_all(),
        Graphs.is_directed(g),
        normalized,
    )
    _check_ret(ret, "igraph_betweenness")

    return Vector(res)
end

function Graphs.pagerank(
    g::Graphs.AbstractGraph{U}, ::IGraphAlgorithm; damping=0.85, weights=nothing, kwargs...
) where {U<:Integer}
    ig = igraph(g)
    n = Graphs.nv(g)
    res = IGraphs.IGVectorFloat(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_init(res.objref, n)
    w = _handle_weights(weights)

    val = Ref{LibIGraph.igraph_real_t}(0.0)
    ret = LibIGraph.igraph_pagerank(
        ig.objref,
        w.objref,
        res.objref,
        val,
        damping,
        Graphs.is_directed(g),
        LibIGraph.igraph_vss_all(),
        LibIGraph.IGRAPH_PAGERANK_ALGO_PRPACK,
        IGraphs.IGNull().objref,
    )
    _check_ret(ret, "igraph_pagerank")
    return Vector(res)
end

end # module
