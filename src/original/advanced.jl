function degree(v::Vertex, g::UndirectedGraph)
    d = 0
    for edge in edges(g)
        if id(edge.a) == id(v) || id(edge.b) == id(v)
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

function degrees(g::UndirectedGraph)
    n = order(g)
    ds = zeros(Int, n)
    for edge in edges(g)
        ds[id(edge.a)] += 1
        ds[id(edge.b)] += 1
    end
    return ds
end

function outdegrees(g::DirectedGraph)
    n = order(g)
    ds = zeros(Int, n)
    for edge in edges(g)
        ds[id(out(edge))] += 1
    end
    return ds
end

function indegrees(g::DirectedGraph)
    n = order(g)
    ds = zeros(Int, n)
    for edge in edges(g)
        ds[id(in(edge))] += 1
    end
    return ds
end

connected(v1::Vertex, v2::Vertex, g::AbstractGraph) = error("Not yet implemented")
adjacent(e1::Edge, e2::Edge, g::AbstractGraph) = error("Not yet implemented")
const coincident = adjacent

isconnected(g::AbstractGraph) = error("Not yet implemented")

function iscomplete(g::AbstractGraph)
    all(adjacency_matrix(g) .== 1)
end

function isdirected(g::AbstractGraph)
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

# TODO: Implement a better algorithm
function issymmetric(g::DirectedGraph)
    a = adjacency_matrix(g)
    return isequal(a, a')
end

function isweighted(g::AbstractGraph)
    for edge in edges(g)
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
# istree()
# isforest()
# isbipartite()
# chromatic_number()
# pagerank()

function adjacency_matrix(g::UndirectedGraph)
    n = order(g)
    A = zeros(Int, n, n)
    for edge in edges(g)
        A[edge.a.id, edge.b.id] = 1
        A[edge.b.id, edge.a.id] = 1
    end
    return A
end

function adjacency_matrix(g::DirectedGraph)
    n = order(g)
    A = zeros(Int, n, n)
    for edge in edges(g)
        A[id(out(edge)), id(in(edge))] = 1
    end
    return A
end

degree_matrix(g::UndirectedGraph) = diagm(degrees(g))
outdegree_matrix(g::DirectedGraph) = diagm(outdegrees(g))
indegree_matrix(g::DirectedGraph) = diagm(indegrees(g))

distance_matrix(g::AbstractGraph) = error("Not yet implemented")

function incidence_matrix(g::UndirectedGraph)
    n = order(g)
    p = size(g)
    M = zeros(Int, n, p)
    i = 0
    for edge in edges(g)
        i += 1
        M[edge.a.id, i] = 1
        M[edge.b.id, i] = 1
    end
    return M
end

function incidence_matrix(g::DirectedGraph)
    n = order(g)
    p = size(g)
    M = zeros(Int, n, p)
    i = 0
    for edge in edges(g)
        i += 1
        M[edge.out.id, i] = 1
        M[edge.in.id, i] = 1
    end
    return M
end

laplacian_matrix(g::UndirectedGraph) = degree_matrix(g) - adjacency_matrix(g)
function laplacian_matrix(g::DirectedGraph, direction::Symbol)
    if direction == :out
        outdegree_matrix(g) - adjacency_matrix(g)
    elseif direction == :in
        indegree_matrix(g) - adjacency_matrix(g)
    else
        error("direction must be :out or :in")
    end
end
laplacian_matrix(g::DirectedGraph) = laplacian_matrix(g, :out)
const laplacian = laplacian_matrix

signless_laplacian_matrix(g::UndirectedGraph) = degree_matrix(g) + adjacency_matrix(g)
function signless_laplacian_matrix(g::DirectedGraph, direction::Symbol)
    if direction == :out
        outdegree_matrix(g) + adjacency_matrix(g)
    elseif direction == :in
        indegree_matrix(g) + adjacency_matrix(g)
    else
        error("direction must be :out or :in")
    end
end
signless_laplacian_matrix(g::DirectedGraph) = signless_laplacian_matrix(g, :out)
const signless_laplacian = signless_laplacian_matrix
