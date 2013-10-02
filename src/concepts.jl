#################################################
#
#  Graph concepts
#
#################################################

# the root type of all graphs
abstract AbstractGraph{V, E}

vertex_type{V,E}(g::AbstractGraph{V,E}) = V
edge_type{V,E}(g::AbstractGraph{V,E}) = E

# concepts checking

implements_vertex_list(g::AbstractGraph) = false
implements_edge_list(g::AbstractGraph) = false

implements_vertex_map(g::AbstractGraph) = false
implements_edge_map(g::AbstractGraph) = false

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
    :vertex_list, :edge_list, :vertex_map, :edge_map,
    :adjacency_list, :incidence_list,
    :bidirectional_adjacency_list, :bidirectional_incidence_list,
    :adjacency_matrix )

function _graph_implements_code(G::Symbol, concepts::Symbol...)
    stmts = Expr[]
    for c in concepts
        if !(c in _supported_graph_concept_symbols)
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
    if !(concept in _supported_graph_concept_symbols)
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

