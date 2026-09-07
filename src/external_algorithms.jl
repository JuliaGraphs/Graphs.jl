"""
    Graphs.EXTERNAL_ALGORITHMS

Registry mapping every function that _Graphs.jl_ declares but does not
implement to the packages known to provide a method for it.

The entries are used by [`Graphs.external_algorithm_hint`](@ref) to turn the
`MethodError` of a missing implementation into a message that names the package
to install. Register a new entry with [`Graphs.@declare_external`](@ref).
"""
const EXTERNAL_ALGORITHMS = IdDict{Any,Vector{String}}()

"""
    @declare_external function_name "Package.jl" ["OtherPackage.jl" ...]

Record that `function_name` is implemented by the listed packages rather than by
_Graphs.jl_ itself.

The function must already be declared (`function function_name end`). Declaring
it separately keeps the docstring next to the signature it documents.
"""
macro declare_external(f, packages...)
    return quote
        EXTERNAL_ALGORITHMS[$(esc(f))] = String[$(map(esc, packages)...)]
    end
end

"""
    Graphs.external_algorithm_hint(io, exc)

Append an actionable note to the `MethodError` of a function that _Graphs.jl_
declares but leaves to an implementation package.

Registered as a `MethodError` hint in `Graphs.__init__`. The wording depends on
whether the function has any method at all and on whether an implementation
package is already loaded, so that nobody is told to install a package they
have.
"""
function external_algorithm_hint(io::IO, exc::MethodError)
    packages = get(EXTERNAL_ALGORITHMS, exc.f, nothing)
    packages === nothing && return nothing
    name = nameof(exc.f)
    list = join(packages, ", ", " or ")
    loaded = filter(_is_package_loaded, packages)
    if !isempty(methods(exc.f))
        print(
            io,
            "\n\n`$name` is implemented by $list, but no method matches these " *
            "argument types. Check the documentation of the implementation " *
            "package for the signatures it supports.",
        )
    elseif isempty(loaded)
        print(
            io,
            "\n\n`$name` is declared by Graphs.jl but implemented elsewhere: " *
            "install and load $list to get a method for it.",
        )
    else
        print(
            io,
            "\n\n`$name` is declared by Graphs.jl and implemented by $list. " *
            "$(join(loaded, ", ", " and ")) is loaded but defines no method for it, " *
            "so this version may not cover `$name` yet.",
        )
    end
    return nothing
end

# A package is considered loaded when a top-level module of that name is; the
# registry spells packages the way users install them, with the `.jl` suffix.
function _is_package_loaded(package::AbstractString)
    name = Symbol(chopsuffix(package, ".jl"))
    return any(m -> nameof(m) === name, values(Base.loaded_modules))
end

"""
    max_weight_perfect_matching(g, weights, alg)

Compute a perfect matching of the undirected graph `g` maximising the total
weight of the matched edges, and return a `(weight, mates)` tuple in which
`mates[v]` is the vertex matched with `v`.

A perfect matching covers every vertex exactly once, so it exists only if `g`
has an even number of vertices and enough edges; implementations are expected
to throw if none exists.

!!! note "Implementation package required"
    Graphs.jl only declares this function; it has no methods of its own.
    [LEMONGraphs.jl](https://github.com/JuliaGraphs/LEMONGraphs.jl) is the
    intended implementation, wrapping LEMON's `MaxWeightedPerfectMatching`:

    ```julia
    using Graphs, LEMONGraphs

    g = complete_graph(4)
    weight, mates = max_weight_perfect_matching(g, [10, 1, 1, 1, 1, 10], LEMONAlgorithm())
    ```

    That method arrives in the LEMONGraphs.jl release that follows this
    declaration; until then the algorithm lives there under its own name,
    `LEMONGraphs.maxweightedperfectmatching`.

    Calling it without an implementation package loaded raises a `MethodError`
    carrying a hint that names the package to install.

See also the discussion of
[dispatching to external implementations](@ref "Dispatching to algorithm implementations in external packages").
"""
function max_weight_perfect_matching end

@declare_external max_weight_perfect_matching "LEMONGraphs.jl"
