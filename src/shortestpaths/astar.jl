# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# A* shortest-path algorithm

function reconstruct_path!(
    total_path, # a vector to be filled with the shortest path
    came_from, # a vector holding the parent of each node in the A* exploration
    end_idx, # the end vertex
    g,  # the graph
    edgetype_to_return::Type{E}=edgetype(g),
) where {E<:AbstractEdge}
    curr_idx = end_idx
    while came_from[curr_idx] != curr_idx
        pushfirst!(total_path, edgetype_to_return(came_from[curr_idx], curr_idx))
        curr_idx = came_from[curr_idx]
    end
end

function a_star_impl!(
    g, # the graph
    goal, # the end vertex
    open_set, # an initialized heap containing the active vertices
    closed_set, # an (initialized) color-map to indicate status of vertices
    g_score, # a vector holding g scores for each node
    came_from, # a vector holding the parent of each node in the A* exploration
    distmx,
    heuristic,
    edgetype_to_return::Type{E},
) where {E<:AbstractEdge}
    total_path = Vector{edgetype_to_return}()

    @inbounds while !isempty(open_set)
        current = dequeue!(open_set)

        if current == goal
            reconstruct_path!(total_path, came_from, current, g, edgetype_to_return)
            return total_path
        end

        closed_set[current] = true

        for neighbor in Graphs.outneighbors(g, current)
            closed_set[neighbor] && continue

            tentative_g_score = g_score[current] + distmx[current, neighbor]

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
    a_star(g, s, t[, distmx][, heuristic][, edgetype_to_return])

Compute a shortest path using the [A* search algorithm](http://en.wikipedia.org/wiki/A%2A_search_algorithm).

# Arguments
- `g::AbstractGraph`: the graph
- `s::Integer`: the source vertex
- `t::Integer`: the target vertex
- `distmx::AbstractMatrix`: an optional (possibly sparse) `n × n` matrix of edge weights. It is set to `weights(g)` by default (which itself falls back on [`Graphs.DefaultDistance`](@ref)).
- `heuristic`: an optional function mapping each vertex to a lower estimate of the remaining distance from `v` to `t`. It is set to `v -> 0` by default (which corresponds to Dijkstra's algorithm). Note that the heuristic values should have the same type as the edge weights!
- `edgetype_to_return::Type{E}`: the eltype `E<:AbstractEdge` of the vector of edges returned. It is set to `edgetype(g)` by default. Note that the two-argument constructor `E(u, v)` must be defined, even for weighted edges: if it isn't, consider using `E = Graphs.SimpleEdge`.
"""
function a_star(
    g::AbstractGraph{U},  # the g
    s::Integer,                       # the start vertex
    t::Integer,                       # the end vertex
    distmx::AbstractMatrix{T}=weights(g),
    heuristic=n -> zero(T),
    edgetype_to_return::Type{E}=edgetype(g),
) where {T,U,E<:AbstractEdge}
    # if we do checkbounds here, we can use @inbounds in a_star_impl!
    checkbounds(distmx, Base.OneTo(nv(g)), Base.OneTo(nv(g)))

    open_set = PriorityQueue{U,T}()
    enqueue!(open_set, s, 0)

    closed_set = zeros(Bool, nv(g))

    g_score = fill(Inf, nv(g))
    g_score[s] = 0

    came_from = fill(-one(s), nv(g))
    came_from[s] = s

    return a_star_impl!(
        g,
        t,
        open_set,
        closed_set,
        g_score,
        came_from,
        distmx,
        heuristic,
        edgetype_to_return,
    )
end
