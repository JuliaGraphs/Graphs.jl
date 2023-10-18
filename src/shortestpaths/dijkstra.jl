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

    pathcounts = zeros(Int, nvg)
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
            relax(u,v,distmx,dists,parents,visited,H;
                  allpaths=allpaths,
                  pathcounts=pathcounts,
                  preds=preds
            )
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

function relax(u,
               v, 
               distmx::AbstractMatrix{T}, 
               dists::Vector{T}, 
               parents::Vector{U}, 
               visited::Vector{Bool}, 
               Q::PriorityQueue{U,T};
               allpaths=false,
               pathcounts=nothing,
               preds=nothing,
               forward=true
) where {T<:Real} where {U<:Integer}
    alt = dists[u] + (forward ? distmx[u, v] : distmx[v, u])

    if !visited[v]
        visited[v] = true
        dists[v] = alt
        parents[v] = u
        
        if !isnothing(pathcounts)
            pathcounts[v] += pathcounts[u]
        end
        if allpaths
            preds[v] = [u;]
        end
        Q[v] = alt
    elseif alt < dists[v]
        dists[v] = alt
        parents[v] = u
        #615
        if !isnothing(pathcounts)
            pathcounts[v] = pathcounts[u]
        end
        if allpaths
            resize!(preds[v], 1)
            preds[v][1] = u
        end
        Q[v] = alt
    elseif alt == dists[v]
        if !isnothing(pathcounts)
            pathcounts[v] += pathcounts[u]
        end
        if allpaths
            push!(preds[v], u)
        end
    end
end

"""
    bidijkstra_shortest_paths(g, src, dst, distmx=weights(g));

Perform [Bidirectional Dijkstra's algorithm](https://www.homepages.ucl.ac.uk/~ucahmto/math/2020/05/30/bidirectional-dijkstra.html)
on a graph, computing the shortest path between `src` and `dst`.

# Examples
```jldoctest
julia> using Graphs

julia> bidijkstra_shortest_path(cycle_graph(5), 1, 4)
3-element Vector{Int64}:
 1
 5
 4

julia> bidijkstra_shortest_path(path_graph(5), 1, 4)
4-element Vector{Int64}:
 1
 2
 3
 4
```
"""
function bidijkstra_shortest_path(
    g::AbstractGraph,
    src::U,
    dst::U,
    distmx::AbstractMatrix{T}=weights(g)
) where {T<:Real} where {U<:Integer}
    if src == dst
        return Int[]
    end
    # keep weight of the best seen path and the midpoint vertex
    μ, mid_v = typemax(T), -1
    nvg = nv(g)
    dists_f, dists_b= fill(typemax(T), nvg), fill(typemax(T), nvg)
    parents_f, parents_b= zeros(U, nvg), zeros(U, nvg)
    visited_f, visited_b = zeros(Bool, nvg),zeros(Bool, nvg)
    preds_f, preds_b = fill(Vector{U}(), nvg), fill(Vector{U}(), nvg)
    Qf, Qb = PriorityQueue{U,T}(), PriorityQueue{U,T}()

    dists_f[src], dists_b[dst]= zero(T), zero(T)
    visited_f[src], visited_b[dst]= true, true
    Qf[src], Qb[dst] = zero(T), zero(T)

    while !isempty(Qf) && !isempty(Qb)
        uf, ub = dequeue!(Qf), dequeue!(Qb)

        for v in outneighbors(g, uf)
            relax(uf, v, distmx, dists_f, parents_f, visited_f, Qf)
            if visited_b[v] && (dists_f[uf]+distmx[uf,v]+dists_b[v]) < μ
                # we have found an edge between the forward and backward exploration
                μ = dists_f[uf]+distmx[uf,v]+dists_b[v]
                mid_v = v
            end
        end

        for v in inneighbors(g, ub)
            relax(ub, v, distmx, dists_b, parents_b, visited_b, Qb; forward=false)
            if visited_f[v] && (dists_f[v]+distmx[v,ub]+dists_b[ub]) < μ
                # we have found an edge between the forward and backward exploration
                μ = dists_f[v]+distmx[v,ub]+dists_b[ub]
                mid_v = v
            end
        end
        if dists_f[uf]+dists_b[ub] >= μ
            break
        end
    end
    if mid_v == -1
        # no path exists between source and destination
        return Int[]
    end
    ds_f = DijkstraState{T,U}(parents_f, dists_f, preds_f, zeros(nvg), Vector{U}())
    ds_b = DijkstraState{T,U}(parents_b, dists_b, preds_b, zeros(nvg), Vector{U}())
    if mid_v == src
        return reverse(enumerate_paths(ds_b, mid_v))
    elseif mid_v ==dst
        return enumerate_paths(ds_f, mid_v)
    end
    return vcat(enumerate_paths(ds_f, mid_v), reverse(enumerate_paths(ds_b, mid_v)[1:end-1]))
end

