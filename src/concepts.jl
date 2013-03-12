# Graph concepts

# the root type of all graphs
abstract AbstractGraph

# for graphs where vertices can be directly enumerated
abstract AbstractVertexListGraph <: AbstractGraph

# for graphs where edges can be directly enumerated
abstract AbstractEdgeListGraph <: AbstractVertexListGraph

# all graphs where outgoing neigbors of each vertex can be enumerated
abstract AbstractAdjacencyGraph <: AbstractVertexListGraph

# all graphs where incoming & outgoing neigbors of each vertex can be enumerated
abstract AbstractBidirAdjacencyGraph <: AbstractVertexListGraph

# all graphs where outgoing edges of each vertex can be enumerated
abstract AbstractIncidenceGraph <: AbstractAdjacencyGraph

# all graphs where both incoming & outgoing edges of each vertex can be enumerated
abstract AbstractBidirIncidenceGraph <: AbstractIncidenceGraph

# all graphs where one can test the existence of an edge (u, v) efficient
abstract AbstractAdjacencyMatrix <: AbstractVertexListGraph

typealias AbstractBidirGraph Union(AbstractBidirAdjacencyGraph, AbstractBidirIncidenceGraph)


# Tree concepts

abstract AbstractTree

abstract AbstractVertexListTree <: AbstractTree

abstract AbstractAdjacencyTree <: AbstractVertexListTree

abstract AbstractBidirAdjacencyTree <: AbstractAdjacencyTree
