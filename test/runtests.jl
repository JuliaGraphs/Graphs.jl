using Aqua
using Documenter
using Graphs
using Graphs.SimpleGraphs
using Graphs.Experimental
using JET
using JuliaFormatter
using Graphs.Test
using Test
using SparseArrays
using LinearAlgebra
using Compat
using DelimitedFiles
using Base64
using Random
using Statistics: mean, std
using StableRNGs
using Pkg

const testdir = dirname(@__FILE__)

function get_pkg_version(name::AbstractString)
    for dep in values(Pkg.dependencies())
        if dep.name == name
            return dep.version
        end
    end
    return error("Dependency not available")
end

#@testset "Code quality (JET.jl)" begin
#    if VERSION >= v"1.9"
#        @assert get_pkg_version("JET") >= v"0.8.4"
#        JET.test_package(Graphs; target_defined_modules=true, ignore_missing_comparison=true)
#    end
#end

@testset verbose = true "Code quality (Aqua.jl)" begin
    Aqua.test_all(Graphs; ambiguities=false)
end

@testset verbose = true "Code formatting (JuliaFormatter.jl)" begin
    @test format(Graphs; verbose=false, overwrite=false, ignore="vf2.jl")  # TODO: remove ignore kwarg once the file is formatted correctly
end

#doctest(Graphs)

function testgraphs(g)
    return if is_directed(g)
        [g, DiGraph{UInt8}(g), DiGraph{Int16}(g)]
    else
        [g, Graph{UInt8}(g), Graph{Int16}(g)]
    end
end
testgraphs(gs...) = vcat((testgraphs(g) for g in gs)...)
testdigraphs = testgraphs

# some operations will create a large graph from two smaller graphs. We
# might error out on very small eltypes.
function testlargegraphs(g)
    return if is_directed(g)
        [g, DiGraph{UInt16}(g), DiGraph{Int32}(g)]
    else
        [g, Graph{UInt16}(g), Graph{Int32}(g)]
    end
end
testlargegraphs(gs...) = vcat((testlargegraphs(g) for g in gs)...)

function test_generic_graphs(g; eltypes=[UInt8, Int16], skip_if_too_large::Bool=false)
    SG = is_directed(g) ? SimpleDiGraph : SimpleGraph
    GG = is_directed(g) ? GenericDiGraph : GenericGraph
    result = GG[]
    for T in  eltypes
        if skip_if_too_large && nv(g) > typemax(T)
            continue
        end
        push!(result, GG(SG{T}(g)))
    end
    return result
end

test_large_generic_graphs(g; skip_if_too_large::Bool=false) = test_generic_graphs(g; eltypes=[UInt16, Int32], skip_if_too_large=skip_if_too_large)


tests = [
    "iterators/iterators",
]

@testset verbose = true "Graphs" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end;
