# EMRF (Extended Multiroute Flow) algorithms
"""
    ext_multiroute_flow(flow_graph, source, target, capacity_matrix, flow_algorithm, routes=0)

Compute the maximum multiroute flow (for any number of `route`s)
between `source` and `target` in `flow_graph` via flow algorithm `flow_algorithm`.

If a number of routes is given, return the value of the multiroute flow as
well as the final flow matrix, along with a multiroute cut if the
Boykov-Kolmogorov max-flow algorithm is used as a subroutine.
Otherwise, return the vector of breaking points of the parametric
multiroute flow function.

### References
- [Extended Multiroute Flow algorithm](http://dx.doi.org/10.1016/j.disopt.2016.05.002)
"""
function ext_multiroute_flow(
    flow_graph::Graphs.AbstractGraph,          # the input graph
    source::Integer,                       # the source vertex
    target::Integer,                       # the target vertex
    capacity_matrix::AbstractMatrix,       # edge flow capacities
    flow_algorithm::AbstractFlowAlgorithm, # keyword argument for algorithm
    routes::Real=0,
)
    breakingpoints = ext_multiroute_flow_breakingPoints(
        flow_graph, source, target, capacity_matrix
    )
    if routes > 0
        x, f = ext_multiroute_flow_intersection(breakingpoints, routes)
        return maximum_flow(
            flow_graph,
            source,
            target,
            capacity_matrix;
            algorithm=flow_algorithm,
            restriction=x,
        )
    end
    return breakingpoints
end

@doc raw"""
    ext_multiroute_flow_auxiliaryPoints(flow_graph, source, target, capacity_matrix)

Output a set of (point, slope) that compose the restricted max-flow function
of `flow_graph` from `source to `target` using capacities in `capacity_matrix`.

### Performance
One point by possible slope is enough (hence ``\\mathcal{O}(λ×maximum_flow)`` complexity).
"""
function ext_multiroute_flow_auxiliaryPoints end
@traitfn function ext_multiroute_flow_auxiliaryPoints(
    flow_graph::::IsDirected,                   # the input graph
    source::Integer,                           # the source vertex
    target::Integer,                           # the target vertex
    capacity_matrix::AbstractMatrix,   # edge flow capacities
)
    # Problem descriptors
    λ = maximum_flow(flow_graph, source, target)[1] # Connectivity
    n = Graphs.nv(flow_graph) # number of vertices
    r1, r2 = ext_multiroute_flow_minmaxCapacity(capacity_matrix) # restriction left (1) and right (2)
    auxpoints = fill((0.0, 0.0), λ + 1)

    # Initialisation of left side (1)
    f1, F1, cut1 = maximum_flow(
        flow_graph,
        source,
        target,
        capacity_matrix;
        algorithm=BoykovKolmogorovAlgorithm(),
        restriction=r1,
    )
    s1 = ext_multiroute_flow_slope(flow_graph, capacity_matrix, cut1, r1) # left slope
    auxpoints[λ + 1 - s1] = (r1, f1) # Add left initial auxiliary point

    # Initialisation of right side (2)
    f2, F2, cut2 = maximum_flow(
        flow_graph,
        source,
        target,
        capacity_matrix;
        algorithm=BoykovKolmogorovAlgorithm(),
        restriction=r2,
    )
    s2 = ext_multiroute_flow_slope(flow_graph, capacity_matrix, cut2, r2) # right slope
    auxpoints[λ + 1 - s2] = (r2, f2) # Add right initial auxiliary point

    # Loop if the slopes are distinct by at least 2
    if s1 > s2 + 1
        queue = [((f1, s1, r1), (f2, s2, r2))]

        while !isempty(queue)
            # Computes an intersection (middle) with a new associated slope
            (f1, s1, r1), (f2, s2, r2) = pop!(queue)
            r, expectedflow = ext_multiroute_flow_intersection(r1, f1, s1, r2, f2, s2)
            f, F, cut = maximum_flow(
                flow_graph,
                source,
                target,
                capacity_matrix;
                algorithm=BoykovKolmogorovAlgorithm(),
                restriction=r,
            )
            s = ext_multiroute_flow_slope(flow_graph, capacity_matrix, max.(cut, 1), r) # current slope
            auxpoints[λ + 1 - s] = (r, f)
            # If the flow at the intersection (middle) is as expected
            if expectedflow ≉ f # approximatively not equal (enforced by floating precision)
                # if the slope difference between (middle) and left is at least 2
                # push (left),(middle)
                if s1 > s + 1 && !ext_multiroute_flow_approximately_equal((r2, f2), (r, f))
                    q = (f1, s1, r1), (f, s, r)
                    push!(queue, q)
                end
                # if the slope difference between (middle) and right is at least 2
                # push (middle),(right)
                if s > s2 + 1 && !ext_multiroute_flow_approximately_equal((r1, f1), (r, f))
                    q = (f, s, r), (f2, s2, r2)
                    push!(queue, q)
                end
            end
        end
    end
    return auxpoints
end

"""
    ext_multiroute_flow_breakingPoints(flow_graph::::IsDirected, source, target, capacity_matrix)

Calculates the breaking of the restricted max-flow from a set of auxiliary points
for `flow_graph` from `source to `target` using capacities in `capacity_matrix`.
"""
function ext_multiroute_flow_breakingPoints end
@traitfn function ext_multiroute_flow_breakingPoints(
    flow_graph::::IsDirected,                   # the input graph
    source::Integer,                           # the source vertex
    target::Integer,                           # the target vertex
    capacity_matrix::AbstractMatrix{T},   # edge flow capacities
) where {T}
    auxpoints = ext_multiroute_flow_auxiliaryPoints(
        flow_graph, source, target, capacity_matrix
    )
    λ = length(auxpoints) - 1
    left_index = 1
    breakingpoints = Vector{Tuple{T,T,Int}}()

    for (id, point) in enumerate(auxpoints)
        if id == 1
            push!(breakingpoints, (0.0, 0.0, λ))
        else
            pleft = breakingpoints[left_index]
            if point[1] != 0
                x, y = ext_multiroute_flow_intersection(
                    pleft[1], pleft[2], pleft[3], point[1], point[2], λ + 1 - id
                )
                push!(breakingpoints, (x, y, λ + 1 - id))
                left_index += 1
            end
        end
    end
    return breakingpoints
end

# Function to get the nonzero min and max function of a Matrix
# note: this is more efficient than maximum() / minimum() / extrema()
#       since we have to ignore zero values.
"""
    ext_multiroute_flow_minmaxCapacity(capacity_matrix)

Return the nonzero min and max function of `capacity_matrix`.

Note: this is more efficient than maximum() / minimum() / extrema()
since we have to ignore zero values.
"""
function ext_multiroute_flow_minmaxCapacity(
    capacity_matrix::AbstractMatrix{T},    # edge flow capacities
) where {T}
    cmin, cmax = typemax(T), typemin(T)
    for c in capacity_matrix
        if c > zero(T)
            cmin = min(cmin, c)
        end
        cmax = max(cmax, c)
    end
    return cmin, cmax
end

"""
    ext_multiroute_flow_slope(flow_graph, capacity_matrix, cut, restriction)

Return the slope of `flow_graph` using capacities in `capacity_matrix` and
a cut vector `cut`. The slope is initialized at 0 and is incremented for
each edge whose capacity does not exceed `restriction`.
"""
function ext_multiroute_flow_slope end
# Function to get the slope of the restricted flow
@traitfn function ext_multiroute_flow_slope(
    flow_graph::::IsDirected,      # the input graph
    capacity_matrix::AbstractMatrix,  # edge flow capacities
    cut::Vector,                      # cut information for vertices
    restriction::Number,               # value of the restriction
)
    slope = 0
    for e in Graphs.edges(flow_graph)
        ## Chain comparison to wether an edge cross the cut from the source side of
        # the cut to the target side of the cut. Then the edge is selected iff the
        # capacity of the edge is larger then the restriction argument.
        # cut[dst(e)] == 2 > cut[src(e)] is equivalent to
        # cut[dst(e)] == 2 && 2 > cut[src(e)]
        # Description of chain comparisons can be found at https://goo.gl/IJpCqe
        if cut[Graphs.dst(e)] == 2 > cut[Graphs.src(e)] &&
            capacity_matrix[Graphs.src(e), Graphs.dst(e)] > restriction
            slope += 1
        end
    end
    return slope
end

"""
    ext_multiroute_flow_intersection(x1, y1, a1, x2, y2, a2)

Return the intersection of two lines defined by `x` and `y` with slopes `a`.
2) A set of segments and a linear function of slope k passing by the origin.
Requires argument:
1) - x1, y1, a1, x2, y2, a2::T<:AbstractFloat # Coordinates/slopes
2) - points::Vector{Tuple{T, T, Int}}         # vector of points with T<:AbstractFloat
- k::R<:Real                             # number of routes (slope of the line)
"""
function ext_multiroute_flow_intersection(
    x1::T,          # x coordinate of point 1
    y1::T,          # y coordinate of point 1
    a1::Integer,        # slope passing by point 1
    x2::T,          # x coordinate of point 2
    y2::T,          # y coordinate of point 2
    a2::R,           # slope passing by point 2
) where {T<:AbstractFloat} where {R<:Real}
    (a1 == a2) && return -1.0, -1.0 # result will be ignored in other intersection method
    b1 = y1 - a1 * x1
    b2 = y2 - a2 * x2
    x = (b2 - b1) / (a1 - a2)
    y = a1 * x + b1
    return x, y
end

"""
    ext_multiroute_flow_intersection(points, k)

Return the intersection of a set of line segments and a line of slope `k`
passing by the origin. Segments are defined as a triple (x, y, slope).
"""
function ext_multiroute_flow_intersection(
    points::Vector{Tuple{T,T,I}},  # vector of breaking points
    k::R,                               # number of routes (slope of the line)
) where {T<:AbstractFloat} where {I<:Integer} where {R<:Real}
    λ = points[1][1] # Connectivity

    # Loop over the segments (pair of breaking points)
    for (id, p) in enumerate(points[1:(end - 1)])
        if id == 1
            k ≈ λ && return points[2]
        else
            x, y = ext_multiroute_flow_intersection(p[1], p[2], p[3], 0.0, 0.0, k)
            (p[1] ≤ x ≤ points[id + 1][1]) && return x, y
        end
    end
    p = points[end]
    return ext_multiroute_flow_intersection(p[1], p[2], p[3], 0.0, 0.0, k)
end

"""
    ext_multiroute_flow_approximately_equal(a, b)

Return true if each element in the tuple is approximately equal to its counterpart.

### Implementation Notes:
This is a separate function because we don't want to hijack isapprox for tuples.
"""
ext_multiroute_flow_approximately_equal(
    a::Tuple{T,T}, b::Tuple{T,T}
) where {T<:AbstractFloat} = a[1] ≈ b[1] && a[2] ≈ b[2]
