# Common facilities


#################################################
#
#  vertex types
#
################################################

vertex_index(v::Integer) = v

immutable XVertex{X}
    index::Int
    info::X
end

vertex_index(v::XVertex) = v.index

#################################################
#
#  edge types
#
################################################

immutable Edge{V}
    index::Int
    source::V
    target::V
end

edge_index(e::Edge) = e.index
source(e::Edge) = e.source
target(e::Edge) = e.target

immutable XEdge{V,X}
    index::Int
    source::V
    target::V
    info::X
end

edge_index(e::XEdge) = e.index
source(e::XEdge) = e.source
target(e::XEdge) = e.target


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


#################################################
#
#  creation of property maps
#
################################################

immutable RangeMap{I<:Integer, T}
    idx0::I     # the index corresponding to the 0-th element
    values::Vector{T}
    
    RangeMap(rgn::Range1{I}, values::Vector{T}) = new(rgn[1] - 1, values)
end

getindex{I<:Integer,T}(map::RangeMap{I,T}, i::I) = map.values[i-map.idx0]

function create_map_from_list{I<:Integer,T}(vs::Range1{I}, v0::T)
    RangeMap(vs, fill(v0, length(vs)))                
end

function create_map_from_list{T}(vs, v0::T)
    K = eltype(vs)
    Dict{K,T}()
end




