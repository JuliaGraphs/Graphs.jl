function degree(v::Vertex, g::UndirectedGraph)
    d = 0
    for edge in edges(g)
        if id(edge.out) == id(v) || id(edge.in) == id(v)
            d += 1
        end
    end
    return d
end

function indegree(v::Vertex, g::DirectedGraph)
    d = 0
    for edge in edges(g)
        if id(in(edge)) == id(v)
            d += 1
        end
    end
    return d
end

function outdegree(v::Vertex, g::DirectedGraph)
    d = 0
    for edge in edges(g)
        if id(out(edge)) == id(v)
            d += 1
        end
    end
    return d
end

# Assume no doubled edges
# Assume no flipped edges
function degrees(g::UndirectedGraph)
    n = order(g)
    ds = zeros(Int, n)
    es = edges(g)
    for i in 1:size(g)
        edge = es[i]
        ds[id(edge.out)] += 1
        ds[id(edge.in)] += 1
    end
    return ds
end

connected(v1::Vertex, v2::Vertex, g::Graph) = error("Not yet implemented")
adjacent(e1::Edge, e2::Edge, g::Graph) = error("Not yet implemented")
const coincident = adjacent

isconnected(g::Graph) = error("Not yet implemented")

function iscomplete(g::Graph)
    all(adjacency_matrix(g) .== 1)
end

function isdirected(g::Graph)
    if isa(g, DirectedGraph)
        return true
    elseif isa(g, UndirectedGraph)
        return false
    else
        error("Unknown graph type")
    end
end

function isregular(g::UndirectedGraph)
    error("Not yet implemented")
end

function issimple(g::UndirectedGraph)
    error("Not yet implemented")
end

# TODO: Implement faster algorithm
function issymmetric(g::DirectedGraph)
    a = adjacency_matrix(g)
    return isequal(a, a')
end

function isweighted(g::Graph)
    for edge in edges
        if weight(edge) != 1.0
            return true
        end
    end
    return false
end

# TODO: Add all of the following
# assortativity()
# betweenness()
# betweennesses()
# cliques()
# clusters()
# communities()
# components()
# eccentricity()
# neighborhoods()
# reciprocity()
# shortest_path()
# shortest_paths()
# transitivity()
# betweenness_centrality()
# closeness_centrality()
# eigenvector_centrality()
# hamiltonian_path()
# minimum_spanning_tree()

function adjacency_matrix(g::UndirectedGraph)
    n = order(g)
    A = zeros(Int, n, n)
    for i in 1:size(g)
        edge = edges(g)[i]
        A[edge.out.id, edge.in.id] = 1
        A[edge.in.id, edge.out.id] = 1
    end
    return A
end

function adjacency_matrix(g::DirectedGraph)
    n = order(g)
    A = zeros(Int, n, n)
    for i in 1:size(g)
        edge = edges(g)[i]
        A[id(out(edge)), id(in(edge))] = 1
    end
    return A
end

degree_matrix(g::Graph) = diagm(degrees(g))

distance_matrix(g::Graph) = error("Not yet implemented")

incidence_matrix(g::Graph) = error("Not yet implemented")

laplacian_matrix(g::UndirectedGraph) = degree_matrix(g) - adjacency_matrix(g)
const laplacian = laplacian_matrix
