using Graphs
using Base.Test

g = simple_complete_graph(5)
@test num_vertices(g) == 5 && num_edges(g) == 20
g = simple_complete_graph(5, is_directed=false)
@test num_vertices(g) == 5 && num_edges(g) == 10

g = simple_star_graph(5)
@test num_vertices(g) == 5 && num_edges(g) == 4
g = simple_star_graph(5, is_directed=false)
@test num_vertices(g) == 5 && num_edges(g) == 4
g = simple_star_graph(1)
@test num_vertices(g) == 1 && num_edges(g) == 0

g = simple_path_graph(5)
@test num_vertices(g) == 5 && num_edges(g) == 4
g = simple_path_graph(5; is_directed=false)
@test num_vertices(g) == 5 && num_edges(g) == 4

g = simple_wheel_graph(5)
@test num_vertices(g) == 5 && num_edges(g) == 8
g = simple_wheel_graph(5, is_directed=false)
@test num_vertices(g) == 5 && num_edges(g) == 8

g = simple_diamond_graph()
@test num_vertices(g) == 4 && num_edges(g) == 5

g = simple_bull_graph()
@test num_vertices(g) == 5 && num_edges(g) == 5

g = simple_chvatal_graph()
@test num_vertices(g) == 12 && num_edges(g) == 24

g = simple_cubical_graph()
@test num_vertices(g) == 8 && num_edges(g) == 12


g = simple_desargues_graph()
@test num_vertices(g) == 20 && num_edges(g) == 30

g = simple_dodecahedral_graph()
@test num_vertices(g) == 20 && num_edges(g) == 30

g = simple_frucht_graph()
@test num_vertices(g) == 20 && num_edges(g) == 18

g = simple_heawood_graph()
@test num_vertices(g) == 14 && num_edges(g) == 21

g = simple_house_graph()
@test num_vertices(g) == 5 && num_edges(g) == 6

g = simple_house_x_graph()
@test num_vertices(g) == 5 && num_edges(g) == 8

g = simple_icosahedral_graph()
@test num_vertices(g) == 12 && num_edges(g) == 30

g = simple_krackhardt_kite_graph()
@test num_vertices(g) == 10 && num_edges(g) == 18

g = moebius_kantor_graph()
@test num_vertices(g) == 16 && num_edges(g) == 24

g = simple_octahedral_graph()
@test num_vertices(g) == 6 && num_edges(g) == 12

g = simple_pappus_graph()
@test num_vertices(g) == 18 && num_edges(g) == 27

g = simple_petersen_graph()
@test num_vertices(g) == 10 && num_edges(g) == 15

g = simple_sedgewick_maze_graph()
@test num_vertices(g) == 8 && num_edges(g) == 10

g = simple_tetrahedral_graph()
@test num_vertices(g) == 4 && num_edges(g) == 6

g = simple_truncated_cube_graph()
@test num_vertices(g) == 24 && num_edges(g) == 36

g = simple_truncated_tetrahedron_graph()
@test num_vertices(g) == 12 && num_edges(g) == 18

g = simple_tutte_graph()
@test num_vertices(g) == 46 && num_edges(g) == 69
