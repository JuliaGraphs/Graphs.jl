# DFS implementation optimized from http://www.cs.nott.ac.uk/~psznza/G5BADS03/graphs2.pdf
# Depth-first visit / traversal

"""
    is_cyclic(g)

Return `true` if graph `g` contains a cycle.

### Implementation Notes
The algorithm uses a DFS. Self-loops are counted as cycles.
"""
function is_cyclic end
@enum Vertex_state unvisited visited
@traitfn function is_cyclic(g::AG::(!IsDirected)) where {T,AG<:AbstractGraph{T}}
    visited = falses(nv(g))
    for v in vertices(g)
        visited[v] && continue
        visited[v] = true
        S = [(v, v)]
        while !isempty(S)
            parent, w = pop!(S)
            for u in neighbors(g, w)
                u == w && return true # self-loop
                u == parent && continue
                visited[u] && return true
                visited[u] = true
                push!(S, (w, u))
            end
        end
    end
    return false
end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function is_cyclic(g::AG::IsDirected) where {T,AG<:AbstractGraph{T}}
    # 0 if not visited, 1 if in the current dfs path, 2 if fully explored
    vcolor = zeros(UInt8, nv(g))
    vertex_stack = Vector{T}()
    for v in vertices(g)
        vcolor[v] != 0 && continue
        push!(vertex_stack, v)
        while !isempty(vertex_stack)
            u = vertex_stack[end]
            if vcolor[u] == 0
                vcolor[u] = 1
                for n in outneighbors(g, u)
                    # we hit a loop when reaching back a vertex of the main path
                    if vcolor[n] == 1
                        return true
                    elseif vcolor[n] == 0
                        # we store neighbors, but these are not yet on the path
                        push!(vertex_stack, n)
                    end
                end
            else
                pop!(vertex_stack)
                if vcolor[u] == 1
                    vcolor[u] = 2
                end
            end
        end
    end
    return false
end

"""
    topological_sort(g)

Return a [topological sort](https://en.wikipedia.org/wiki/Topological_sorting) of a directed
graph `g` as a vector of vertices in topological order.

### Implementation Notes
This is currently just an alias for `topological_sort_by_dfs`
"""
function topological_sort end

@traitfn function topological_sort(g::AG::IsDirected) where {AG<:AbstractGraph}
    return topological_sort_by_dfs(g)
end

# Topological sort using DFS
"""
    topological_sort_by_dfs(g)

Return a [topological sort](https://en.wikipedia.org/wiki/Topological_sorting) of a directed
graph `g` as a vector of vertices in topological order.
"""
function topological_sort_by_dfs end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function topological_sort_by_dfs(g::AG::IsDirected) where {T,AG<:AbstractGraph{T}}
    # 0 if not visited, 1 if in the current dfs path, 2 if fully explored
    vcolor = zeros(UInt8, nv(g))
    verts = Vector{T}()
    vertex_stack = Vector{T}()
    for v in vertices(g)
        vcolor[v] != 0 && continue
        push!(vertex_stack, v)
        while !isempty(vertex_stack)
            u = vertex_stack[end]
            if vcolor[u] == 0
                vcolor[u] = 1
                for n in outneighbors(g, u)
                    # we hit a loop when reaching back a vertex of the main path
                    if vcolor[n] == 1
                        error("The input graph contains at least one loop.") # TODO 0.7 should we use a different error?
                    elseif vcolor[n] == 0
                        # we store neighbors, but these are not yet on the path
                        push!(vertex_stack, n)
                    end
                end
            else
                pop!(vertex_stack)
                # if vcolor[u] == 2, the vertex was already explored and added to verts
                if vcolor[u] == 1
                    vcolor[u] = 2
                    pushfirst!(verts, u)
                end
            end
        end
    end
    return verts
end

"""
    dfs_tree(g, s)

Return an ordered vector of vertices representing a directed acyclic graph based on
depth-first traversal of the graph `g` starting with source vertex `s`.
"""
dfs_tree(g::AbstractGraph, s::Integer; dir=:out) = tree(dfs_parents(g, s; dir=dir))

"""
    dfs_parents(g, s[; dir=:out])

Perform a depth-first search of graph `g` starting from vertex `s`.
Return a vector of parent vertices indexed by vertex. If `dir` is specified,
use the corresponding edge direction (`:in` and `:out` are acceptable values).

### Implementation Notes
This version of DFS is iterative.
"""
function dfs_parents(g::AbstractGraph, s::Integer; dir=:out)
    return if (dir == :out)
        _dfs_parents(g, s, outneighbors)
    else
        _dfs_parents(g, s, inneighbors)
    end
end

function _dfs_parents(g::AbstractGraph{T}, s::Integer, neighborfn::Function) where {T}
    parents = zeros(T, nv(g))

    seen = zeros(Bool, nv(g))
    S = Vector{T}([s])
    seen[s] = true
    parents[s] = s
    while !isempty(S)
        v = S[end]
        u = 0
        for n in neighborfn(g, v)
            if !seen[n]
                u = n
                break
            end
        end
        if u == 0
            pop!(S)
        else
            seen[u] = true
            push!(S, u)
            parents[u] = v
        end
    end
    return parents
end
