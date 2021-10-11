using Documenter
#include("../src/Graphs.jl")
using Graphs

# same for contributing and license
cp(normpath(@__FILE__, "../../CONTRIBUTING.md"), normpath(@__FILE__, "../src/contributing.md"); force=true)
cp(normpath(@__FILE__, "../../LICENSE.md"), normpath(@__FILE__, "../src/license.md"); force=true)

makedocs(
    modules     = [Graphs],
    format      = Documenter.HTML(), 
    sitename    = "Graphs",
    doctest     = false,
    pages       = Any[
        "Getting Started"                   => "index.md",
        "Choosing A Graph Type"             => "graphtypes.md",
        "Graphs Types"                      => "types.md",
        "Accessing Properties"              => "basicproperties.md",
        "Making and Modifying Graphs"       => "generators.md",
        "Reading / Writing Graphs"          => "persistence.md",
        "Operators"                         => "operators.md",
        "Core Functions"                    => "core.md",
        "Plotting Graphs"                   => "plotting.md",
        "Path and Traversal"                => "pathing.md",
        "Coloring"                          => "coloring.md",
        "Distance"                          => "distance.md",
        "Centrality Measures"               => "centrality.md",
        "Linear Algebra"                    => "linalg.md",
        "Matching"                          => "matching.md",
        "Community Structures"              => "community.md",
        "Degeneracy"                        => "degeneracy.md",
        "Integration with other packages"   => "integration.md",
        "Experimental Functionality"        => "experimental.md",
        "Parallel Algorithms"               => "parallel.md",
        "Contributing"                      => "contributing.md",
        "Developer Notes"                   => "developing.md",
        "License Information"               => "license.md",
        "Citing Graphs"                     => "citing.md"
    ]
)

deploydocs(
    repo        = "github.com/JuliaGraphs/Graphs.jl.git",
    target      = "build",
)

rm(normpath(@__FILE__, "../src/contributing.md"))
rm(normpath(@__FILE__, "../src/license.md"))
