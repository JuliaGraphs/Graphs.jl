"""
    is_tree(g)

Returns true if g is a simple tree: that is, a simple connected graph, with nv-1 edges (nv = number of vertices). Trees are the minimal connected graphs; equivalently they have no cycles.  

This is only for undirected graphs. 
"""

function is_tree(g::SimpleGraph)
    return is_connected(g) && ne(g) == nv(g) - 1
end

function _is_prufer(c)
    ℓ = length(c)
    return ndims(c) == 1 && maximum(c) <= ℓ + 2 && ℓ >= 1
end

function _degree_from_prufer(c::Vector{T}) where {T<:Integer}
    """
    Degree sequence from prufer code.
    Returns d such that d[i] = 1 + number of occurences of i in c
    """
    n = length(c) + 2
    return [count(==(i), c) for i in 1:n] .+ 1
end

function test_degree_sequence()
    a = [1, 2, 3, 4, 4, 4] # 8 nodes
    return _prufer_degree_sequence(a) == [2, 2, 2, 4, 1, 1, 1, 1]
end

"""
    prufer_decode(code)

Returns the unique tree associated with the given (Prüfer) code. 
Each tree of size n is associated with a Prüfer sequence (a[1], ..., a[n-2]) with 1 ⩽ a[i] ⩽ n. The sequence is constructed recursively by the leaf removal algoritm. At step k, the leaf with smallest index is removed and its unique neighbor is added to the Prüfer sequence, giving a[k]. The decoding algorithm goes backward.  
Ref: [Prüfer sequence on Wikipedia](https://en.wikipedia.org/wiki/Pr%C3%BCfer_sequence)
"""

function prufer_decode(code::Array{T,1})::Graph{T} where {T<:Integer}
    n = length(code) + 2
    !_is_prufer(code) && throw(
        ArgumentError(
            "The code must be an Array{T,1} and must be a Prufer sequence with length ⩾1. ",
        ),
    )
    d = _degree_from_prufer(code)
    L = BinaryMinHeap(findall(==(1), d))
    g = Graph(n, 0)

    for i in 1:(n - 2)
        l = pop!(L) # extract leaf with priority rule (max)
        d[l] -= 1 # update degree sequence
        add_edge!(g, l, code[i]) # add edge
        d[code[i]] -= 1 # update degree sequence
        d[code[i]] == 1 && push!(L, code[i]) # add new leaf if any
    end

    add_edge!(g, pop!(L), pop!(L)) # add last leaf

    return g
end

"""
    prufer_encode(g)

Given a tree (a connected minimal undirected graph) of size n⩾2, returns the unique Prüfer sequence associated with this tree. 

Each tree of size n ⩾ 2 is associated with a Prüfer sequence (a[1], ..., a[n-2]) with 1 ⩽ a[i] ⩽ n. The sequence is constructed recursively by the leaf removal algoritm. At step k, the leaf with smallest index is removed and its unique neighbor is added to the Prüfer sequence, giving a[k]. 

Ref: [Prüfer sequence on Wikipedia](https://en.wikipedia.org/wiki/Pr%C3%BCfer_sequence)

"""

function prufer_encode(G::Graph{T})::Array{T,1} where {T<:Integer}
    n = nv(G)
    (!is_tree(G) || n <= 2) &&
        throw(ArgumentError("The graph must be a tree with n ⩾ 3 vertices. "))
    g = copy(G)
    code = zeros(Int, n - 2)
    d = degree(g)
    L = BinaryMinHeap(findall(==(1), d))

    for i in 1:(n - 2)
        l = pop!(L)
        v = neighbors(g, l)[1]
        rem_edge!(g, l, v)
        d[l] -= 1
        d[v] -= 1
        d[v] == 1 && push!(L, v)
        code[i] = v
    end

    return code
end