
# Generate a random graph with n verticies where each edge is included with probability p.
function erdos_renyi_graph(n::Integer, p::Real; directed=false, loops=false)
    if(directed)
        edge_type = DirectedEdge
        graph_type = DirectedGraph
    else
        edge_type = UndirectedEdge
        graph_type = UndirectedGraph
    end

    verticies = Set{Vertex}();
    for i=1:n
        add!(verticies,Vertex(i))
    end

    edges = Set{edge_type}();
    m = directed ? n : ceil(n/2)
    for i=1:n
        for j=1:n
            if(rand() <= p && (i != j || loops))
                add!(edges, edge_type(i,j))
            end
        end
    end
    return graph_type(verticies, edges)
end

# Generate a 'small world' random graph based on the Watts-Strogatz model.
# Written with much reference to the implementation from GraphStream <http://graphstream-project.org>.
# The resulting graph has n verticies, 
#   Each vertex has a base degree of k  (n > k, k >= 2, k must be even.)
#   There is a beta chance of each edge being 'rewired'
function watts_strogatz_graph(n::Integer, k::Integer, beta::Real)
    g = UndirectedGraph()

    # We start by placing the nodes around the edge of a circle.
    space = linspace(0,2*pi,n)
    for i in 1:n
        v = Vertex(i)
        attrs = attributes(v)
        x = round((cos(space[i]) + 1)*100,2)
        y = round((sin(space[i]) + 1)*100,2)
        attrs["pos"] = "$(x),$(y)"
        add!(g,v)
    end


    # Then we link each node to the k/2 nodes next to it in each direction.
    for i in 1:n
        for j in 1:(k/2)
            add!(g, UndirectedEdge(i, (i+j) % n ))
        end
    end

    # Then we do the rewiring

    for i in 1:n
        for j in 1:(k/2)
            if rand() < beta
                # add a random link across the graph
                curEdges = length(edges(g))
                    
                while length(edges(g)) == curEdges
                    target = rand(1:(n-1))
                    if (target >= i)
                        target += 1
                    end
                    e = UndirectedEdge(i,target)
                    add!(g,e)
                end
                # remove the edge between i and i + j % n
                del(g,UndirectedEdge(i,(i+j)%n))               
            end
        end
    end
    g
end