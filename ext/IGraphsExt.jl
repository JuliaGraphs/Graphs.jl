module IGraphsExt

using Graphs
using IGraphs
using LinearAlgebra
using IGraphs: LibIGraph

import Graphs: igraph, AbstractIGraph, IGraphAlgorithm
import Graphs: sir_model, layout_kamada_kawai, layout_fruchterman_reingold, community_leiden, modularity_matrix
import Graphs: betweenness_centrality, pagerank
import Graphs: nv, ne, is_directed, vertices, edges, has_vertex, has_edge, inneighbors, outneighbors, edgetype, eltype

# Note: IGraphs wrappers (IGraph, IGVectorInt, etc.) store the underlying C struct 
# in an `objref` field which is a Ref{LibIGraph.ctype}.

function _check_ret(ret, funcname)
    if ret != LibIGraph.IGRAPH_SUCCESS
        error("$funcname failed with error code $ret")
    end
end

"""
    igraph(g::AbstractSimpleGraph)

Fast conversion from `Graphs.SimpleGraph` to `IGraphs.IGraph`.
Uses `igraph_add_edges` for high performance.
"""
function igraph(g::Graphs.AbstractSimpleGraph)
    n = Graphs.nv(g)
    ig = IGraphs.IGraph(n; directed=Graphs.is_directed(g))
    m = Graphs.ne(g)
    edges_vec = Vector{Int64}(undef, 2*m)
    for (i, e) in enumerate(Graphs.edges(g))
        edges_vec[2*i-1] = Graphs.src(e) - 1
        edges_vec[2*i] = Graphs.dst(e) - 1
    end
    # Create the IGVectorInt wrapper
    v_edges = IGraphs.IGVectorInt(edges_vec)
    # Add edges in bulk using .objref to pass the underlying Ref to ccall
    ret = LibIGraph.igraph_add_edges(ig.objref, v_edges.objref, IGraphs.IGNull().objref)
    _check_ret(ret, "igraph_add_edges")
    return ig
end

# --- Graph API Implementation for AbstractIGraph ---

Graphs.nv(g::AbstractIGraph) = Int(LibIGraph.igraph_vcount(g.objref))
Graphs.ne(g::AbstractIGraph) = Int(LibIGraph.igraph_ecount(g.objref))
Graphs.is_directed(g::AbstractIGraph) = Bool(LibIGraph.igraph_is_directed(g.objref))

Graphs.vertices(g::AbstractIGraph) = 1:nv(g)

function Graphs.edges(g::AbstractIGraph)

    m = ne(g)
    v_edges = IGraphs.IGVectorInt(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_int_init(v_edges.objref, 2 * m)
    LibIGraph.igraph_get_edgelist(g.objref, v_edges.objref, false)
    edge_list = Vector(v_edges)
    ET = edgetype(g)
    return [ET(edge_list[2*i-1]+1, edge_list[2*i]+1) for i in 1:m]
end

Graphs.has_vertex(g::AbstractIGraph, v::Integer) = 1 <= v <= nv(g)

function Graphs.has_edge(g::AbstractIGraph, u::Integer, v::Integer)
    eid = Ref{LibIGraph.igraph_integer_t}(-1)
    ret = LibIGraph.igraph_get_eid(g.objref, eid, u-1, v-1, is_directed(g), false)
    return eid[] != -1
end

function Graphs.outneighbors(g::AbstractIGraph, v::Integer)
    res = IGraphs.IGVectorInt(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_int_init(res.objref, 0)
    # IGRAPH_OUT = 1
    ret = LibIGraph.igraph_neighbors(g.objref, res.objref, v-1, 1)
    _check_ret(ret, "igraph_neighbors (out)")
    return [Int(x) + 1 for x in Vector(res)]
end

function Graphs.inneighbors(g::AbstractIGraph, v::Integer)
    res = IGraphs.IGVectorInt(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_int_init(res.objref, 0)
    # IGRAPH_IN = 2
    ret = LibIGraph.igraph_neighbors(g.objref, res.objref, v-1, 2)
    _check_ret(ret, "igraph_neighbors (in)")
    return [Int(x) + 1 for x in Vector(res)]
end

Graphs.neighbors(g::AbstractIGraph, v::Integer) = outneighbors(g, v)

Graphs.edgetype(g::AbstractIGraph) = Graphs.SimpleGraphs.SimpleEdge{Int}
Graphs.eltype(g::AbstractIGraph) = Int

# Fallback for other graph types
igraph(g::AbstractGraph) = IGraphs.IGraph(g)

# Helper to handle weights
function _handle_weights(weights)
    if weights === nothing
        return IGraphs.IGNull()
    else
        return IGraphs.IGVectorFloat(weights)
    end
end

# --- Algorithm Implementations ---

function sir_model(g::AbstractGraph{U}, ::IGraphAlgorithm; beta=0.1, gamma=0.1, no_sim=100) where U<:Integer
    ig = igraph(g)
    
    # result is an igraph_vector_ptr_t
    # We use a Ref to a pointer to hold the vector_ptr_t if it's not wrapped
    # or we can try to use a raw ccall if IGraphs doesn't provide it.
    
    # Let's assume LibIGraph has the type igraph_vector_ptr_t
    # Based on typical igraph wrappers, we might need to handle memory manually here.
    
    ptr_vec = Ref{LibIGraph.igraph_vector_ptr_t}()
    LibIGraph.igraph_vector_ptr_init(ptr_vec, 0)
    
    try
        ret = LibIGraph.igraph_sir(ig.objref, beta, gamma, no_sim, ptr_vec)
        _check_ret(ret, "igraph_sir")
        
        n_sim = LibIGraph.igraph_vector_ptr_size(ptr_vec)
        results = Vector{Vector{Float64}}(undef, n_sim)
        
        for i in 1:n_sim
            # Each element is an igraph_vector_t*
            v_ptr = LibIGraph.igraph_vector_ptr_get(ptr_vec, i-1)
            # We can wrap this in a temporary IGVectorFloat if we know it doesn't own the memory
            # or just copy it.
            # Assuming LibIGraph.igraph_vector_size(v_ptr) works
            v_size = LibIGraph.igraph_vector_size(v_ptr)
            res_v = Vector{Float64}(undef, v_size)
            for j in 1:v_size
                res_v[j] = LibIGraph.igraph_vector_get(v_ptr, j-1)
            end
            results[i] = res_v
        end
        return results
    finally
        # Clean up: destroy all vectors inside and the ptr vector itself
        # igraph_vector_ptr_destroy_all calls igraph_vector_destroy and then igraph_free on each element
        LibIGraph.igraph_vector_ptr_destroy_all(ptr_vec)
    end
end

function modularity_matrix(g::AbstractGraph{U}, ::IGraphAlgorithm; kwargs...) where U<:Integer
    ig = igraph(g)
    return IGraphs.modularity_matrix(ig; kwargs...)
end

function community_leiden(g::AbstractGraph{U}, ::IGraphAlgorithm; resolution=1.0, beta=0.01, n_iterations=10, kwargs...) where U<:Integer
    ig = igraph(g)
    membership = IGraphs.IGVectorInt(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_int_init(membership.objref, 0)
    
    nb_clusters = Ref{LibIGraph.igraph_int_t}(0)
    quality = Ref{LibIGraph.igraph_real_t}(0.0)
    
    ret = LibIGraph.igraph_community_leiden_simple(ig.objref, IGraphs.IGNull().objref, 0, resolution, beta, IGraphs.IGNull().objref, n_iterations, membership.objref, nb_clusters, quality)
    _check_ret(ret, "igraph_community_leiden_simple")
    return Vector(membership)
end

function layout_kamada_kawai(g::AbstractGraph{U}, ::IGraphAlgorithm; maxiter=100, epsilon=0.0, kkconst=0.0, kwargs...) where U<:Integer
    ig = igraph(g)
    n = nv(g)
    res = IGraphs.IGMatrixFloat(; _uninitialized=Val(true))
    LibIGraph.igraph_matrix_init(res.objref, n, 2)
    ret = LibIGraph.igraph_layout_kamada_kawai(ig.objref, res.objref, false, maxiter, epsilon, kkconst, IGraphs.IGNull().objref, -100.0, 100.0, -100.0, 100.0)
    _check_ret(ret, "igraph_layout_kamada_kawai")
    return Matrix(res)
end

function layout_fruchterman_reingold(g::AbstractGraph{U}, ::IGraphAlgorithm; niter=500, kwargs...) where U<:Integer
    ig = igraph(g)
    n = nv(g)
    res = IGraphs.IGMatrixFloat(; _uninitialized=Val(true))
    LibIGraph.igraph_matrix_init(res.objref, n, 2)
    ret = LibIGraph.igraph_layout_fruchterman_reingold(ig.objref, res.objref, false, niter, IGraphs.IGNull().objref, -100.0, 100.0, -100.0, 100.0)
    _check_ret(ret, "igraph_layout_fruchterman_reingold")
    return Matrix(res)
end

function Graphs.modularity(g::AbstractGraph{U}, membership::Vector{Int}, ::IGraphAlgorithm; weights=nothing, resolution=1.0, kwargs...) where U<:Integer
    ig = igraph(g)
    m_vec = IGraphs.IGVectorInt(membership .- 1) # igraph uses 0-indexed membership
    w = _handle_weights(weights)
    res = Ref{LibIGraph.igraph_real_t}(0.0)
    ret = LibIGraph.igraph_modularity(ig.objref, m_vec.objref, w.objref, resolution, is_directed(g), res)
    _check_ret(ret, "igraph_modularity")
    return res[]
end

# --- Dispatch Overrides for Core Algorithms ---

function betweenness_centrality(g::AbstractGraph{U}, ::IGraphAlgorithm; weights=nothing, normalized=true, kwargs...) where U<:Integer
    ig = igraph(g)
    n = nv(g)
    res = IGraphs.IGVectorFloat(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_init(res.objref, n)
    w = _handle_weights(weights)
    
    ret = LibIGraph.igraph_betweenness(ig.objref, w.objref, res.objref, LibIGraph.igraph_vss_all(), is_directed(g), normalized)
    _check_ret(ret, "igraph_betweenness")
    
    return Vector(res)
end

function pagerank(g::AbstractGraph{U}, ::IGraphAlgorithm; damping=0.85, weights=nothing, kwargs...) where U<:Integer
    ig = igraph(g)
    n = nv(g)
    res = IGraphs.IGVectorFloat(; _uninitialized=Val(true))
    LibIGraph.igraph_vector_init(res.objref, n)
    w = _handle_weights(weights)
    
    val = Ref{LibIGraph.igraph_real_t}(0.0)
    # Default behavior: try PRPACK first as it is more robust for small/disconnected graphs
    ret = LibIGraph.igraph_pagerank(ig.objref, w.objref, res.objref, val, damping, is_directed(g), LibIGraph.igraph_vss_all(), LibIGraph.IGRAPH_PAGERANK_ALGO_PRPACK, IGraphs.IGNull().objref)
    _check_ret(ret, "igraph_pagerank")
    return Vector(res)
end

# --- Specialized dispatches for AbstractIGraph ---
# These ensure that IGraph types use C implementations automatically.

Graphs.sir_model(g::AbstractIGraph; kwargs...) = sir_model(g, IGraphAlgorithm(); kwargs...)
Graphs.modularity_matrix(g::AbstractIGraph; kwargs...) = modularity_matrix(g, IGraphAlgorithm(); kwargs...)
Graphs.community_leiden(g::AbstractIGraph; kwargs...) = community_leiden(g, IGraphAlgorithm(); kwargs...)
Graphs.layout_kamada_kawai(g::AbstractIGraph; kwargs...) = layout_kamada_kawai(g, IGraphAlgorithm(); kwargs...)
Graphs.layout_fruchterman_reingold(g::AbstractIGraph; kwargs...) = layout_fruchterman_reingold(g, IGraphAlgorithm(); kwargs...)
Graphs.betweenness_centrality(g::AbstractIGraph; kwargs...) = betweenness_centrality(g, IGraphAlgorithm(); kwargs...)
Graphs.pagerank(g::AbstractIGraph; kwargs...) = pagerank(g, IGraphAlgorithm(); kwargs...)

end # module
