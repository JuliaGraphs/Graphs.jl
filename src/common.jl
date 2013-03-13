# Common facilities

#################################################
#
#  a variety of edge types
#
################################################

immutable Edge{V}
    source::V
    target::V
end

immutable IndexedEdge{I, V}
    index::I
    source::V
    target::V
end

immutable XEdge{V, X}
    source::V
    target::V
    info::X
end

immutable IndexedXEdge{I, V, X}
    index::I
    source::V
    target::V
    info::X
end

source(e::Union(Edge, IndexedEdge, XEdge, IndexedXEdge)) = e.source
target(e::Union(Edge, IndexedEdge, XEdge, IndexedXEdge)) = e.target

source(e::Union(Edge, IndexedEdge, XEdge, IndexedXEdge), g::AbstractGraph) = e.source
target(e::Union(Edge, IndexedEdge, XEdge, IndexedXEdge), g::AbstractGraph) = e.target


#################################################
#
#  iteration
#
################################################

immutable VecProxy{A, I}
    vec::A
    len::Int
    inds::I
end

vec_proxy{A,I}(vec::A, inds::I) = VecProxy(vec, length(inds), inds)

length(proxy::VecProxy) = proxy.len
isempty(proxy::VecProxy) = isempty(proxy.inds)
getindex(proxy::VecProxy, i::Integer) = proxy.vec[proxy.inds[i]]

start(proxy::VecProxy) = 1
next(proxy::VecProxy, s::Int) = (proxy.vec[proxy.inds[s]], s+1)
done(proxy::VecProxy, s::Int) =  s > proxy.len


# out_neighbors proxy

immutable OutNeighborsProxy{EList}
    len::Int
    edges::EList
end

out_neighbors_proxy{EList}(edges::EList) = OutNeighborsProxy(length(edges), edges)

length(proxy::OutNeighborsProxy) = proxy.len
isempty(proxy::OutNeighborsProxy) = proxy.len == 0
getindex(proxy::OutNeighborsProxy, i::Integer) = target(proxy.edges[i])

start(proxy::OutNeighborsProxy) = 1
next(proxy::OutNeighborsProxy, s::Int) = (proxy[s], s+1)
done(proxy::OutNeighborsProxy, s::Int) =  s > proxy.len



