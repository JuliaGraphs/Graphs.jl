"""
    struct DijkstraState{T, U}

An [`AbstractPathState`](@ref) designed for Dijkstra shortest-paths calculations.
"""
struct DijkstraState{T<:Real,U<:Integer} <: AbstractPathState
    parents::Vector{U}
    dists::Vector{T}
    predecessors::Vector{Vector{U}}
    pathcounts::Vector{Float64}
    closest_vertices::Vector{U}
end

"""
    dijkstra_shortest_paths(g, srcs, distmx=weights(g));

Perform [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
on a graph, computing shortest distances between `srcs` and all other vertices.
Return a [`Graphs.DijkstraState`](@ref) that contains various traversal information.


### Optional Arguments
* `allpaths=false`: If true,

`state.predecessors` holds a vector, indexed by vertex,
of all the predecessors discovered during shortest-path calculations.
This keeps track of all parents when there are multiple shortest paths available from the source.

`state.pathcounts` holds a vector, indexed by vertex, of the number of shortest paths from the source to that vertex.
The path count of a source vertex is always `1.0`. The path count of an unreached vertex is always `0.0`.

* `trackvertices=false`: If true,

`state.closest_vertices` holds a vector of all vertices in the graph ordered from closest to farthest.

* `maxdist` (default: `typemax(T)`) specifies the maximum path distance beyond which all path distances are assumed to be infinite (that is, they do not exist).

### Performance
If using a sparse matrix for `distmx`, you *may* achieve better performance by passing in a transpose of its sparse transpose.
That is, assuming `D` is the sparse distance matrix:
```
D = transpose(sparse(transpose(D)))
```
Be aware that realizing the sparse transpose of `D` incurs a heavy one-time penalty, so this strategy should only be used
when multiple calls to `dijkstra_shortest_paths` with the distance matrix are planned.

# Examples
```jldoctest
julia> using Graphs

julia> ds = dijkstra_shortest_paths(cycle_graph(5), 2);

julia> ds.dists
5-element Vector{Int64}:
 1
 0
 1
 2
 2

julia> ds = dijkstra_shortest_paths(path_graph(5), 2);

julia> ds.dists
5-element Vector{Int64}:
 1
 0
 1
 2
 3
```
"""
function dijkstra_shortest_paths(
    g::AbstractGraph,
    srcs::Vector{U},
    distmx::AbstractMatrix{T}=weights(g);
    allpaths=false,
    trackvertices=false,
    maxdist=typemax(T)
    ) where T <: Real where U <: Integer

    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    visited = zeros(Bool, nvg)

    pathcounts = zeros(nvg)
    preds = fill(Vector{U}(), nvg)
    H = PriorityQueue{U,T}()
    # fill creates only one array.

    for src in srcs
        dists[src] = zero(T)
        visited[src] = true
        pathcounts[src] = one(Float64)
        H[src] = zero(T)
    end

    closest_vertices = Vector{U}()  # Maintains vertices in order of distances from source
    sizehint!(closest_vertices, nvg)

    while !isempty(H)
        u = dequeue!(H)

        if trackvertices
            push!(closest_vertices, u)
        end

        d = dists[u] # Cannot be typemax if `u` is in the queue
        for v in outneighbors(g, u)
            alt = d + distmx[u, v]

            alt > maxdist && continue

            if !visited[v]
                visited[v] = true
                dists[v] = alt
                parents[v] = u

                pathcounts[v] += pathcounts[u]
                if allpaths
                    preds[v] = [u;]
                end
                H[v] = alt
            elseif alt < dists[v]
                dists[v] = alt
                parents[v] = u
                #615
                pathcounts[v] = pathcounts[u]
                if allpaths
                    resize!(preds[v], 1)
                    preds[v][1] = u
                end
                H[v] = alt
            elseif alt == dists[v]
                pathcounts[v] += pathcounts[u]
                if allpaths
                    push!(preds[v], u)
                end
            end
        end
    end

    if trackvertices
        for s in vertices(g)
            if !visited[s]
                push!(closest_vertices, s)
            end
        end
    end

    for src in srcs
        pathcounts[src] = one(Float64)
        parents[src] = 0
        empty!(preds[src])
    end

    return DijkstraState{T,U}(parents, dists, preds, pathcounts, closest_vertices)
end

function dijkstra_shortest_paths(
    g::AbstractGraph,
    src::Integer,
    distmx::AbstractMatrix=weights(g);
    allpaths=false,
    trackvertices=false,
    maxdist=typemax(eltype(distmx))
)
    return dijkstra_shortest_paths(
        g, [src;], distmx; allpaths=allpaths, trackvertices=trackvertices, maxdist=maxdist
    )
end
