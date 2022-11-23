# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# A* shortest-path algorithm

"""
    struct AStar <: ShortestPathAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use the [A* search algorithm](http://en.wikipedia.org/wiki/A%2A_search_algorithm).
An optional `heuristic` function may be supplied. If missing, the heuristic is set to
`n -> 0`.

### Implementation Notes
`AStar` supports the following shortest-path functionality:
- non-negative distance matrices / weights
- single destination
"""
struct AStar{F<:Function} <: ShortestPathAlgorithm
    heuristic::F
end

AStar(T::Type=Float64) = AStar(n -> zero(T))

struct AStarResult{T,U<:Integer} <: ShortestPathResult
    path::Vector{U}
    dist::T
end

function reconstruct_path!(
    total_path, # a vector to be filled with the shortest path
    came_from, # a vector holding the parent of each node in the A* exploration
    end_idx, # the end vertex
    g,
) # the graph
    curr_idx = end_idx
    while came_from[curr_idx] != curr_idx
        pushfirst!(total_path, came_from[curr_idx])
        curr_idx = came_from[curr_idx]
    end
    return push!(total_path, end_idx)
end

function a_star_impl!(
    g, # the graph
    goal, # the end vertex
    open_set, # an initialized heap containing the active vertices
    closed_set, # an (initialized) color-map to indicate status of vertices
    g_score, # a vector holding g scores for each node
    f_score, # a vector holding f scores for each node
    came_from, # a vector holding the parent of each node in the A* exploration
    distmx,
    heuristic,
)
    T = eltype(g)
    total_path = Vector{T}()

    @inbounds while !isempty(open_set)
        current = dequeue!(open_set)

        if current == goal
            reconstruct_path!(total_path, came_from, current, g)
            return total_path
        end

        closed_set[current] = true

        for neighbor in outneighbors(g, current)
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

function calc_dist(path, distmx)
    T = eltype(distmx)
    isempty(path) && return typemax(T)
    rest_of_path = copy(path)
    dist = zero(T)
    u = pop!(rest_of_path)
    while !isempty(rest_of_path)
        v = pop!(rest_of_path)
        dist += distmx[u, v]
        u = v
    end
    return dist
end

function shortest_paths(
    g::AbstractGraph, s::Integer, t::Integer, distmx::AbstractMatrix, alg::AStar
)
    T = eltype(distmx)

    # if we do checkbounds here, we can use @inbounds in a_star_impl!
    checkbounds(distmx, Base.OneTo(nv(g)), Base.OneTo(nv(g)))

    open_set = PriorityQueue{Integer,T}()
    enqueue!(open_set, s, 0)

    closed_set = zeros(Bool, nv(g))

    g_score = fill(Inf, nv(g))
    g_score[s] = 0

    f_score = fill(Inf, nv(g))
    f_score[s] = alg.heuristic(s)

    came_from = -ones(Integer, nv(g))
    came_from[s] = s

    path = a_star_impl!(
        g, t, open_set, closed_set, g_score, f_score, came_from, distmx, alg.heuristic
    )
    return AStarResult(path, calc_dist(path, distmx))
end

function shortest_paths(g::AbstractGraph, s::Integer, t::Integer, alg::AStar)
    return shortest_paths(g, s, t, weights(g), alg)
end
paths(s::AStarResult) = [s.path]
paths(s::AStarResult, v::Integer) = throw(ArgumentError("AStar produces at most one path."))
dists(s::AStarResult) = [[s.dist]]
dists(s::AStarResult, v::Integer) = throw(ArgumentError("AStar produces at most one path."))
