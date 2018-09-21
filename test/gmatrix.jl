# Graph to matrices

using Graphs
using Test
using SparseArrays

# data

global eds = [Edge(1,1,2), Edge(2,1,3), Edge(3,2,4), Edge(4,3,4)]

global a0 = fill(false, 4, 4)
global a0[1, 2] = a0[1, 3] = a0[2, 4] = a0[3, 4] = true

global a0u = copy(a0)
global a0u[2, 1] = a0u[3, 1] = a0u[4, 2] = a0u[4, 3] = true

global a0_s = sparse(a0)
global a0u_s = sparse(a0u)

# graphs

global gd_elst = simple_edgelist(4, eds)
global gu_elst = simple_edgelist(4, eds; is_directed=false)

global gd_ilst = simple_inclist(4)
global gu_ilst = simple_inclist(4, is_directed=false)

let
for ed in eds
  add_edge!(gd_ilst, ed.source, ed.target)
  add_edge!(gu_ilst, ed.source, ed.target)
end
end


# adjacency matrix

@test adjacency_matrix(gd_elst) == a0
@test adjacency_matrix(gu_elst) == a0u

@test adjacency_matrix_sparse(gd_elst) == a0_s
@test adjacency_matrix_sparse(gu_elst) == a0u_s

@test adjacency_matrix(gd_ilst) == a0
@test adjacency_matrix(gu_ilst) == a0u

@test adjacency_matrix_sparse(gd_ilst) == a0_s
@test adjacency_matrix_sparse(gu_ilst) == a0u_s


# weight matrix

global eweights = [1., 2., 3., 4.]
global wm0  = [0. 1. 2. 0.; 0. 0. 0. 3.; 0. 0. 0. 4.; 0. 0. 0. 0.]
global wm0u = [0. 1. 2. 0.; 1. 0. 0. 3.; 2. 0. 0. 4.; 0. 3. 4. 0.]
global wm0_s = sparse(wm0)
global wm0u_s = sparse(wm0u)

@test weight_matrix(gd_elst, eweights) == wm0
@test weight_matrix(gu_elst, eweights) == wm0u

@test weight_matrix_sparse(gd_elst, eweights) == wm0_s
@test weight_matrix_sparse(gu_elst, eweights) == wm0u_s

@test weight_matrix(gd_ilst, eweights) == wm0
@test weight_matrix(gu_ilst, eweights) == wm0u

@test weight_matrix_sparse(gd_ilst, eweights) == wm0_s
@test weight_matrix_sparse(gu_ilst, eweights) == wm0u_s

# distance matrix

global dm0  = [0. 1. 2. Inf; Inf 0. Inf 3.; Inf Inf 0. 4.; Inf Inf Inf 0.]
global dm0u = [0. 1. 2. Inf; 1. 0. Inf 3.; 2. Inf 0. 4.; Inf 3. 4. 0.]

@test distance_matrix(gd_elst, eweights) == dm0
@test distance_matrix(gu_elst, eweights) == dm0u

@test distance_matrix(gd_ilst, eweights) == dm0
@test distance_matrix(gu_ilst, eweights) == dm0u


# Laplacian matrix

global L0 = [2. -1. -1. 0.; -1. 2. 0. -1.; -1. 0. 2. -1.; 0. -1. -1. 2.]
global L0_s = sparse(L0)

@test laplacian_matrix(gu_elst) == L0
@test laplacian_matrix(gu_ilst) == L0

@test laplacian_matrix_sparse(gu_elst) == L0_s
@test laplacian_matrix_sparse(gu_ilst) == L0_s


global Lw = [3. -1. -2. 0.; -1. 4. 0. -3.; -2. 0. 6. -4.; 0. -3. -4. 7.]
global Lw_s = sparse(Lw)

@test laplacian_matrix(gu_elst, eweights) == Lw
@test laplacian_matrix(gu_ilst, eweights) == Lw

@test laplacian_matrix_sparse(gu_elst, eweights) == Lw_s
@test laplacian_matrix_sparse(gu_ilst, eweights) == Lw_s
