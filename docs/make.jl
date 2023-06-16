using Documenter
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
cp(
    normpath(@__FILE__, "../../README.md"),
    normpath(@__FILE__, "../src/index.md");
    force=true,
)

function get_title(markdown_file_path::AbstractString)
    first_line = open(markdown_file_path) do io
        readline(io)
    end
    return String(chop(first_line; head=2, tail=0))
end

pages_files = [
    "First steps" => [
        "index.md",
        "first_steps/theory.md",
        "first_steps/construction.md",
        "first_steps/access.md",
        "first_steps/paths_traversal.md",
        "first_steps/plotting.md",
        "first_steps/persistence.md",
    ],
    "Ecosystem" => ["ecosystem/graphtypes.md", "ecosystem/interface.md"],
    "Core API" => [
        "core_functions/core.md",
        "core_functions/interface.md",
        "core_functions/module.md",
        "core_functions/operators.md",
        "core_functions/persistence.md",
        "core_functions/simplegraphs_generators.md",
        "core_functions/simplegraphs.md",
    ],
    "Algorithms API" => [
        "algorithms/biconnectivity.md",
        "algorithms/centrality.md",
        "algorithms/community.md",
        "algorithms/connectivity.md",
        "algorithms/cut.md",
        "algorithms/cycles.md",
        "algorithms/trees.md",
        "algorithms/degeneracy.md",
        "algorithms/digraph.md",
        "algorithms/distance.md",
        "algorithms/dominatingset.md",
        "algorithms/editdist.md",
        "algorithms/independentset.md",
        "algorithms/linalg.md",
        "algorithms/shortestpaths.md",
        "algorithms/spanningtrees.md",
        "algorithms/steinertree.md",
        "algorithms/traversals.md",
        "algorithms/utils.md",
        "algorithms/vertexcover.md",
    ],
    "For advanced users" => [
        "advanced/errorhandling.md",
        "advanced/experimental.md",
        "advanced/parallel.md",
        "contributing.md",
        "license.md",
    ],
]

pages = [
    section_name => [
        get_title(joinpath(normpath(@__FILE__, ".."), "src", file)) => file for
        file in section_files
    ] for (section_name, section_files) in pages_files
]

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
        section_name => [
            get_title(joinpath(normpath(@__FILE__, ".."), "src", file)) => file for
            file in section_files
        ] for (section_name, section_files) in pages_files
    ],
)

deploydocs(; repo="github.com/JuliaGraphs/Graphs.jl.git", target="build")

rm(normpath(@__FILE__, "../src/contributing.md"))
rm(normpath(@__FILE__, "../src/license.md"))
rm(normpath(@__FILE__, "../src/index.md"))
