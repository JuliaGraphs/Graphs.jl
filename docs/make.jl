using Documenter
#include("../src/Graphs.jl")
using Graphs

# same for contributing and license
cp(
    normpath(@__FILE__, "../../CONTRIBUTING.md"),
    normpath(@__FILE__, "../src/contributing.md");
    force=true,
)
cp(
    normpath(@__FILE__, "../../LICENSE.md"),
    normpath(@__FILE__, "../src/license.md");
    force=true,
)

makedocs(;
    modules=[Graphs],
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
        collapselevel=1,
        canonical="https://gdalle.github.io/Graphs.jl",
    ),
    sitename="Graphs.jl",
    doctest=false,
    expandfirst=[],
    pages=[
        "Introduction" => [
            "Package Overview" => "index.md",
            "Citing Graphs" => "citing.md",
            "License Information" => "license.md",
            "Contributing" => "contributing.md",
        ],
        "Tutorials" => [],
        "'How-to' guides" => [
            "Graph types" => "howto/concrete_types.md",
            "Interface" => "howto/interface.md",
            "Construction" => "howto/construction.md",
            "Access" => "howto/access.md",
            "Plotting" => "howto/plotting.md",
            "Reading and writing" => "howto/persistence.md",
            "Paths and traversal" => "howto/paths_traversal.md",
        ],
        "Explanation" => [
            "Graph theory" => "explanation/theory.md",
            "Choosing a graph type" => "explanation/graphtypes.md",
            "Error handling" => "explanation/errorhandling.md",
            "Parallel algorithms" => "explanation/parallel.md",
            "Integration with other packages" => "explanation/integration.md",
        ],
        "API Reference" => [
            "Biconnectivity" => "reference/biconnectivity.md",
            "Centrality" => "reference/centrality.md",
            "Community" => "reference/community.md",
            "Connectivity" => "reference/connectivity.md",
            "Core" => "reference/core.md",
            "Cut" => "reference/cut.md",
            "Cycles" => "reference/cycles.md",
            "Degeneracy" => "reference/degeneracy.md",
            "Digraph" => "reference/digraph.md",
            "Distance" => "reference/distance.md",
            "Dominating set" => "reference/dominatingset.md",
            "Edit distance" => "reference/edit_distance.md",
            "Experimental" => "reference/experimental.md",
            "Independent set" => "reference/independentset.md",
            "Interface" => "reference/interface.md",
            "Linear algebra" => "reference/linalg.md",
            "Module" => "reference/module.md",
            "Operators" => "reference/operators.md",
            "Parallel" => "reference/parallel.md",
            "Persistence" => "reference/persistence.md",
            "Shortest paths" => "reference/shortestpaths.md",
            "SimpleGraphs generators" => "reference/simplegraphs_generators.md",
            "SimpleGraphs" => "reference/simplegraphs.md",
            "Spanning trees" => "reference/spanningtrees.md",
            "Steiner tree" => "reference/steinertree.md",
            "Traversals" => "reference/traversals.md",
            "Utilities" => "reference/utils.md",
            "Vertex cover" => "reference/vertexcover.md",
        ],
    ],
)

# deploydocs(; repo="github.com/JuliaGraphs/Graphs.jl.git", target="build")

deploydocs(; repo="github.com/gdalle/Graphs.jl", target="build", devbranch="master")

rm(normpath(@__FILE__, "../src/contributing.md"))
rm(normpath(@__FILE__, "../src/license.md"))
