# Adapted from SimpleGraphs.jl [Copyright (c) 2014, Ed Scheinerman]:
#    https://github.com/scheinerman/SimpleGraphs.jl/blob/master/src/simple_euler.jl
# Reproduced under the MIT Expat License.

"""
    eulerian(g::AbstractSimpleGraph{T}[, u::T, v::T]) --> T[]

Compute an Eulerian tour through an undirected graph `g`, starting at `u` and ending at `v`,
returning a vector listing the vertices of `g` in the order that they are travailed. If no
such tour exists, throws an error.

## Optional arguments
- If `v` is omitted, an Eulerian cycle is computed with `v = u`.
- If both `u` and `v` are omitted, a Eulerian cycle is computed with
  `u = v = first(vertices(g))`.
"""
function eulerian(g::AbstractSimpleGraph{T}, u::T, v::T) where {T}
    is_directed(g) && error("`eulerian` is not yet implemented for directed graphs")
    
    _check_eulerian_input(g, u, v) # perform basic sanity checks

    g′ = SimpleGraph{T}(nv(g)) # copy `g`
    for e in edges(g)
        add_edge!(g′, e)
    end

    return _eulerian!(g′, u)
end

# special case: find an Euler cycle from a specified vertex
eulerian(G::AbstractSimpleGraph{T}, u::T) where {T} = eulerian(G, u, u)

# special case: find any Euler tour; randomly pick first vertex
eulerian(g::AbstractSimpleGraph) = eulerian(g, first(vertices(g)))

function _eulerian!(g::AbstractSimpleGraph{T}, u::T) where {T}
    # TODO: This uses Fleury's algorithm which is O(|E|²) in the number of edges |E|.
    #       Hierholzer's algorithm [https://en.wikipedia.org/wiki/Eulerian_path#Hierholzer's_algorithm]
    #       is presumably faster, running in O(|E|) time, but requires more space due to
    #       needing to keep track of visited/nonvisited sites in a doubly-linked list/deque.
    trail = T[]

    nverts = nv(g)
    while true
        # if last vertex
        if nverts == 1
            push!(trail, u)
            return trail
        end

        # get the neighbors of u
        Nu = neighbors(g, u)

        if length(Nu) == 1
            # if only one neighbor, delete and move on
            w = first(Nu)
            rem_edge!(g, u, w)
            nverts -= 1
            push!(trail, u)
            u = w
        else
            # otherwise, pick whichever neighbor is not a bridge/cut-edge
            bs = bridges(g)
            for w in Nu
                if all(e -> e ≠ Edge(u, w) && e ≠ Edge(w, u), bs)
                    # not a bridge/cut-edge; add to trail
                    rem_edge!(g, u, w)
                    push!(trail, u)
                    u = w
                    break
                end
            end
        end
    end
    error("unreachable reached")
end

function _check_eulerian_input(g, u, v)
    if !(has_vertex(g, u) && has_vertex(g, v))
        error("one or both of the provided start and end vertices are not in the graph")
    end

    # special case: if any vertex have degree zero
    if any(x->degree(g, x) == 0, vertices(g))
        error("some vertices have degree zero (are isolated) and cannot be reached")
    end

    # vertex degree checks
    if u == v   # (cycle)
        if any(x->isodd(degree(g, x)), vertices(g))
            error("start and end vertices are identical but there exists vertices of odd degree: a eulerian cycle does not exist")
        end
    else        # u != v (tour)
        for x in vertices(g)
            if x == u || x == v
                if iseven(degree(g, x))
                    return error("start and end vertices differ but have even degree: a eulerian tour does not exist")
                end
            else
                if isodd(degree(g, x))
                    return error("a non-start/end vertex has odd degree: a eulerian tour does not exist")
                end
            end
        end
    end

    if !is_connected(g)
        error("graph is not connected: a eulerian cycle/tour does not exist")
    end
end