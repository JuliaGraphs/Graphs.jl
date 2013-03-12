#################################################
#
#  Graph concepts
#
#################################################

# the root type of all graphs
abstract AbstractGraph{V, E}

vertex_type{V,E}(g::AbstractGraph{V,E}) = Int
edge_type{V,E}(g::AbstractGraph{V,E}) = (Int, Int)

# concepts checking

implements_vertex_list(g::AbstractGraph) = false
implements_edge_list(g::AbstractGraph) = false

implements_bidirectional_adjacency_list(g::AbstractGraph) = false
implements_bidirectional_incidence_list(g::AbstractGraph) = false

# This ensures that 
# When implements_bidirectional_adjlist is set to true, 
# implements_adjlist is automatically true without being overrided

implements_adjacency_list(g::AbstractGraph) = implements_bidirectional_adjacency_list(g)
implements_incidence_list(g::AbstractGraph) = implements_bidirectional_incidence_list(g)

implements_adjacency_matrix(g::AbstractGraph) = false

# macro to simplify concept declaration

const _supported_graph_concept_symbols = Set(
    :vertex_list, :edge_list, :adjacency_list, :incidence_list, 
    :bidirectional_adjacency_list, :bidirectional_incidence_list, 
    :adjacency_matrix )

function _graph_implements_code(G::Symbol, concepts::Symbol...)
    stmts = Expr[]
    for c in concepts   
        if !has(_supported_graph_concept_symbols, c)
            error("Invalid concept name: $c")
        end
           
        fun = symbol(string("implements_", string(c)))
        stmt = :( $(fun)(::$(G)) = true )
        push!(stmts, stmt)
    end
    Expr(:block, stmts...)
end

macro graph_implements(G, concepts...)
    esc(_graph_implements_code(G, concepts...))
end

# macro to check interface requirements

function _graph_requires_stmt(g::Symbol, concept::Symbol)
    if !has(_supported_graph_concept_symbols, concept)
        error("Invalid concept name: $c")
    end
    fun = symbol(string("implements_", string(concept)))
    msg = "The graph $(g) does not implement a required concept: $(concept)."
    :( $(fun)($g) ? nothing : throw(ArgumentError($msg)) )
end

function _graph_requires_code(g::Symbol, concepts::Symbol...)
    stmts = Expr[]
    for c in concepts
        push!(stmts, _graph_requires_stmt(g, c))
    end
    Expr(:block, stmts...)
end

macro graph_requires(g, concepts...)
    esc(_graph_requires_code(g, concepts...))
end


#################################################
#
#  Helpers for providing out_neighbors and
#  in_neighbors methods for incidence graph.
#
#################################################

immutable OutNeighborProxy{G, I}
    g::G   # graph
    edge_iter::I
end

out_neighbor_proxy(g::AbstractGraph) = OutNeighborProxy(g, out_edges(g))

start(proxy::OutNeighborProxy) = start(g.edge_iter)

function next(proxy::OutNeighborProxy, s) 
    edge, s = next(g.edge_iter, s)
    (target(edge, proxy.g), s)
end

done(proxy::OutNeighborProxy, s) = done(proxy.edge_iter, s)


immutable InNeighborProxy{G, I}
    g::G   # graph
    edge_iter::I
end

in_neighbor_proxy(g::AbstractGraph) = InNeighborProxy(g, in_edges(g))

start(proxy::InNeighborProxy) = start(g.edge_iter)

function next(proxy::InNeighborProxy, s) 
    edge, s = next(g.edge_iter, s)
    (source(edge, proxy.g), s)
end

done(proxy::InNeighborProxy, s) = done(proxy.edge_iter, s)

