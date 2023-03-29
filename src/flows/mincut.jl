"""
    mincut(flow_graph::Graphs.IsDirected, source::Integer, target::Integer, capacity_matrix::AbstractMatrix, algorithm::AbstractFlowAlgorithm)

Compute the min-cut between `source` and `target` for the given graph.
First computes the maxflow using `algorithm` and then builds the partition of the residual graph
Returns a triplet `(part1, part2, flow)` with the partition containing the source, the partition containing the target (the rest) and the min-cut(max-flow) value
"""
function mincut(
        flow_graph::Graphs.DiGraph,             # the input graph
        source::Integer,                       # the source vertex
        target::Integer,                       # the target vertex
        capacity_matrix::AbstractMatrix,       # edge flow capacities
        algorithm::AbstractFlowAlgorithm       # keyword argument for algorithm
    )
    flow, flow_matrix = maximum_flow(flow_graph, source, target, capacity_matrix, algorithm)
    residual_matrix = spzeros(Graphs.nv(flow_graph),Graphs.nv(flow_graph))
    for edge in Graphs.edges(flow_graph)
        residual_matrix[edge.src,edge.dst] = max(0.0, capacity_matrix[edge.src,edge.dst] - flow_matrix[edge.src,edge.dst])
        residual_matrix[edge.dst,edge.src] = max(0.0, capacity_matrix[edge.dst,edge.src] - flow_matrix[edge.dst,edge.src])
    end
    part1 = typeof(source)[]
    queue = [source]
    while !isempty(queue)
        node = pop!(queue)
        push!(part1, node)
        dests = [dst for dst in 1:Graphs.nv(flow_graph) if residual_matrix[node,dst]>0.0 && dst ∉ part1 && dst ∉ queue]
        append!(queue, dests)
    end
    part2 = [node for node in 1:Graphs.nv(flow_graph) if node ∉ part1]
    return (part1, part2, flow)
end
