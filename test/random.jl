using Graphs
using Base.Test

# Test the random graph generation
# We're just running the functions, no testing that the graphs
# actually have the characteristics that they are supposed to have.

n = 10
p = 0.2
let g = erdos_renyi_graph(n,p, is_directed=false)
    # A graph should have n vertices
    @test num_vertices(g) == n
    @test !is_directed(g)
end

p = 1
let g = erdos_renyi_graph(n,p, is_directed=false)
    # When p = 1, the graph should be complete.
    @test num_edges(g) == sum(1:n-1)
end

p = 1
let g = erdos_renyi_graph(n,p, is_directed=true)
    # A graph should have n vertices
    @test num_vertices(g) == n
    @test is_directed(g)
    # When p = 1, the graph should be complete.
    @test num_edges(g) == 2*sum(1:n-1)
end

# Watts-Strogatz small world graphs

# First check that the initial circle is created when beta=0
n = 100
k = 6
beta = 0
let g = watts_strogatz_graph(n, k, beta)
    @test num_edges(g) == n*(k/2)
    @test num_vertices(g) == n
    for i = 1:n
        on = out_neighbors(i,g)
        for j = 1:k/2
            @test (((i+j-1) % n) + 1 in on)
        end
    end
end

# Check that no edges are lost in rewiring:
beta = 0.1
let g = watts_strogatz_graph(n, k, beta)
    @test num_edges(g) == n*(k/2)
    @test num_vertices(g) == n
end
