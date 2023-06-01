# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# A* shortest-path algorithm

function reconstruct_path!(total_path, # a vector to be filled with the shortest path
    came_from, # a vector holding the parent of each node in the A* exploration
    end_idx, # the end vertex
    g,  # the graph
    ) where {E<:AbstractEdge}
    curr_idx = end_idx
    while came_from[curr_idx] != curr_idx
        pushfirst!(total_path, E(came_from[curr_idx], curr_idx))
        curr_idx = came_from[curr_idx]
    end
end

function a_star_impl!(g::AbstractGraph{V, E}, # the graph
    goal, # the end vertex
    open_set, # an initialized heap containing the active vertices
    closed_set, # an (initialized) color-map to indicate status of vertices
    g_score, # a vector holding g scores for each node
    came_from, # a vector holding the parent of each node in the A* exploration
    vertex_dist,
    heuristic,) where {V, E}

    total_path = Vector{E}()

    @inbounds while !isempty(open_set)
        current = dequeue!(open_set)

        if current == goal
            reconstruct_path!(total_path, came_from, current, g, E)
            return total_path
        end

        closed_set[current] = true

        for neighbor in outneighbors(g, current)
            closed_set[neighbor] && continue

            tentative_g_score = g_score[current] + vertex_dist(g, current, neighbor)

            if tentative_g_score < g_score[neighbor]
                g_score[neighbor] = tentative_g_score
                priority = tentative_g_score + heuristic(neighbor)
                open_set[neighbor] = priority
                came_from[neighbor] = current
            end
        end
    end
    return total_path
end

"""
    a_star(g, s, t[, distmx][, heuristic][])

Compute a shortest path using the [A* search algorithm](http://en.wikipedia.org/wiki/A%2A_search_algorithm).

# Arguments
- `g::AbstractGraph`: the graph
- `s::Integer`: the source vertex
- `t::Integer`: the target vertex
- `vertex_dist::Function`: an optional function returning the distance between the vertices `u` and `v` in `g`
- `heuristic::Function`: an optional function mapping each vertex to a lower estimate of the remaining distance from `v` to `t`. It is set to `v -> 0` by default (which corresponds to Dijkstra's algorithm)
"""
function a_star(g::AbstractGraph{V, E},  # the graph
    s::AbstractVertex,                   # the start vertex
    t::AbstractVertex,                   # the end vertex
    vertex_dist::Function = (g, u, v) -> minimum(weight.(get_edges(g, u, v))),
    distmx::AbstractMatrix{T}=weights(g),
    heuristic::Function=n -> zero(T)) where {T, V<:AbstractVertex, E<:AbstractEdge}
    # if we do checkbounds here, we can use @inbounds in a_star_impl!
    checkbounds(distmx, Base.OneTo(nv(g)), Base.OneTo(nv(g)))

    open_set = PriorityQueue{V, T}()
    enqueue!(open_set, s, 0)

    closed_set = get_vertex_container(g, Bool)
    closed_set[vertices(g)] .= false

    g_score = get_vertex_container(g, T)
    g_score[vertices(g)] .= typemax(T)
    g_score[s] = 0

    came_from = get_vertex_container(g, T)
    came_from[vertices(g)] .= s

    a_star_impl!(
        g,
        t,
        open_set,
        closed_set,
        g_score,
        came_from,
        distmx,
        heuristic,
    )
end

"""
    a_star(g, s, t[, distmx][, heuristic][])

Compute a shortest path using the [A* search algorithm](http://en.wikipedia.org/wiki/A%2A_search_algorithm).

# Arguments
- `g::AbstractGraph`: the graph
- `s::Integer`: the source vertex
- `t::Integer`: the target vertex
- `distmx::AbstractMatrix`: an optional (possibly sparse) `n × n` matrix of edge weights. It is set to `weights(g)` by default (which itself falls back on [`Graphs.DefaultDistance`](@ref)).
- `heuristic::Function`: an optional function mapping each vertex to a lower estimate of the remaining distance from `v` to `t`. It is set to `v -> 0` by default (which corresponds to Dijkstra's algorithm)
"""
a_star(g::AbstractGraph{V, E},  # the graph
    s::AbstractVertex,          # the start vertex
    t::AbstractVertex,          # the end vertex
    distmx::AbstractMatrix{T}=weights(g),
    heuristic::Function=n -> zero(T)) where {T, V<:AbstractVertex, E<:AbstractEdge}
    = a_star(g, s, t, (g, s, t)->distmx[u, v], heuristic)
