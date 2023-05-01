# Parts of this code was written by @jpfairbanks.

# Parallel Breadth-first search / traversal using a frontier based parallelized
# approach.

#################################################
#
# Parallel frontier based Breadth-first search approach
#
#################################################
"""
    ThreadQueue

A thread safe queue implementation for using as the queue for BFS.
"""
struct ThreadQueue{T,N<:Integer}
    data::Vector{T}
    head::Atomic{N} # Index of the head
    tail::Atomic{N} # Index of the tail
end

function ThreadQueue(T::Type, maxlength::N) where {N<:Integer}
    q = ThreadQueue(Vector{T}(undef, maxlength), Atomic{N}(1), Atomic{N}(1))
    return q
end

function push!(q::ThreadQueue{T,N}, val::T) where {T} where {N}
    # TODO: check that head > tail
    offset = atomic_add!(q.tail, one(N))
    q.data[offset] = val
    return offset
end

function popfirst!(q::ThreadQueue{T,N}) where {T} where {N}
    # TODO: check that head < tail
    offset = atomic_add!(q.head, one(N))
    return q.data[offset]
end

function isempty(q::ThreadQueue{T,N}) where {T} where {N}
    return (q.head[] == q.tail[]) && q.head != one(N)
end

function getindex(q::ThreadQueue{T}, iter) where {T}
    return q.data[iter]
end

# Traverses the vertices in the queue and adds newly found successors to the queue.
function bfskernel(
    next::ThreadQueue, # Thread safe queue to add vertices to
    g::AbstractGraph, # The graph
    parents::Array{Atomic{T}}, # Parents array
    level::Array{T}, # Vertices in the current frontier
) where {T<:Integer}
    @threads for src in level
        vertexneighbors = neighbors(g, src) # Get the neighbors of the vertex
        for vertex in vertexneighbors
            # Atomically check and set parent value if not set yet.
            parent = atomic_cas!(parents[vertex], zero(T), src)
            if parent == 0
                push!(next, vertex) # Push onto queue if newly found
            end
        end
    end
end

"""
    bfs_tree!(g, src, parents)

Provide a parallel breadth-first traversal of the graph `g` starting with source vertex `s`,
and return a parents array. The returned array is an Array of `Atomic` integers.

### Implementation Notes
This function uses `@threads` for parallelism which depends on the `JULIA_NUM_THREADS`
environment variable to decide the number of threads to use. Refer `@threads` documentation
for more details.
"""
function bfs_tree!(
    next::ThreadQueue, # Thread safe queue to add vertices to
    g::AbstractGraph, # The graph
    source::T, # Source vertex
    parents::Array{Atomic{T}}, # Parents array
) where {T<:Integer}
    parents[source][] = source # Set source to source
    push!(next, source) # Add source to the queue
    while !isempty(next)
        level = next[next.head[]:(next.tail[] - 1)] # Get vertices in the frontier
        next.head[] = next.tail[] # reset the queue
        bfskernel(next, g, parents, level) # Find new frontier
    end
    return parents
end

function bfs_tree(g::AbstractGraph, source::T, nv::T) where {T<:Integer}
    next = ThreadQueue(T, nv) # Initialize threadqueue
    parents = [Atomic{T}(0) for i in 1:nv] # Create parents array
    Parallel.bfs_tree!(next, g, source, parents)
    return Graphs.tree([i[] for i in parents])
end

function bfs_tree(g::AbstractGraph, source::T) where {T<:Integer}
    nvg = nv(g)
    return Parallel.bfs_tree(g, source, nvg)
end
