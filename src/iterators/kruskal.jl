# The kruskal algorithms are largely copied from Graphs/src/spanningtrees/kruskal.jl

struct KruskalIterator <: EdgeIterator
    graph::AbstractGraph
    connected_vs::IntDisjointSets
    distmx::AbstractMatrix
    edge_list

    function KruskalIterator(graph, distmx=weights(g); minimize=true)
        is_directed(graph) && throw(ArgumentError("Cannot use Kruskal on a directed graph."))
        weights = Vector{eltype(distmx)}()
        sizehint!(weights, ne(graph))
        edge_list = collect(edges(graph))
        for e in edge_list
            push!(weights, distmx[src(e), dst(e)])
        end
        e = edge_list[sortperm(weights; rev=!minimize)]
        new(graph, IntDisjointSets(nv(graph)), distmx, e)
    end
end

Base.length(t::KruskalIterator) = nv(t.graph)-1
Base.eltype(t::KruskalIterator) = edgetype(t.graph)


"""
    mutable struct KruskalIteratorState

`KruskalIteratorState` is a struct to hold the current state of iteration which is need for the Base.iterate() function.
"""
mutable struct KruskalIteratorState <: AbstractIteratorState
    edge_id::Int
    mst_len::Int
end


function Base.iterate(t::KruskalIterator, state::KruskalIteratorState=KruskalIteratorState(1,1))
    while state.mst_len <= (nv(t.graph)-1)
        i = state.edge_id
        if !in_same_set(t.connected_vs, src(t.edge_list[i]), dst(t.edge_list[i]))
            union!(t.connected_vs, src(t.edge_list[i]), dst(t.edge_list[i]))
            state.mst_len += 1
            return (t.edge_list[i], state)
        end
        state.edge_id += 1
    end
end

