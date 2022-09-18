"""
    randomwalk(g, s, niter; rng=nothing, seed=nothing)

Perform a random walk on graph `g` starting at vertex `s` and continuing for
a maximum of `niter` steps. Return a vector of vertices visited in order.
"""
function randomwalk(
    g::AG, s::Integer, niter::Integer;
    rng::Union{Nothing, AbstractRNG}=nothing, seed::Union{Nothing, Integer}=nothing
) where AG <: AbstractGraph{T} where T
    s in vertices(g) || throw(BoundsError())
    rng = rng_from_rng_or_seed(rng, seed)
    visited = Vector{T}()
    sizehint!(visited, niter)
    currs = s
    i = 1
    while i <= niter
        push!(visited, currs)
        i += 1
        nbrs = outneighbors(g, currs)
        length(nbrs) == 0 && break
        currs = rand(rng, nbrs)
    end
    return visited[1:(i - 1)]
end

"""
    non_backtracking_randomwalk(g, s, niter; rng=nothing, seed=nothing)

Perform a non-backtracking random walk on directed graph `g` starting at
vertex `s` and continuing for a maximum of `niter` steps. Return a
vector of vertices visited in order.
"""
function non_backtracking_randomwalk end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function non_backtracking_randomwalk(
    g::AG::(!IsDirected), s::Integer, niter::Integer;
    rng::Union{Nothing, AbstractRNG}=nothing, seed::Union{Nothing, Integer}=nothing
) where {T, AG<:AbstractGraph{T}}
    s in vertices(g) || throw(BoundsError())
    rng = rng_from_rng_or_seed(rng, seed)
    visited = Vector{T}()
    sizehint!(visited, niter)
    currs = s
    prev = -1
    i = 1

    push!(visited, currs)
    i += 1
    nbrs = outneighbors(g, currs)
    length(nbrs) == 0 && return visited[1:(i - 1)]
    prev = currs
    currs = rand(rng, nbrs)

    while i <= niter
        push!(visited, currs)
        i += 1
        nbrs = outneighbors(g, currs)
        length(nbrs) == 1 && break
        idnext = rand(rng, 1:(length(nbrs) - 1))
        next = nbrs[idnext]
        if next == prev
            next = nbrs[end]
        end
        prev = currs
        currs = next
    end
    return visited[1:(i - 1)]
end

# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function non_backtracking_randomwalk(
    g::AG::IsDirected, s::Integer, niter::Integer;
    rng::Union{Nothing, AbstractRNG}=nothing, seed::Union{Nothing, Integer}=nothing
) where {T, AG<:AbstractGraph{T}}
    s in vertices(g) || throw(BoundsError())
    rng = rng_from_rng_or_seed(rng, seed)
    visited = Vector{T}()
    sizehint!(visited, niter)
    currs = s
    prev = -1
    i = 1

    while i <= niter
        push!(visited, currs)
        i += 1
        nbrs = outneighbors(g, currs)
        length(nbrs) == 0 && break
        next = rand(rng, nbrs)
        if next == prev
            length(nbrs) == 1 && break
            idnext = rand(rng, 1:(length(nbrs) - 1))
            next = nbrs[idnext]
            if next == prev
                next = nbrs[end]
            end
        end
        prev = currs
        currs = next
    end
    return visited[1:(i - 1)]
end

"""
    self_avoiding_walk(g, s, niter; rng=nothing, seed=nothing)

Perform a [self-avoiding walk](https://en.wikipedia.org/wiki/Self-avoiding_walk)
on graph `g` starting at vertex `s` and continuing for a maximum of `niter` steps.
Return a vector of vertices visited in order.
"""
function self_avoiding_walk(
    g::AG, s::Integer, niter::Integer;
    rng::Union{Nothing, AbstractRNG}=nothing, seed::Union{Nothing, Integer}=nothing
) where AG <: AbstractGraph{T} where T
    s in vertices(g) || throw(BoundsError())
    rng = rng_from_rng_or_seed(rng, seed)
    visited = Vector{T}()
    svisited = Set{T}()
    sizehint!(visited, niter)
    sizehint!(svisited, niter)
    currs = s
    i = 1
    while i <= niter
        push!(visited, currs)
        push!(svisited, currs)
        i += 1
        nbrs = setdiff(Set(outneighbors(g, currs)), svisited)
        length(nbrs) == 0 && break
        currs = rand(rng, collect(nbrs))
    end
    return visited[1:(i - 1)]
end
