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

source{V}(e::Edge{V}, g::AbstractGraph{V}) = e.source
target{V}(e::Edge{V}, g::AbstractGraph{V}) = e.target


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
#  convenient functions
#
################################################

function collect_edges{V,E}(graph::AbstractGraph{V,E})
            
    if implements_edge_list(graph)
        collect(edges(graph))                
            
    elseif implements_vertex_list(graph) && implements_incidence_list(graph)
        edges = Array(E, 0)    
        sizehint(edges, num_edges(graph))
    
        for v in vertices(graph)
            for e in out_edges(v, graph)
                push!(edges, e)
            end
        end    
        edges
    else
        throw(ArgumentError("graph must implement either edge_list or incidence_list."))
    end    
end


immutable WeightedEdge{E,W}
    edge::E
    weight::W
end

< {E,W}(a::WeightedEdge{E,W}, b::WeightedEdge{E,W}) = a.weight < b.weight
> {E,W}(a::WeightedEdge{E,W}, b::WeightedEdge{E,W}) = a.weight > b.weight

function collect_weighted_edges{V,E,W}(graph::AbstractGraph{V,E}, weights::AbstractVector{W})
    
    @graph_requires graph edge_map
    
    wedges = Array(WeightedEdge{E,W}, 0)
    sizehint(wedges, num_edges(graph))
            
    if implements_edge_list(graph)
        for e in edges(graph)
            w = weights[edge_index(e, graph)]
            push!(wedges, WeightedEdge(e, w))
        end               
            
    elseif implements_vertex_list(graph) && implements_incidence_list(graph)    
        for v in vertices(graph)
            for e in out_edges(v, graph)
                w = weights[edge_index(e, graph)]
                push!(wedges, WeightedEdge(e, w))
            end
        end    
    else
        throw(ArgumentError("graph must implement either edge_list or incidence_list."))
    end  
    
    return wedges  
end







