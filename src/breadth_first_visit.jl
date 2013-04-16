# Breadth-first search / traversal

#################################################
#
#  Breadth-first visitor
#
#################################################

abstract AbstractBFSVisitor

# trivial implementation

# invoked when a vertex v is encountered for the first time
# (before the algorithm puts the vertex to the queue)
# this function returns whether to continue search
discover_vertex!(vis::AbstractBFSVisitor, v) = true

# invoked when a vertex v is popped from the queue 
# (before the algorithm starts to examine its outgoing edges)
open_vertex!(vis::AbstractBFSVisitor, v) = nothing

# invoked when an out-edge is discovered & examined
examine_edge!(vis::AbstractBFSVisitor, u, v, color::Int) = nothing

# invoked when all out-edges/neighbors of an vertex have been examined
close_vertex!(vis::AbstractBFSVisitor, v) = nothing


#################################################
#
#  Breadth-first visit
#
#################################################

function breadth_first_visit_impl!(
    graph::AbstractGraph,   # the graph
    queue,                  # an (initialized) queue that stores the active vertices    
    colormap::Vector{Int},          # an (initialized) color-map to indicate status of vertices
    visitor::AbstractBFSVisitor)    # the visitor
    
    @graph_requires graph adjacency_list
    
    while !isempty(queue)
        u = dequeue!(queue)
        open_vertex!(visitor, u)
        
        for v in out_neighbors(u, graph)
            v_color::Int = colormap[v]
            examine_edge!(visitor, u, v, v_color)
                        
            if v_color == 0
                colormap[vertex_index(v, graph)] = 1
                if !discover_vertex!(visitor, v)
                    return
                end
                enqueue!(queue, v)
            end                
        end
        
        colormap[vertex_index(u, graph)] = 2
        close_vertex!(visitor, u)            
    end    
    nothing
end


function breadth_first_visit{V,E}(
    graph::AbstractGraph{V,E}, s::V, visitor::AbstractBFSVisitor; 
    colormap=nothing)
    
    if colormap == nothing
        colormap = zeros(Int, num_vertices(graph))       
    end
    
    que = queue(V)
    
    colormap[vertex_index(s, graph)] = 1
    discover_vertex!(visitor, s)
    enqueue!(que, s)
    
    breadth_first_visit_impl!(graph, que, colormap, visitor)
end


function breadth_first_visit{V,E}(
    graph::AbstractGraph{V,E}, sources::AbstractVector{V}, visitor::AbstractBFSVisitor; 
    colormap=nothing)
    
    if colormap == nothing
        colormap = zeros(Int, num_vertices(graph)) 
    end
    
    que = queue(V)
    
    for s in sources
        colormap[vertex_index(s, graph)] = 1
        discover_vertex!(visitor, s)
        enqueue!(que, s)
    end
    
    breadth_first_visit_impl!(graph, que, colormap, visitor)
end


#################################################
#
#  Convenient functions
#
#################################################

# Get a list of vertices by BFS

type BFSVertexListVisitor{V} <: AbstractBFSVisitor
    vertices::Vector{V}
    
    function BFSVertexListVisitor(n::Integer)
        vs = Array(V, 0)
        sizehint(vs, n)
        new(vs)        
    end
end

function discover_vertex!{V}(visitor::BFSVertexListVisitor{V}, v::V)
    push!(visitor.vertices, v)
    true
end

function breadth_first_vertex_list{V,E}(graph::AbstractGraph{V,E}, sources)
    visitor = BFSVertexListVisitor{V}(num_vertices(graph))
    breadth_first_visit(graph, sources, visitor)
    visitor.vertices::Vector{V}
end


# Get the map of the distances from vertices to source by BFS

type BFSDistanceVisitor <: AbstractBFSVisitor
    dists::Vector{Int}
end

function examine_edge!(visitor::BFSDistanceVisitor, u, v, color::Int)
    if color == 0
        dists = visitor.dists
        dists[vertex_index(v)] = dists[vertex_index(u)] + 1
    end
end

function breadth_first_distances!{V,E,DMap}(graph::AbstractGraph{V,E}, s::V, dists::DMap)
    visitor = BFSDistanceVisitor(dists)
    dists[vertex_index(s)] = 0  
    breadth_first_visit(graph, s, visitor)
    dists                
end

function breadth_first_distances!{V,E,DMap}(graph::AbstractGraph{V,E}, sources::AbstractVector{V}, dists::DMap)
    visitor = BFSDistanceVisitor(dists)
    for s in sources        
        dists[vertex_index(s)] = 0  
    end
    breadth_first_visit(graph, sources, visitor)
    dists                
end

function breadth_first_distances(graph::AbstractGraph, sources; defaultdist::Int=-1)
    dists = fill(defaultdist, num_vertices(graph))    
    breadth_first_distances!(graph, sources, dists)
end

