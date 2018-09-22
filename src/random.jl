
# Generate a random graph with n vertices where each edge is included with probability p.
function erdos_renyi_graph(g::GT, n::Integer, p::Real; has_self_loops=false) where {GT<:AbstractGraph}
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

# Generate a 'small world' random graph based on the Watts-Strogatz model.
# Written with much reference to the implementation from GraphStream <http://graphstream-project.org>.
# The resulting graph has n vertices,
#   Each vertex has a base degree of k  (n > k, k >= 2, k must be even.)
#   There is a beta chance of each edge being 'rewired'
function watts_strogatz_graph(g::GT, n::Integer, k::Integer, beta::Real) where {GT<:AbstractGraph}
    # When attributes are restored, we can enable placing the vertices around a circle.
    # This is nice for explicit visualization of the model.
    #space = linspace(0,2*pi,n+1)
    #for v in vertices(g)
    #    attrs = attributes(v)
    #    x = round((cos(space[i]) + 1)*100,2)
    #    y = round((sin(space[i]) + 1)*100,2)
    #    attrs["pos"] = "$(x),$(y)"
    #end

    # Link each node to the k/2 nodes next to it in each direction.
    # For each vertex in the graph:
    for i in 1:n
        # For the next k/2 higher indexed nodes:
        for j in 1:div(k,2)
            # Either make an edge to the neighbor or a long edge across the graph.
            if rand() > beta
                add_edge!(g, i, ((i+j - 1) % n) + 1 )
            else
                # Add a random link across the graph and delete the link to the neighbor.
                while true
                    target = rand(1:(n-1))
                    if (target >= i)
                        target += 1
                    end
                    if !(target in out_neighbors(i,g))
                        add_edge!(g,i, target)
                        break
                    end
                end
            end
        end
    end
    g
end

# Convenience function with a default graph type.
function watts_strogatz_graph(n::Integer, k::Integer, beta::Real)
    g = simple_inclist(n, is_directed=false)
    watts_strogatz_graph(g,n,k,beta)
end
