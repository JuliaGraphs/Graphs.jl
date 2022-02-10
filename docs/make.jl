using Documenter
#include("../src/Graphs.jl")
using Graphs
using MetaGraphs
using MetaGraphsNext
using SimpleWeightedGraphs

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
    modules=[Graphs, MetaGraphs, MetaGraphsNext, SimpleWeightedGraphs],
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
        "First Steps" => [
            "Package overview" => "index.md",
            "Graph theory" => "first_steps/theory.md",
            "Constructing a graph" => "first_steps/construction.md",
            "Accessing graph properties" => "first_steps/access.md",
            "Running graph algorithms" => "first_steps/paths_traversal.md",
            "Plotting a graph" => "first_steps/plotting.md",
            "Reading and writing graphs" => "first_steps/persistence.md",
        ],
        "Graph types" => [
            "Existing graph types" => "graph_types/graphtypes.md",
            "Abstract interface" => "graph_types/interface.md",
            "Creating a new graph type" => "graph_types/creating.md",
        ],
        "Core functions" => [
            "Core" => "core_functions/core.md",
            "Interface" => "core_functions/interface.md",
            "Module" => "core_functions/module.md",
            "Operators" => "core_functions/operators.md",
            "Persistence" => "core_functions/persistence.md",
            "SimpleGraphs generators" => "core_functions/simplegraphs_generators.md",
            "SimpleGraphs" => "core_functions/simplegraphs.md",
        ],
        "Algorithms" => [
            "Biconnectivity" => "algorithms/biconnectivity.md",
            "Centrality" => "algorithms/centrality.md",
            "Community" => "algorithms/community.md",
            "Connectivity" => "algorithms/connectivity.md",
            "Cut" => "algorithms/cut.md",
            "Cycles" => "algorithms/cycles.md",
            "Degeneracy" => "algorithms/degeneracy.md",
            "Digraph" => "algorithms/digraph.md",
            "Distance" => "algorithms/distance.md",
            "Dominating set" => "algorithms/dominatingset.md",
            "Edit distance" => "algorithms/edit_distance.md",
            "Independent set" => "algorithms/independentset.md",
            "Linear algebra" => "algorithms/linalg.md",
            "Shortest paths" => "algorithms/shortestpaths.md",
            "Spanning trees" => "algorithms/spanningtrees.md",
            "Steiner tree" => "algorithms/steinertree.md",
            "Traversals" => "algorithms/traversals.md",
            "Utilities" => "algorithms/utils.md",
            "Vertex cover" => "algorithms/vertexcover.md",
        ],
        "Ecosystem docs" => [
            "MetaGraphs.jl" => "ecosystem/metagraphs.md",
            "MetaGraphsNext.jl" => "ecosystem/metagraphsnext.md",
            "SimpleWeightedGraphs.jl" => "ecosystem/simpleweightedgraphs.md",
        ],
        "For advanced users" => [
            "Error handling" => "advanced/errorhandling.md",
            "Experimental algorithms" => "advanced/experimental.md",
            "Parallel algorithms" => "advanced/parallel.md",
            "Integration with other packages" => "advanced/integration.md",
            "Contributing" => "contributing.md",
            "License information" => "license.md",
        ],
    ],
)

# deploydocs(; repo="github.com/JuliaGraphs/Graphs.jl.git", target="build")

deploydocs(; repo="github.com/gdalle/Graphs.jl", target="build", devbranch="master")

rm(normpath(@__FILE__, "../src/contributing.md"))
rm(normpath(@__FILE__, "../src/license.md"))
