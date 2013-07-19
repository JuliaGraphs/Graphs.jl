# Graph to matrices

using Graphs
using Base.Test

# adjacency matrix

edges = [Edge(1, 1, 2), Edge(2, 1, 3), Edge(3, 2, 4), Edge(4, 3, 4)]

a0 = falses(4, 4)
a0[1, 2] = a0[1, 3] = a0[2, 4] = a0[3, 4] = true

a0u = copy(a0)
a0u[2, 1] = a0u[3, 1] = a0u[4, 2] = a0u[4, 3] = true

@test adjacency_matrix(true, 4, edges) == a0
@test adjacency_matrix(false, 4, edges) == a0u

a0_s = sparse(convert(Array{Float64,2},a0))
a0u_s = sparse(convert(Array{Float64,2},a0u))
@test adjacency_matrix_sparse(true, 4, edges) == a0_s
@test adjacency_matrix_sparse(false, 4, edges) == a0u_s

gd = simple_inclist(4)
gu = simple_inclist(4, is_directed=false)

for e in edges
    add_edge!(gd, e.source, e.target)
    add_edge!(gu, e.source, e.target)
end

@test Graphs.adjacency_matrix_by_adjlist(gd) == a0
@test Graphs.adjacency_matrix_by_inclist(gd) == a0
@test adjacency_matrix(gd) == a0

@test Graphs.adjacency_matrix_by_adjlist_sparse(gd) == a0_s
@test Graphs.adjacency_matrix_by_inclist_sparse(gd) == a0_s
@test adjacency_matrix_sparse(gd) == a0

@test Graphs.adjacency_matrix_by_adjlist(gu) == a0u
@test Graphs.adjacency_matrix_by_inclist(gu) == a0u
@test adjacency_matrix(gu) == a0u

@test Graphs.adjacency_matrix_by_adjlist_sparse(gu) == a0u_s
@test Graphs.adjacency_matrix_by_inclist_sparse(gu) == a0u_s
@test adjacency_matrix_sparse(gu) == a0u_s

# weight matrix

eweights = [1., 2., 3., 4.]

wm0  = [0. 1. 2. 0.; 0. 0. 0. 3.; 0. 0. 0. 4.; 0. 0. 0. 0.]
wm0u = [0. 1. 2. 0.; 1. 0. 0. 3.; 2. 0. 0. 4.; 0. 3. 4. 0.]

@test weight_matrix(true, 4, edges, eweights) == wm0
@test weight_matrix(false, 4, edges, eweights) == wm0u

@test weight_matrix(gd, eweights) == wm0
@test weight_matrix(gu, eweights) == wm0u

wm0_s = sparse(wm0)
wm0u_s = sparse(wm0u)

@test weight_matrix_sparse(true, 4, edges, eweights) == wm0_s
@test weight_matrix_sparse(false, 4, edges, eweights) == wm0u_s

@test weight_matrix_sparse(gd, eweights) == wm0_s
@test weight_matrix_sparse(gu, eweights) == wm0u_s

# Laplacian matrix

L0 = [2. -1. -1. 0.; -1. 2. 0. -1.; -1. 0. 2. -1.; 0. -1. -1. 2.]

@test laplacian_matrix(4, edges) == L0
@test Graphs.laplacian_matrix_by_adjlist(gu) == L0
@test Graphs.laplacian_matrix_by_inclist(gu) == L0
@test laplacian_matrix(gu) == L0

L0_s = sparse(L0)

@test laplacian_matrix_sparse(4, edges) == L0_s
@test Graphs.laplacian_matrix_by_adjlist_sparse(gu) == L0_s
@test Graphs.laplacian_matrix_by_inclist_sparse(gu) == L0_s
@test laplacian_matrix_sparse(gu) == L0_s

Lw = [3. -1. -2. 0.; -1. 4. 0. -3.; -2. 0. 6. -4.; 0. -3. -4. 7.]
@test laplacian_matrix(4, edges, eweights) == Lw
@test laplacian_matrix(gu, eweights) == Lw

Lw_s = sparse(Lw)
@test laplacian_matrix_sparse(4, edges, eweights) == Lw_s
@test laplacian_matrix_sparse(gu, eweights) == Lw_s
