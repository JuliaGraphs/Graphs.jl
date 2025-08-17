#### Optional APIs backed by external packages (e.g., IGraphs.jl)
#### These functions are PUBLIC names that Graphs.jl exposes, but by default
#### they throw a helpful error until a backend (IGraphs.jl) provides methods.

# Friendly message builder
_igraph_backend_msg(fname) = """
`$(fname)` is not implemented in base Graphs.jl.
It is available via the **IGraphs.jl** backend.

Enable it and re-run:

    using IGraphs, IGraphs.GraphsCompat
    $(fname)(g, IGraphAlgorithm())

"""

# -----------------------
# Assortativity
# -----------------------
@static if !isdefined(@__MODULE__, :assortativity)
"""
    assortativity(g::AbstractGraph, attr; normalized::Bool=true)

Degree- or attribute-based assortativity coefficient.

!!! note "Availability"
    Backend-only: use **IGraphs.jl** (see message if not loaded).
"""
function assortativity end
assortativity(g::AbstractGraph, attr; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:assortativity)))
end

@static if !isdefined(@__MODULE__, :assortativity_degree)
"""
    assortativity_degree(g::AbstractGraph; normalized::Bool=true)

Degree assortativity (scalar coefficient).
"""
function assortativity_degree end
assortativity_degree(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:assortativity_degree)))
end

@static if !isdefined(@__MODULE__, :assortativity_nominal)
"""
    assortativity_nominal(g::AbstractGraph, attr)

Nominal/categorical assortativity based on a vertex attribute.
"""
function assortativity_nominal end
assortativity_nominal(g::AbstractGraph, attr; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:assortativity_nominal)))
end

# -----------------------
# Coreness / k-core number
# -----------------------
@static if !isdefined(@__MODULE__, :coreness)
"""
    coreness(g::AbstractGraph)

Return the k-core number (coreness) per vertex.
"""
function coreness end
coreness(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:coreness)))
end

# -----------------------
# Connectivity & disjoint paths
# -----------------------
@static if !isdefined(@__MODULE__, :edge_connectivity)
"""
    edge_connectivity(g::AbstractGraph)

Global edge connectivity (minimum edge cut size).
"""
function edge_connectivity end
edge_connectivity(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:edge_connectivity)))
end

@static if !isdefined(@__MODULE__, :vertex_connectivity)
"""
    vertex_connectivity(g::AbstractGraph)

Global vertex connectivity (minimum vertex cut size).
"""
function vertex_connectivity end
vertex_connectivity(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:vertex_connectivity)))
end

@static if !isdefined(@__MODULE__, :edge_disjoint_paths)
"""
    edge_disjoint_paths(g::AbstractGraph, s::Integer, t::Integer)

Maximum number of edge-disjoint s–t paths.
"""
function edge_disjoint_paths end
edge_disjoint_paths(g::AbstractGraph, s::Integer, t::Integer; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:edge_disjoint_paths)))
end

@static if !isdefined(@__MODULE__, :vertex_disjoint_paths)
"""
    vertex_disjoint_paths(g::AbstractGraph, s::Integer, t::Integer)

Maximum number of vertex-disjoint s–t paths.
"""
function vertex_disjoint_paths end
vertex_disjoint_paths(g::AbstractGraph, s::Integer, t::Integer; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:vertex_disjoint_paths)))
end

# -----------------------
# Cuts & cut trees
# -----------------------
@static if !isdefined(@__MODULE__, :gomory_hu_tree)
"""
    gomory_hu_tree(g::AbstractGraph; capacity=:weight)

Compute the Gomory–Hu cut tree (all-pairs min-cuts).
"""
function gomory_hu_tree end
gomory_hu_tree(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:gomory_hu_tree)))
end

@static if !isdefined(@__MODULE__, :minimum_size_separators)
"""
    minimum_size_separators(g::AbstractGraph)

Enumerate minimum cardinality vertex separators.
"""
function minimum_size_separators end
minimum_size_separators(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:minimum_size_separators)))
end

# -----------------------
# Isomorphism, VF2, automorphisms
# -----------------------
@static if !isdefined(@__MODULE__, :isomorphic)
"""
    isomorphic(g1::AbstractGraph, g2::AbstractGraph)

Graph isomorphism test (e.g., VF2 backend).
"""
function isomorphic end
isomorphic(g1::AbstractGraph, g2::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:isomorphic)))
end

@static if !isdefined(@__MODULE__, :subgraph_isomorphisms_vf2)
"""
    subgraph_isomorphisms_vf2(pat::AbstractGraph, g::AbstractGraph)

Find (all) VF2 subgraph isomorphisms of `pat` in `g`.
"""
function subgraph_isomorphisms_vf2 end
subgraph_isomorphisms_vf2(pat::AbstractGraph, g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:subgraph_isomorphisms_vf2)))
end

@static if !isdefined(@__MODULE__, :count_automorphisms)
"""
    count_automorphisms(g::AbstractGraph)

Count graph automorphisms (backend dependent).
"""
function count_automorphisms end
count_automorphisms(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:count_automorphisms)))
end

# -----------------------
# Graphlets & motifs
# -----------------------
@static if !isdefined(@__MODULE__, :graphlets)
"""
    graphlets(g::AbstractGraph; k=5)

Graphlet counts / signatures up to size `k`.
"""
function graphlets end
graphlets(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:graphlets)))
end

@static if !isdefined(@__MODULE__, :motifs)
"""
    motifs(g::AbstractGraph; size)

Motif (small subgraph) counts for a given size.
"""
function motifs end
motifs(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:motifs)))
end

# -----------------------
# Line graph, spectral embeddings, modularity
# -----------------------
@static if !isdefined(@__MODULE__, :linegraph)
"""
    linegraph(g::AbstractGraph)

Construct the line graph of `g`.
"""
function linegraph end
linegraph(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:linegraph)))
end

@static if !isdefined(@__MODULE__, :adjacency_spectral_embedding)
"""
    adjacency_spectral_embedding(g::AbstractGraph; nev, which=:LM)

Compute an adjacency spectral embedding (ASE).
"""
function adjacency_spectral_embedding end
adjacency_spectral_embedding(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:adjacency_spectral_embedding)))
end

@static if !isdefined(@__MODULE__, :modularity_matrix)
"""
    modularity_matrix(g::AbstractGraph; weights=:weight)

Return the modularity matrix (backend dependent).
"""
function modularity_matrix end
modularity_matrix(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:modularity_matrix)))
end

# -----------------------
# Clustering (transitivity) & strength
# -----------------------
@static if !isdefined(@__MODULE__, :transitivity_avglocal_undirected)
"""
    transitivity_avglocal_undirected(g::AbstractGraph)

Average local clustering coefficient (undirected).
"""
function transitivity_avglocal_undirected end
transitivity_avglocal_undirected(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:transitivity_avglocal_undirected)))
end

@static if !isdefined(@__MODULE__, :transitivity_local_undirected)
"""
    transitivity_local_undirected(g::AbstractGraph)

Local clustering coefficients per vertex (undirected).
"""
function transitivity_local_undirected end
transitivity_local_undirected(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:transitivity_local_undirected)))
end

@static if !isdefined(@__MODULE__, :strength)
"""
    strength(g::AbstractGraph; mode=:out, weights=:weight)

Weighted degree ("strength") per vertex.
"""
function strength end
strength(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:strength)))
end

# -----------------------
# Independent sets, neighborhood graphs
# -----------------------
@static if !isdefined(@__MODULE__, :independence_number)
"""
    independence_number(g::AbstractGraph)

Size of a maximum independent set.
"""
function independence_number end
independence_number(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:independence_number)))
end

@static if !isdefined(@__MODULE__, :independent_vertex_sets)
"""
    independent_vertex_sets(g::AbstractGraph)

Enumerate maximal (or all) independent sets (backend dependent).
"""
function independent_vertex_sets end
independent_vertex_sets(g::AbstractGraph; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:independent_vertex_sets)))
end

@static if !isdefined(@__MODULE__, :neighborhood_graphs)
"""
    neighborhood_graphs(g::AbstractGraph, vset; order=1, mode=:all)

Induced neighborhood graphs around `vset`.
"""
function neighborhood_graphs end
neighborhood_graphs(g::AbstractGraph, vset; kwargs...) =
    throw(ArgumentError(_igraph_backend_msg(:neighborhood_graphs)))
end

# -----------------------
# Layouts (visualization helpers)
# (Backends often provide: circle, kk, fr, drl, graphopt, grid, lgl, mds, random, reingold_tilford, sugiyama)
# -----------------------
for fname in (
    :layout_circle, :layout_kamada_kawai, :layout_fruchterman_reingold, :layout_drl,
    :layout_graphopt, :layout_grid, :layout_lgl, :layout_mds,
    :layout_random, :layout_reingold_tilford, :layout_sugiyama
)
    @eval begin
        @static if !isdefined(@__MODULE__, $fname)
            """
                $(Symbol($fname))(g::AbstractGraph; kwargs...)

            Compute a 2D/3D layout embedding (backend dependent).
            """
            function $(Symbol(fname)) end
            $(Symbol(fname))(g::AbstractGraph; kwargs...) =
                throw(ArgumentError(_igraph_backend_msg($fname)))
        end
    end
end
