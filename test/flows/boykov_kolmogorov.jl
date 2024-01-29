@testset "Boykov Kolmogorov" begin
    @testset "Lattice graph" begin
        # image size
        sz = (9, 9)

        # number of pixels
        npix = prod(sz)

        # lattice graph
        G = DiGraph(npix + 2)
        C = spzeros(npix + 2, npix + 2)

        # connect all pixels in the 9x9 image
        # with its immediate 4 neighbors
        for i in 1:(sz[1] - 1), j in 1:sz[2]
            u = LinearIndices(sz)[i, j]
            v = LinearIndices(sz)[i + 1, j]
            add_edge!(G, u, v)
            add_edge!(G, v, u)
        end
        for i in 1:sz[1], j in 1:(sz[2] - 1)
            u = LinearIndices(sz)[i, j]
            v = LinearIndices(sz)[i, j + 1]
            add_edge!(G, u, v)
            add_edge!(G, v, u)
        end

        # create capacity for flow in the 4x4
        # subimage located at the top left
        for i in 1:3, j in 1:4
            u = LinearIndices(sz)[i, j]
            v = LinearIndices(sz)[i + 1, j]
            C[u, v] = C[v, u] = 1
        end
        for i in 1:4, j in 1:3
            u = LinearIndices(sz)[i, j]
            v = LinearIndices(sz)[i, j + 1]
            C[u, v] = C[v, u] = 1
        end

        # create capacity for flow in the 4x4
        # subimage located at the bottom right
        for i in 6:8, j in 6:9
            u = LinearIndices(sz)[i, j]
            v = LinearIndices(sz)[i + 1, j]
            C[u, v] = C[v, u] = 1
        end
        for i in 6:9, j in 6:8
            u = LinearIndices(sz)[i, j]
            v = LinearIndices(sz)[i, j + 1]
            C[u, v] = C[v, u] = 1
        end

        # create source node and connect it to the
        # leftmost column of the image
        # create target node and connect it to the
        # rightmost column of the image
        s = npix + 1
        t = npix + 2
        for i in 1:sz[1]
            u = LinearIndices(sz)[i, 1]
            add_edge!(G, s, u)
            C[s, u] = C[u, s] = Inf
        end
        for i in 1:sz[1]
            u = LinearIndices(sz)[i, sz[2]]
            add_edge!(G, u, t)
            C[u, t] = C[t, u] = Inf
        end

        for G_gen in [G]  # TODO: generic graphs
            # now we are ready to start the flow
            flow, _, labels = maximum_flow(
                G_gen, s, t, C; algorithm=BoykovKolmogorovAlgorithm()
            )

            # because the two subimages are not connected
            # we must have zero flow from source to target
            @test flow == 0

            # the final cut represents the two disconnected
            # subimages filled with water of different color
            COLOR = reshape(labels[1:(end - 2)], sz)
            @test COLOR == eltype(COLOR)[
                1 1 1 1 0 0 0 0 2
                1 1 1 1 0 0 0 0 2
                1 1 1 1 0 0 0 0 2
                1 1 1 1 0 0 0 0 2
                1 0 0 0 0 0 0 0 2
                1 0 0 0 0 2 2 2 2
                1 0 0 0 0 2 2 2 2
                1 0 0 0 0 2 2 2 2
                1 0 0 0 0 2 2 2 2
            ]

            # now let's create a bridge connecting the two
            # subimages to allow flow from source to target
            for (I1, I2) in
                [[(4, 4), (5, 4)], [(5, 4), (5, 5)], [(5, 5), (5, 6)], [(5, 6), (6, 6)]]
                u = LinearIndices(sz)[I1...]
                v = LinearIndices(sz)[I2...]
                C[u, v] = C[v, u] = 1
            end

            flow, _, labels = maximum_flow(
                G_gen, s, t, C; algorithm=BoykovKolmogorovAlgorithm()
            )

            # because there is only one bridge,
            # the maximum flow allowed is one unit
            @test flow == 1

            # the final cut is unchanged compared to the previous one
            COLOR = reshape(labels[1:(end - 2)], sz)
            @test COLOR == eltype(COLOR)[
                1 1 1 1 0 0 0 0 2
                1 1 1 1 0 0 0 0 2
                1 1 1 1 0 0 0 0 2
                1 1 1 1 0 0 0 0 2
                1 0 0 0 0 0 0 0 2
                1 0 0 0 0 2 2 2 2
                1 0 0 0 0 2 2 2 2
                1 0 0 0 0 2 2 2 2
                1 0 0 0 0 2 2 2 2
            ]

            # finally let's create a second bridge to increase
            # the maximum flow from one to two units
            for (I1, I2) in
                [[(4, 4), (4, 5)], [(4, 5), (5, 5)], [(5, 5), (6, 5)], [(6, 5), (6, 6)]]
                u = LinearIndices(sz)[I1...]
                v = LinearIndices(sz)[I2...]
                C[u, v] = C[v, u] = 1
            end

            flow, _, labels = maximum_flow(
                G_gen, s, t, C; algorithm=BoykovKolmogorovAlgorithm()
            )

            # the maximum flow is now doubled
            @test flow == 2

            # the final cut is slightly different
            # near the corners of the two subimages
            COLOR = reshape(labels[1:(end - 2)], sz)
            @test COLOR == eltype(COLOR)[
                1 1 1 1 0 0 0 0 2
                1 1 1 1 0 0 0 0 2
                1 1 1 1 0 0 0 0 2
                1 1 1 0 0 0 0 0 2
                1 0 0 0 0 0 0 0 2
                1 0 0 0 0 0 2 2 2
                1 0 0 0 0 2 2 2 2
                1 0 0 0 0 2 2 2 2
                1 0 0 0 0 2 2 2 2
            ]
        end
    end

    @testset "Find path" begin
        # construct graph
        gg = Graphs.DiGraph(3)
        Graphs.add_edge!(gg, 1, 2)
        Graphs.add_edge!(gg, 2, 3)

        # source and sink terminals
        source, target = 1, 3

        for g in test_generic_graphs(gg)
            # default capacity
            capacity_matrix = Graphs.DefaultCapacity(g)
            residual_graph = @inferred(Graphs.residual(g))
            T = eltype(g)
            flow_matrix = zeros(T, 3, 3)
            TREE = zeros(T, 3)
            TREE[source] = T(1)
            TREE[target] = T(2)
            PARENT = zeros(T, 3)
            A = [T(source), T(target)]
            path = Graphs.boykov_kolmogorov_find_path!(
                residual_graph,
                source,
                target,
                flow_matrix,
                capacity_matrix,
                PARENT,
                TREE,
                A,
            )

            @test path == [1, 2, 3]
        end
    end
end
