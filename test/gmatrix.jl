# Graph to matrices

using Graphs
using Base.Test


# data

eds = [Edge(1,1,2), Edge(2,1,3), Edge(3,2,4), Edge(4,3,4)]

a0 = fill(false, 4, 4)
a0[1, 2] = a0[1, 3] = a0[2, 4] = a0[3, 4] = true

a0u = copy(a0)
a0u[2, 1] = a0u[3, 1] = a0u[4, 2] = a0u[4, 3] = true

a0_s = sparse(a0)
a0u_s = sparse(a0u)

# graphs

gd_elst = simple_edgelist(4, eds)
gu_elst = simple_edgelist(4, eds; is_directed=false)

gd_ilst = simple_inclist(4)
gu_ilst = simple_inclist(4, is_directed=false)

for e in eds
    add_edge!(gd_ilst, e.source, e.target)
    add_edge!(gu_ilst, e.source, e.target)
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

eweights = [1., 2., 3., 4.]
wm0  = [0. 1. 2. 0.; 0. 0. 0. 3.; 0. 0. 0. 4.; 0. 0. 0. 0.]
wm0u = [0. 1. 2. 0.; 1. 0. 0. 3.; 2. 0. 0. 4.; 0. 3. 4. 0.]
wm0_s = sparse(wm0)
wm0u_s = sparse(wm0u)

@test weight_matrix(gd_elst, eweights) == wm0
@test weight_matrix(gu_elst, eweights) == wm0u

@test weight_matrix_sparse(gd_elst, eweights) == wm0_s
@test weight_matrix_sparse(gu_elst, eweights) == wm0u_s

@test weight_matrix(gd_ilst, eweights) == wm0
@test weight_matrix(gu_ilst, eweights) == wm0u

@test weight_matrix_sparse(gd_ilst, eweights) == wm0_s
@test weight_matrix_sparse(gu_ilst, eweights) == wm0u_s

# distance matrix

dm0  = [0. 1. 2. Inf; Inf 0. Inf 3.; Inf Inf 0. 4.; Inf Inf Inf 0.]
dm0u = [0. 1. 2. Inf; 1. 0. Inf 3.; 2. Inf 0. 4.; Inf 3. 4. 0.]

@test distance_matrix(gd_elst, eweights) == dm0
@test distance_matrix(gu_elst, eweights) == dm0u

@test distance_matrix(gd_ilst, eweights) == dm0
@test distance_matrix(gu_ilst, eweights) == dm0u


# Laplacian matrix

L0 = [2. -1. -1. 0.; -1. 2. 0. -1.; -1. 0. 2. -1.; 0. -1. -1. 2.]
L0_s = sparse(L0)

@test laplacian_matrix(gu_elst) == L0
@test laplacian_matrix(gu_ilst) == L0

@test laplacian_matrix_sparse(gu_elst) == L0_s
@test laplacian_matrix_sparse(gu_ilst) == L0_s


Lw = [3. -1. -2. 0.; -1. 4. 0. -3.; -2. 0. 6. -4.; 0. -3. -4. 7.]
Lw_s = sparse(Lw)

@test laplacian_matrix(gu_elst, eweights) == Lw
@test laplacian_matrix(gu_ilst, eweights) == Lw

@test laplacian_matrix_sparse(gu_elst, eweights) == Lw_s
@test laplacian_matrix_sparse(gu_ilst, eweights) == Lw_s
