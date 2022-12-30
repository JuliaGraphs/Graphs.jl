"""
    name of func
    blabla
"""

function is_tree(g::SimpleGraph)
    return is_connected(g) && ne(g)==nv(g)-1
end

function _prufer_degree_sequence(c::Vector{Int64})
    """
    Degree sequence from prufer code.
    Returns d such that d[i] = 1 + number of occurences of i in c
    """
    n = length(c)+2
    [count(==(i), c) for i in 1:n] .+ 1
end

function degree_sequence(g::Graph)
    degree(g)
end

function test_degree_sequence()
    a = [1,2,3,4,4,4] # 8 nodes
    _prufer_degree_sequence(a) == [2, 2, 2, 4, 1, 1, 1, 1]
end

"""
    prufer_decoding()
"""

function prufer_decode(c)::Graph
    n = length(c) + 2
    d = _prufer_degree_sequence(c)
    L = BinaryMaxHeap(findall(==(1),d))
    g = Graph(n, 0)

    for i in 1:n-2
        l = pop!(L) # extract leaf with priority rule (max)
        d[l] -= 1 # update degree sequence
        add_edge!(g, l,c[i]) # add edge
        d[c[i]] -= 1 # update degree sequence
        d[c[i]]==1 && push!(L, c[i]) # add new leaf if any
    end

    add_edge!(g, pop!(L), pop!(L)) # add last leaf

    g
end

function prufer_encode(G::Graph)
    g = copy(G)
    n = nv(g)
    c = zeros(Int, n-2)
    d = degree_sequence(g)
    L = BinaryMaxHeap(findall(==(1),d))
    for i in 1:n-2
        l = pop!(L)
        v = neighbors(g,l)[1]
        rem_edge!(g,l,v)
        d[l] -= 1
        d[v] -= 1
        d[v] == 1 && push!(L,v)
        c[i] = v
    end
    c
end