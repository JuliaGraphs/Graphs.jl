
# Generate a random graph with n vertices where each edge is included with probability p.
function erdos_renyi_graph{GT<:AbstractGraph}(g::GT, n::Integer, p::Real; has_self_loops=false)
    for i=1:n
        start_ind = is_directed(g) ? 1 : i
        for j=start_ind:n
            if(rand() <= p && (i != j || has_self_loops))
                add_edge!(g, i, j)
            end
        end
    end
    return g
end

# Convenience function with a default graph type.
function erdos_renyi_graph(n::Integer, p::Real; is_directed=true, has_self_loops=false)
    g = simple_inclist(n, is_directed=is_directed)
    erdos_renyi_graph(g, n, p, has_self_loops=has_self_loops)
end
