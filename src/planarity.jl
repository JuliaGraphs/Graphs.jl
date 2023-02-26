# Planarity algorithm for Julia graphs. 
# Algorithm from https://www.uni-konstanz.de/algo/publications/b-lrpt-sub.pdf
# The implementation is heavily influenced by the recursive implementation in Networkx (https://networkx.org/documentation/stable/_modules/networkx/algorithms/planarity.html)

import DataStructures: DefaultDict, Stack
import Base: isempty

"""
    is_planar(g)

Determines whether or not the graph `g` is [planar](https://en.wikipedia.org/wiki/Planar_graph).

Uses the [left-right planarity test](https://en.wikipedia.org/wiki/Left-right_planarity_test).

### References 
- [Brandes 2009](https://www.uni-konstanz.de/algo/publications/b-lrpt-sub.pdf)
"""
function is_planar(g)
    lrp = LRPlanarity(g)
    return lr_planarity!(lrp)
end

#Simple structs to be used in algorithm. Keep private for now. 
function empty_edge(T)
    return Edge{T}(0, 0)
end

function isempty(e::Edge{T}) where {T}
    return src(e) == zero(T) && dst(e) == zero(T)
end

mutable struct Interval{T}
    high::Edge{T}
    low::Edge{T}
end

function empty_interval(T)
    return Interval(empty_edge(T), empty_edge(T))
end

function isempty(interval::Interval)
    return isempty(interval.high) && isempty(interval.low)
end

function conflicting(interval::Interval{T}, b, lrp_state) where {T}
    return !isempty(interval) && (lrp_state.lowpt[interval.high] > lrp_state.lowpt[b])
end

mutable struct ConflictPair{T}
    L::Interval{T}
    R::Interval{T}
end

function empty_pair(T)
    return ConflictPair(empty_interval(T), empty_interval(T))
end

function swap!(self::ConflictPair)
    #Swap left and right intervals
    temp = self.L
    self.L = self.R
    return self.R = temp
end

function root_pair(T)
    #returns the "root pair" of type T 
    e = Edge{T}(0, 0)
    return ConflictPair(Interval(e, e), Interval(e, e))
end

function isempty(p::ConflictPair)
    return isempty(p.L) && isempty(p.R)
end

# ATM (Julia 1.8.4, DataStructures v0.18.13), DefaultDict crashes
# for large order matrices when we attempt to trim the back edges. 
#To fix this we create a manual version of the DefaultDict that seems to be more stable

struct ManualDict{A,B}
    d::Dict{A,B}
    default::B
end

function ManualDict(A, B, default)
    return ManualDict(Dict{A,B}(), default)
end

import Base: getindex

function getindex(md::ManualDict, x)
    d = md.d
    if haskey(d, x)
        d[x]
    else
        d[x] = md.default
        md.default
    end
end

function setindex!(md::ManualDict, X, key)
    return setindex!(md.d, X, key)
end

mutable struct LRPlanarity{T<:Integer}
    #State class for the planarity test 
    #We index by Edge structs throughout as it is easier than switching between
    #Edges and tuples
    #G::SimpleGraph{T} #Copy of the input graph
    V::Int64
    E::Int64
    roots::Vector{T} #Vector of roots for disconnected graphs. Normally size(roots, 1) == 1
    height::DefaultDict{T,Int64} #DefaultDict of heights <: Int, indexed by node. default is -1
    lowpt::Dict{Edge{T},Int64} #Dict of low points, indexed by Edge
    lowpt2::Dict{Edge{T},Int64} #Dict of low points (copy), indexed by Edge 
    nesting_depth::Dict{Edge{T},Int64} #Dict of nesting depths, indexed by Edge
    parent_edge::DefaultDict{T,Edge{T}} #Dict of parent edges, indexed by node
    DG::SimpleDiGraph{T} #Directed graph for the orientation phase
    adjs::Dict{T,Vector{T}} #Dict of neighbors of nodes, indexed by node
    ordered_adjs::Dict{T,Vector{T}} #Dict of neighbors of nodes sorted by nesting depth, indexed by node
    ref::DefaultDict{Edge{T},Edge{T}} #ManualDict of Edges, indexed by Edge
    side::DefaultDict{Edge{T},Int8} #DefaultDict of +/- 1, indexed by edge
    S::Stack{ConflictPair{T}} #Stack of tuples of Edges
    stack_bottom::Dict{Edge{T},ConflictPair{T}} #Dict of Tuples of Edges, indexed by Edge
    lowpt_edge::Dict{Edge{T},Edge{T}} #Dict of Edges, indexed by Edge 
    #left_ref::Dict{T,Edge{T}} #Dict of Edges, indexed by node
    #right_ref::Dict{T,Edge{T}} #Dict of Edges, indexed by node
    # skip embedding for now 
end

#outer constructor for LRPlanarity
function LRPlanarity(g::AG) where {AG<:AbstractGraph}
    V = Int64(nv(g)) #needs promoting
    E = Int64(ne(g)) #JIC
    #record nodetype of g
    T = eltype(g)
    N = nv(g)

    roots = T[]

    # distance from tree root
    height = DefaultDict{T,Int64}(-1)

    lowpt = Dict{Edge{T},Int64}()  # height of lowest return point of an edge
    lowpt2 = Dict{Edge{T},Int64}()  # height of second lowest return point
    nesting_depth = Dict{Edge{T},Int64}()  # for nesting order

    # None == Edge(0, 0)  for our type-stable algo

    parent_edge = DefaultDict{T,Edge{T}}(empty_edge(T))

    # oriented DFS graph
    DG = SimpleDiGraph{T}(N)

    adjs = Dict{T,Vector{T}}()
    # make adjacency lists for dfs
    for v in 1:nv(g) #for all vertices in G,
        adjs[v] = all_neighbors(g, v) ##neighbourhood of v
    end

    ordered_adjs = Dict{T,Vector{T}}()

    ref = DefaultDict{Edge{T}, Edge{T}}(empty_edge(T))
    side = DefaultDict{Edge{T},Int8}(one(Int8))

    # stack of conflict pairs
    S = Stack{ConflictPair{T}}()
    stack_bottom = Dict{Edge{T},ConflictPair{T}}()
    lowpt_edge = Dict{Edge{T},Edge{T}}()
    #left_ref = Dict{T,Edge{T}}()
    #right_ref = Dict{T,Edge{T}}()

    #self.embedding = PlanarEmbedding()
    return LRPlanarity(
        #g,
        V,
        E,
        roots,
        height,
        lowpt,
        lowpt2,
        nesting_depth,
        parent_edge,
        DG,
        adjs,
        ordered_adjs,
        ref,
        side,
        S,
        stack_bottom,
        lowpt_edge,
        #left_ref,
        #right_ref,
    )
end

function lrp_type(lrp::LRPlanarity{T}) where T
    T
end

function reset_lrp_state!(lrp_state, g)
    T = lrp_type(lrp_state)
    #resets the LRP state 


    #reset roots 
    empty!(lrp_state.roots)

    #reset lowpts 
    #empty!(lrp_state.lowpt)
    #empty!(lrp_state.lowpt2)
    #reset nesting depth
    empty!(lrp_state.nesting_depth)

    #reset heights
    for k ∈ keys(lrp_state.height)
        lrp_state.height[k] = -1
    end

    for k in keys(lrp_state.parent_edge)
        lrp_state.parent_edge[k] = empty_edge(T)
    end

    for e in edges(lrp_state.DG)
        rem_edge!(lrp_state.DG, e)
    end

    for v in 1:nv(g) #for all vertices in G,
        lrp_state.adjs[v] = all_neighbors(g, v) ##neighbourhood of v
    end

    for k ∈ keys(lrp_state.ref)
        lrp_state.ref[k] = empty_edge(T)
    end

    for k ∈ keys(lrp_state.side)
        lrp_state.side[k] = one(Int8)
    end

    empty!(lrp_state.S)
end


function lowest(self::ConflictPair, planarity_state::LRPlanarity)
    #Returns the lowest lowpoint of a conflict pair
    if isempty(self.L)
        return planarity_state.lowpt[self.R.low]
    end

    if isempty(self.R)
        return planarity_state.lowpt[self.L.low]
    end

    return min(planarity_state.lowpt[self.L.low], planarity_state.lowpt[self.R.low])
end

function lr_planarity!(self::LRPlanarity{T}) where {T}
    V = self.V
    E = self.E

    if V > 2 && (E > (3V - 6))
        # graph is not planar
        return false
    end

    # orientation of the graph by depth first search traversal
    for v in 1:V
        if self.height[v] == -one(T) #using -1 rather than nothing for type stability. 
            self.height[v] = zero(T)
            push!(self.roots, v)
            dfs_orientation!(self, v)
        end
    end

    #Testing stage
    #First, sort the ordered_adjs by nesting depth
    for v in 1:V #for all vertices in G,
        #get neighboring nodes
        neighboring_nodes = T[]
        neighboring_nesting_depths = Int64[]
        for (k, value) in self.nesting_depth
            if k.src == v
                push!(neighboring_nodes, k.dst)
                push!(neighboring_nesting_depths, value)
            end
        end
        neighboring_nodes .= neighboring_nodes[sortperm(neighboring_nesting_depths)]
        self.ordered_adjs[v] = neighboring_nodes
    end
    for s in self.roots
        if !dfs_testing!(self, s)
            return false
        end
    end

    #if the algorithm finishes, the graph is planar. Return true
    return true
end

function dfs_orientation!(self::LRPlanarity, v)
    # get the parent edge of v. 
    # if v is a root, the parent_edge dict 
    # will return Edge(0, 0)
    e = self.parent_edge[v] #get the parent edge of v. 
    #orient all edges in graph recursively 
    for w in self.adjs[v]
        # see if vw = Edge(v, w) has already been oriented 
        vw = Edge(v, w)
        wv = Edge(w, v) #Need to consider approach from both direction
        if vw in edges(self.DG) || wv in edges(self.DG)
            continue
        end

        #otherwise, appended to DG
        add_edge!(self.DG, vw)

        #record lowpoints
        self.lowpt[vw] = self.height[v]
        self.lowpt2[vw] = self.height[v]
        #if height == -1, i.e. we are at a tree edge, then 
        # record the height accordingly
        if self.height[w] == -1 ##tree edge
            self.parent_edge[w] = vw
            self.height[w] = self.height[v] + 1
            dfs_orientation!(self, w)
        else
            #at a back edge - no need to 
            #go through a DFS
            self.lowpt[vw] = self.height[w]
        end

        #determine nesting depth with formulae from Brandes
        #note that this will only be carried out 
        #once per edge 
        # if the edge is chordal, use the alternative formula
        self.nesting_depth[vw] = 2 * self.lowpt[vw]
        if self.lowpt2[vw] < self.height[v]
            #chordal 
            self.nesting_depth[vw] += 1
        end

        #update lowpoints of parent 
        if !isempty(e) #if e != root
            if self.lowpt[vw] < self.lowpt[e]
                self.lowpt2[e] = min(self.lowpt[e], self.lowpt2[vw])
                self.lowpt[e] = self.lowpt[vw]
            elseif self.lowpt[vw] > self.lowpt[e]
                self.lowpt2[e] = min(self.lowpt2[e], self.lowpt[vw])
            else
                self.lowpt2[e] = min(self.lowpt2[e], self.lowpt2[vw])
            end
        end
    end
end

function dfs_testing!(self, v)
    T = typeof(v)
    e = self.parent_edge[v]
    for w in self.ordered_adjs[v] #already ordered 
        ei = Edge(v, w)
        if !isempty(self.S) #stack is not empty
            self.stack_bottom[ei] = first(self.S)
        else #stack is empty
            self.stack_bottom[ei] = root_pair(T)
        end

        if ei == self.parent_edge[ei.dst] #tree edge
            if !dfs_testing!(self, ei.dst) #half if testing fails
                return false
            end
        else #back edge
            self.lowpt_edge[ei] = ei
            push!(self.S, ConflictPair(empty_interval(T), Interval(ei, ei)))
        end

        #integrate new return edges 
        if self.lowpt[ei] < self.height[v] #ei has return edge 
            e1 = Edge(v, first(self.ordered_adjs[v]))
            if ei == e1
                self.lowpt_edge[e] = self.lowpt_edge[ei] #in Brandes this is e <- e1. Corrected in Python source?
            else
                #add contraints (algo 4)
                if !edge_constraints!(self, ei, e) #half if fails
                    return false
                end
            end
        end
    end

    #remove back edges returning to parent 
    if !isempty(e)#v is not root
        u = src(e)
        #trim edges ending at parent u, algo 5 
        trim_back_edges!(self, u)
        #side of e is side of highest returning edge 
        if self.lowpt[e] < self.height[u] #e has return edge
            hl = first(self.S).L.high
            hr = first(self.S).R.high
            if !isempty(hl) && (isempty(hr) || (self.lowpt[hl] > self.lowpt[hr]))
                self.ref[e] = hl
            else
                self.ref[e] = hr
            end
        end
    end
    return true
end

function edge_constraints!(self, ei, e)
    T = eltype(ei)
    P = empty_pair(T)
    #merge return edges of ei into P.R
    while first(self.S) != self.stack_bottom[ei]
        Q = pop!(self.S)
        if !isempty(Q.L)
            swap!(Q)
        end
        if !isempty(Q.L) #not planar
            return false
        else
            if self.lowpt[Q.R.low] > self.lowpt[e] #merge intervals
                if isempty(P.R) #topmost interval
                    P.R.high = Q.R.high
                else
                    self.ref[P.R.low] = Q.R.high
                end
                P.R.low = Q.R.low
            else #align
                self.ref[Q.R.low] = self.lowpt_edge[e]
            end
        end
    end

    #merge conflicting return edges of <e...> into P.LRPlanarity
    while conflicting(first(self.S).L, ei, self) || conflicting(first(self.S).R, ei, self)
        Q = pop!(self.S)
        if conflicting(Q.R, ei, self)
            swap!(Q)
        end
        if conflicting(Q.R, ei, self) #not planar
            return false
        else #merge interval below into P.R
            self.ref[P.R.low] = Q.R.high
            if !isempty(Q.R.low)
                P.R.low = Q.R.low
            end
        end
        if isempty(P.L) #topmost interval
            P.L.high = Q.L.high
        else
            self.ref[P.L.low] = Q.L.high
        end
        P.L.low = Q.L.low
    end
    if !isempty(P)
        push!(self.S, P)
    end
    return true
end

function trim_back_edges!(self, u)
    #trim back edges ending at u 
    #drop entire conflict pairs 
    while !isempty(self.S) && (lowest(first(self.S), self) == self.height[u])
        P = pop!(self.S)
        if !isempty(P.L.low)
            self.side[P.L.low] = -1
        end
    end

    if !isempty(self.S) #one more conflict pair to consider 
        P = pop!(self.S)
        #trim left interval 
        while !isempty(P.L.high) && P.L.high.dst == u
            P.L.high = self.ref[P.L.high]
        end

        if isempty(P.L.high) && !isempty(P.L.low) #just emptied
            self.ref[P.L.low] = P.R.low
            self.side[P.L.low] = -1
            T = typeof(u)
            P.L.low = empty_edge(T)
        end

        #trim right interval 
        while !isempty(P.R.high) && P.R.high.dst == u
            P.R.high = self.ref[P.R.high]
        end

        if isempty(P.R.high) && !isempty(P.R.low) #just emptied
            self.ref[P.R.low] = P.L.low
            self.side[P.R.low] = -1
            T = typeof(u)
            P.R.low = empty_edge(T)
        end
        push!(self.S, P)
    end
end
