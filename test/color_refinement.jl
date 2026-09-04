# Brute-force reference implementation for undirected graphs. It repeatedly groups
# vertices by their current color and the multiset of their neighbors' colors until
# the partition is stable.
function _naive_stable_coloring(g::AbstractGraph, alpha::AbstractVector{<:Integer})
    n = nv(g)
    colour = collect(alpha)
    while true
        sigs = [(colour[v], Tuple(sort([colour[w] for w in neighbors(g, v)]))) for v in 1:n]
        seen = Dict{Tuple,Int}()
        newcolour = Vector{Int}(undef, n)
        for v in 1:n
            newcolour[v] = get!(seen, sigs[v], length(seen) + 1)
        end
        newcolour == colour && return colour
        colour = newcolour
    end
end

function _same_partition(a::AbstractVector, b::AbstractVector)
    length(a) == length(b) || return false
    return all((a[u] == a[v]) == (b[u] == b[v]) for u in eachindex(a), v in eachindex(a))
end

@testset "Color refinement" begin
    @testset "Path graph refines to a palindrome" begin
        # Endpoints (degree 1) split from the interior (degree 2), and the interior
        # further splits by distance to the ends, giving 3 stable classes.
        g = path_graph(5)
        c = canonical_color_refinement(g, ones(Int, nv(g)), [1])
        @test c[1] == c[5]
        @test c[2] == c[4]
        @test length(unique(c)) == 3
    end

    @testset "Vertex-transitive graphs stay monochromatic" begin
        # No vertex can be told apart from any other, so refinement leaves one class.
        for g in (cycle_graph(6), complete_graph(5), cycle_graph(4))
            c = canonical_color_refinement(g, ones(Int, nv(g)), [1])
            @test length(unique(c)) == 1
        end
    end

    @testset "Star graph separates center from leaves" begin
        g = star_graph(5)
        c = canonical_color_refinement(g, ones(Int, nv(g)), [1])
        @test length(unique(c)) == 2
        @test count(==(c[1]), c) == 1 # the center is in a class of its own
    end

    @testset "Color numbers are canonical under vertex relabeling" begin
        # A color-preserving isomorphism must preserve the exact output color number,
        # not merely the sizes of the resulting color classes.
        g1 = path_graph(6)
        σ = [4, 1, 6, 2, 5, 3]
        g2 = SimpleGraph(nv(g1))
        for e in edges(g1)
            add_edge!(g2, σ[src(e)], σ[dst(e)])
        end
        c1 = canonical_color_refinement(g1, ones(Int, nv(g1)), [1])
        c2 = canonical_color_refinement(g2, ones(Int, nv(g2)), [1])
        @test all(c1[v] == c2[σ[v]] for v in vertices(g1))

        # A supplied initial coloring is vertex-indexed and must be transported by
        # the same isomorphism. Its color labels, and therefore the refining set,
        # remain unchanged.
        alpha1 = [10, 10, 20, 20, 10, 20]
        alpha2 = similar(alpha1)
        for v in vertices(g1)
            alpha2[σ[v]] = alpha1[v]
        end
        c1 = canonical_color_refinement(g1, alpha1, [10, 20])
        c2 = canonical_color_refinement(g2, alpha2, [10, 20])
        @test all(c1[v] == c2[σ[v]] for v in vertices(g1))
    end

    @testset "Directed path is fully distinguished" begin
        # Each vertex's out-structure differs (the sink has out-degree 0, its
        # predecessor's only out-neighbor is the sink, and so on down the chain), so
        # every vertex ends up in a class of its own.
        dg = path_digraph(4)
        c = canonical_color_refinement(dg, ones(Int, nv(dg)), [1])
        @test length(unique(c)) == nv(dg)
    end

    @testset "Digraphs refine only out-edge structure" begin
        # Digraph refinement uses only outgoing-edge structure. Iterating over
        # `inneighbors` counts each vertex's outgoing edges into the refining class;
        # incoming-edge structure does not cause a split. Thus, vertices with equal
        # out-neighbors but different in-neighbors remain indistinguishable. This is
        # the paper's primary stability definition.
        dg2 = SimpleDiGraph(4)
        add_edge!(dg2, 1, 3) # 1 and 2 both point only to 3 ...
        add_edge!(dg2, 2, 3)
        add_edge!(dg2, 4, 1) # ... but 1 (unlike 2) also has an incoming edge from 4
        c = canonical_color_refinement(dg2, ones(Int, nv(dg2)), [1])
        @test c[1] == c[2]
    end

    @testset "All public entry points agree" begin
        # The `color_refinement` alias and every convenience overload should delegate
        # to `canonical_color_refinement` with the default coloring and refining set.
        g_wrapper = path_graph(5)
        c_wrapper = canonical_color_refinement(g_wrapper, ones(Int, nv(g_wrapper)), [1])
        @test color_refinement(g_wrapper, ones(Int, nv(g_wrapper)), [1]) == c_wrapper
        @test canonical_color_refinement(g_wrapper) == c_wrapper
        @test canonical_color_refinement(g_wrapper, ones(Int, nv(g_wrapper))) == c_wrapper
        @test canonical_color_refinement(g_wrapper, 1) == c_wrapper
        @test color_refinement(g_wrapper) == c_wrapper
        @test color_refinement(g_wrapper, ones(Int, nv(g_wrapper))) == c_wrapper
        @test color_refinement(g_wrapper, 1) == c_wrapper
    end

    @testset "Scalar refining color equals a one-element set" begin
        # Verify delegation for a non-unit initial coloring and a scalar other than
        # the default refining color 1.
        alpha = [100, 100, 200, 200, 100]
        @test canonical_color_refinement(path_graph(5), alpha, 100) ==
            canonical_color_refinement(path_graph(5), alpha, [100])
        @test color_refinement(path_graph(5), alpha, 100) ==
            color_refinement(path_graph(5), alpha, [100])
    end

    @testset "Empty graphs" begin
        @test canonical_color_refinement(SimpleGraph(0), Int[], Int[]) == Int[]
        # An empty graph has no color classes, so `S` is ignored and the empty
        # coloring is returned.
        @test canonical_color_refinement(SimpleGraph(0), Int[], [1]) == Int[]
        @test canonical_color_refinement(SimpleGraph(0)) == Int[]
    end

    @testset "Arbitrary ordered label values are accepted" begin
        # Initial labels need not form a dense range. Replacing them by another
        # order-preserving set of labels leaves their canonical dense numbering—and
        # therefore the result—unchanged.
        c = canonical_color_refinement(path_graph(5), [100, 100, 200, 200, 100], [100])
        c_alt = canonical_color_refinement(path_graph(5), [7, 7, 9, 9, 7], [7])
        @test c == c_alt
    end

    @testset "Default refining set includes every initial color" begin
        g = path_graph(5)
        alpha = [10, 10, 20, 20, 10]
        @test canonical_color_refinement(g, alpha) ==
            canonical_color_refinement(g, alpha, unique(alpha))
        @test color_refinement(g, alpha) == color_refinement(g, alpha, unique(alpha))
    end

    @testset "Duplicate refining colors are ignored" begin
        g = path_graph(5)
        alpha = ones(Int, nv(g))
        @test canonical_color_refinement(g, alpha, [1, 1]) ==
            canonical_color_refinement(g, alpha, [1])
    end

    @testset "Zero and negative labels" begin
        # Vertex 2 has a neighbor in the class labeled 0, while vertex 3 does not;
        # refinement therefore distinguishes all three vertices. Replacing label 0
        # with a negative label preserves the same ordered initial coloring.
        c = canonical_color_refinement(path_graph(3), [0, 1, 1], [0])
        c_negative = canonical_color_refinement(path_graph(3), [-7, 1, 1], [-7])
        @test c[1] != c[2]
        @test c[2] != c[3]
        @test c[1] != c[3]
        @test c_negative == c
    end

    @testset "Rejects wrong-length alpha" begin
        @test_throws ArgumentError canonical_color_refinement(
            path_graph(3), ones(Int, 2), [1]
        )
    end

    @testset "Rejects refining colors absent from alpha" begin
        @test_throws ArgumentError canonical_color_refinement(
            path_graph(3), ones(Int, 3), [2]
        )
    end

    @testset "Empty refining set leaves the initial partition unchanged" begin
        # No refinement is performed; arbitrary labels are only mapped to their
        # deterministic dense order.
        @test canonical_color_refinement(path_graph(4), [3, 1, 1, 3], Int[]) == [2, 1, 1, 2]
    end

    @testset "Self-loops" begin
        # A self-loop makes vertex 1 structurally unique here.
        g_loop = SimpleGraph(3)
        add_edge!(g_loop, 1, 1)
        add_edge!(g_loop, 1, 2)
        add_edge!(g_loop, 2, 3)
        c = canonical_color_refinement(g_loop, ones(Int, 3), [1])
        @test length(unique(c)) == 3
    end

    @testset "Disconnected graphs" begin
        # Isomorphic components land on identical colors (color refinement has no
        # notion of "component id"), and an isolated vertex forms its own class.
        g_disc = SimpleGraph(7)
        add_edge!(g_disc, 1, 2)
        add_edge!(g_disc, 2, 3)
        add_edge!(g_disc, 4, 5)
        add_edge!(g_disc, 5, 6)
        c = canonical_color_refinement(g_disc, ones(Int, 7), [1])
        @test c[1:3] == c[4:6]
        @test c[1] != c[2] # endpoint vs. middle of each path component
        @test c[7] ∉ c[1:6] # the isolated vertex is in a class of its own
    end

    @testset "Refinement is idempotent" begin
        # Re-refining an already-stable coloring with all classes changes nothing.
        g_idem = path_graph(5)
        c = canonical_color_refinement(g_idem, ones(Int, nv(g_idem)), [1])
        @test canonical_color_refinement(g_idem, c, unique(c)) == c
    end

    @testset "One refining color can be sufficient" begin
        # For this graph, using only the smaller initial class produces the same
        # stable partition as using every initial class. This is specific to the
        # instance: omitting a class can otherwise stop refinement early. Callers
        # requiring the coarsest stable coloring should use every label in `alpha`.
        g_refine = path_graph(6)
        alpha_refine = [1, 1, 1, 1, 2, 2]
        c_small_set = canonical_color_refinement(g_refine, alpha_refine, [2])
        c_all_colors = canonical_color_refinement(g_refine, alpha_refine, [1, 2])
        @test c_small_set == c_all_colors
    end

    @testset "Multiple refining colors act together" begin
        # Using every initial class is always sufficient to reach the true stable
        # partition (unlike an arbitrary strict subset, which is not guaranteed to
        # stabilize the coloring fully).
        g_multi = path_graph(7)
        alpha_multi = [1, 1, 2, 2, 2, 3, 3]
        c = canonical_color_refinement(g_multi, alpha_multi, [1, 2, 3])
        @test length(unique(c)) ==
            length(unique(_naive_stable_coloring(g_multi, alpha_multi)))
    end

    @testset "Complete bipartite graph" begin
        # The two sides are distinguished by size, while vertices on the same side
        # remain indistinguishable.
        g_bip = complete_bipartite_graph(2, 3)
        c = canonical_color_refinement(g_bip, ones(Int, nv(g_bip)), [1])
        @test c[1] == c[2]
        @test all(==(c[3]), c[3:5])
        @test c[1] != c[3]
    end

    @testset "Random graphs match brute-force fixed point" begin
        # Compare against an independent brute-force fixed-point computation on
        # random undirected graphs. Using every initial class guarantees full
        # stabilization.
        rng = MersenneTwister(20260705)
        for _ in 1:30
            n = rand(rng, 3:10)
            p = rand(rng, (0.1, 0.3, 0.5, 0.7))
            g_rand = erdos_renyi(n, p; rng=rng)
            alpha_rand = rand(rng, 1:rand(rng, 1:min(4, n)), n)
            expected = _naive_stable_coloring(g_rand, alpha_rand)
            actual = canonical_color_refinement(g_rand, alpha_rand, unique(alpha_rand))
            @test _same_partition(actual, expected)
        end
    end
end
