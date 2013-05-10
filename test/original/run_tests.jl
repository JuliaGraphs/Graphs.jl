require(joinpath("src","Graphs"))
using Graphs

my_tests = ["test/vertex.jl",
            "test/edge.jl",
            "test/graph.jl",
            "test/advanced.jl",
            "test/dot.jl",
            "test/random.jl",
            "test/io.jl"]

println("Running tests:")
for my_test in my_tests
    println(" * $(my_test)")
    include(my_test)
end
