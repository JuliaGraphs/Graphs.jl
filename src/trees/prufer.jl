"""
    is_tree(g)

Returns true if g is a tree: that is, a simple, connected undirected graph, with nv-1 edges (nv = number of vertices). Trees are the minimal connected graphs; equivalently they have no cycles.  

This function does not apply to directed graphs. Directed trees are sometimes called [polytrees](https://en.wikipedia.org/wiki/Polytree)). 

"""
function is_tree end

@traitfn function is_tree(g::::(!IsDirected))
    return ne(g) == nv(g) - 1 && is_connected(g)
end

function _is_prufer(c::AbstractVector{T}) where {T<:Integer}
    return isempty(c) || (minimum(c) >= 1 && maximum(c) <= length(c) + 2)
end

function _degree_from_prufer(c::Vector{T})::Vector{T} where {T<:Integer}
    """
    Degree sequence from Prüfer code.
    Returns d such that d[i] = 1 + number of occurences of i in c
    """
    n = length(c) + 2
    d = ones(T, n)
    for value in c
        d[value] += 1
    end
    return d
end

"""
    prufer_decode(code)

Returns the unique tree associated with the given (Prüfer) code. 
Each tree of size n is associated with a Prüfer sequence (a[1], ..., a[n-2]) with 1 ⩽ a[i] ⩽ n. The sequence is constructed recursively by the leaf removal algoritm. At step k, the leaf with smallest index is removed and its unique neighbor is added to the Prüfer sequence, giving a[k]. The decoding algorithm goes backward.  The tree associated with the empty sequence is the 2-vertices tree with one edge.
Ref: [Prüfer sequence on Wikipedia](https://en.wikipedia.org/wiki/Pr%C3%BCfer_sequence)

"""
function prufer_decode(code::AbstractVector{T})::SimpleGraph{T} where {T<:Integer}
    !_is_prufer(code) && throw(
        ArgumentError("The code must have one dimension and must be a Prüfer sequence. "),
    )
    isempty(code) && return path_graph(T(2)) # the empty Prüfer sequence codes for the one-edge tree

    n = length(code) + 2
    d = _degree_from_prufer(code)
    L = BinaryMinHeap{T}(findall(==(1), d))
    g = Graph{T}(n, 0)

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
    prufer_encode(g::SimpleGraph)

Given a tree (a connected minimal undirected graph) of size n⩾3, returns the unique Prüfer sequence associated with this tree. 

Each tree of size n ⩾ 2 is associated with a Prüfer sequence (a[1], ..., a[n-2]) with 1 ⩽ a[i] ⩽ n. The sequence is constructed recursively by the leaf removal algoritm. At step k, the leaf with smallest index is removed and its unique neighbor is added to the Prüfer sequence, giving a[k]. The Prüfer sequence of the tree with only one edge is the empty sequence. 

Ref: [Prüfer sequence on Wikipedia](https://en.wikipedia.org/wiki/Pr%C3%BCfer_sequence)

"""
function prufer_encode(G::SimpleGraph{T})::Vector{T} where {T<:Integer}
    (nv(G) < 2 || !is_tree(G)) &&
        throw(ArgumentError("The graph must be a tree with n ⩾ 2 vertices. "))

    n = nv(G)
    n == 2 && return Vector{T}() # empty Prüfer sequence 
    g = copy(G)
    code = zeros(T, n - 2)
    d = degree(g)
    L = BinaryMinHeap(findall(==(1), d))

    for i in 1:(n - 2)
        u = pop!(L)
        v = neighbors(g, u)[1]
        rem_edge!(g, u, v)
        d[u] -= 1
        d[v] -= 1
        d[v] == 1 && push!(L, v)
        code[i] = v
    end

    return code
end
