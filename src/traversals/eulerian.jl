# Adapted from SimpleGraphs.jl [Copyright (c) 2014, Ed Scheinerman]:
#    https://github.com/scheinerman/SimpleGraphs.jl/blob/master/src/simple_euler.jl
# Reproduced under the MIT Expat License.

"""
    eulerian(g::AbstractSimpleGraph{T}[, u::T]) --> T[]

Compute an [Eulerian trail or cycle](https://en.wikipedia.org/wiki/Eulerian_path) through an
undirected graph `g`, starting at `u`, returning a vector listing the vertices of `g` in the
order that they are traversed. If no such trail or cycle exists, throws an error.

## Optional arguments
- If `u` is omitted, a Eulerian trail or cycle is computed with `u = first(vertices(g))`.
"""
function eulerian(g::AbstractSimpleGraph{T}, u::T=first(vertices(g))) where {T}
    is_directed(g) && error("`eulerian` is not yet implemented for directed graphs")
    
    _check_eulerian_input(g, u) # perform basic sanity checks

    g′ = SimpleGraph{T}(nv(g)) # copy `g`
    for e in edges(g)
        add_edge!(g′, e)
    end

    return _eulerian!(g′, u)
end

function _eulerian!(g::AbstractSimpleGraph{T}, u::T) where {T}
    # TODO: This uses Fleury's algorithm which is O(|E|²) in the number of edges |E|.
    #       Hierholzer's algorithm [https://en.wikipedia.org/wiki/Eulerian_path#Hierholzer's_algorithm]
    #       is presumably faster, running in O(|E|) time, but requires needing to keep track
    #       of visited/nonvisited sites in a doubly-linked list/deque.
    trail = T[]

    nverts = nv(g)
    while true
        # if last vertex
        if nverts == 1
            push!(trail, u)
            return trail
        end

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

function _check_eulerian_input(g, u)
    if !has_vertex(g, u)
        error("starting vertex is not in the graph")
    end

    # special case: if any vertex has degree zero
    if any(x->degree(g, x) == 0, vertices(g))
        error("some vertices have degree zero (are isolated) and cannot be reached")
    end

    # vertex degree checks
    du = degree(g, u)
    if iseven(du)     # cycle: start (u) == stop (v) - all nodes must have even degree
        if any(x -> isodd(degree(g, x)), vertices(g))
            error("starting vertex has even degree but there are other vertices with odd degree: a eulerian cycle does not exist")
        end
    else # isodd(du)  # trail: start (u) != stop (v) - all nodes, except u and v, must have even degree
        if count(x -> iseven(degree(g, x)), vertices(g)) != 2
            error("starting vertex has odd degree but the total number of vertices of odd degree is not equal to 2: a eulerian trail does not exist")
        end
    end

    if !is_connected(g)
        error("graph is not connected: a eulerian cycle/trail does not exist")
    end
end