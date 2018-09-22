# Test of Floyd-Warshall's algorithm

using Graphs
using Test

eweights = [  0.  1.  5. Inf;
            Inf   0.  3.  8.;
            Inf   3.  0.  2.;
             6. Inf  Inf  0. ]

dists0 = [  0. 1.  4. 6.;
           11. 0.  3. 5.;
            8. 3.  0. 2.;
            6. 7. 10. 0.  ]

nexts0 = [1 2 2 2; 3 2 3 3; 4 2 3 4; 1 1 1 4]

dists = copy(eweights)
nexts = fill(-1, (4, 4))

floyd_warshall!(dists, nexts)

@test dists == dists0
@test nexts == nexts0

@test floyd_warshall(eweights) == dists0
@test_throws ArgumentError floyd_warshall!(rand(3,5))
@test_throws ArgumentError floyd_warshall!(rand(3,5),rand(1:7,5,5))
@test_throws ArgumentError floyd_warshall!(rand(5,5),rand(1:7,3,5))
