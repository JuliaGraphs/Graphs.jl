# Method when using Boykov-Kolmogorov as a subroutine
# Kishimoto algorithm

@traitfn function kishimoto(
        flow_graph::::Graphs.IsDirected,               # the input graph
        source::Integer,                           # the source vertex
        target::Integer,                           # the target vertex
        capacity_matrix::AbstractMatrix,           # edge flow capacities
        flow_algorithm::BoykovKolmogorovAlgorithm, # keyword argument for algorithm
        routes::Int                                # keyword argument for routes
    )
    # Initialisation
    flow, F, labels = maximum_flow(flow_graph, source, target,
    capacity_matrix, algorithm = flow_algorithm)
    restriction = flow / routes
    flow, F, labels = maximum_flow(flow_graph, source, target, capacity_matrix,
    algorithm = flow_algorithm, restriction = restriction)

    # Loop condition : approximatively not equal is enforced by floating precision
    i = 1
    while flow < routes * restriction && flow ≉ routes * restriction
        restriction = (flow - i * restriction) / (routes - i)
        i += 1
        flow, F, labels = maximum_flow(flow_graph, source, target, capacity_matrix,
        algorithm = flow_algorithm, restriction = restriction)
    end

    # End
    return flow, F, labels
end


"""
    kishimoto(flow_graph, source, target, capacity_matrix, flow_algorithm, routes)

Compute the maximum multiroute flow (for an integer number of `route`s)
between `source` and `target` in `flow_graph` with capacities in `capacity_matrix`
using the [Kishimoto algorithm](http://dx.doi.org/10.1109/ICCS.1992.255031).
Return the value of the multiroute flow as well as the final flow matrix,
along with a multiroute cut if Boykov-Kolmogorov is used as a subroutine.
"""
function kishimoto end
@traitfn function kishimoto(
        flow_graph::::Graphs.IsDirected,           # the input graph
        source::Integer,                       # the source vertex
        target::Integer,                       # the target vertex
        capacity_matrix::AbstractMatrix,       # edge flow capacities
        flow_algorithm::AbstractFlowAlgorithm, # keyword argument for algorithm
        routes::Int                            # keyword argument for routes
    )
    # Initialisation
    flow, F = maximum_flow(flow_graph, source, target,
    capacity_matrix, algorithm = flow_algorithm)
    restriction = flow / routes

    flow, F = maximum_flow(flow_graph, source, target, capacity_matrix,
    algorithm = flow_algorithm, restriction = restriction)

    # Loop condition : approximatively not equal is enforced by floating precision
    i = 1
    while flow < routes * restriction && flow ≉ routes * restriction
        restriction = (flow - i * restriction) / (routes - i)
        i += 1
        flow, F = maximum_flow(flow_graph, source, target, capacity_matrix,
        algorithm = flow_algorithm, restriction = restriction)
    end

    # End
    return flow, F
end
