# Graph concepts

# the root type of all graphs
abstract AbstractGraph

# for graphs where vertices can be directly enumerated
abstract AbstractVertexListGraph <: AbstractGraph

# for graphs where edges can be directly enumerated
abstract AbstractEdgeListGraph <: AbstractVertexListGraph

# all graphs where outgoing edges of each vertex can be enumerated
abstract AbstractIncidenceGraph <: AbstractVertexListGraph

# all graphs where both incoming & outgoing edges of each vertex can be enumerated
abstract AbstractBidirectionalGraph <: AbstractIncidenceGraph

# all graphs where adjacent vertices (neighbors) of each vertex can be enumerated
abstract AbstractAdjacencyGraph <: AbstractVertexListGraph

# all graphs where one can test the existence of an edge (u, v) efficient
abstract AbstractAdjacencyMatrix <: AbstractVertexListGraph

