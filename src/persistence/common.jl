abstract type AbstractGraphFormat end

"""
    loadgraph(file, gname="graph", format=LGFormat())

Read a graph named `gname` from `file` in the format `format`.

### Implementation Notes
`gname` is graph-format dependent and is only used if the file contains
multiple graphs; if the file format does not support multiple graphs, this
value is ignored. The default value may change in the future.
"""
function loadgraph(fn::AbstractString, gname::AbstractString, format::AbstractGraphFormat)
    open(fn, "r") do io
        loadgraph(auto_decompress(io), gname, format)
    end
end
loadgraph(fn::AbstractString) = loadgraph(fn, "graph", LGFormat())
loadgraph(fn::AbstractString, gname::AbstractString) = loadgraph(fn, gname, LGFormat())
loadgraph(fn::AbstractString, format::AbstractGraphFormat) = loadgraph(fn, "graph", format)

"""
    loadgraphs(file, format=LGFormat())

Load multiple graphs from `file` in the format `format`.
Return a dictionary mapping graph name to graph.

### Implementation Notes
For unnamed graphs the default name \"graph\" will be used. This default
may change in the future.
"""
function loadgraphs(fn::AbstractString, format::AbstractGraphFormat)
    open(fn, "r") do io
        loadgraphs(auto_decompress(io), format)
    end
end

loadgraphs(fn::AbstractString) = loadgraphs(fn, LGFormat())

function auto_decompress(io::IO)
    format = :raw
    mark(io)
    if !eof(io)
        b1 = read(io, UInt8)
        if !eof(io)
            b2 = read(io, UInt8)
            if (b1, b2) == (0x1f, 0x8b)  # check magic bytes
                format = :gzip
            end
        end
    end
    reset(io)
    if format == :gzip
        io = InflateGzipStream(io)
    end
    return io
end

"""
    savegraph(file, g, gname="graph", format=LGFormat)

Saves a graph `g` with name `gname` to `file` in the format `format`.
Return the number of graphs written.

### Implementation Notes
The default graph name assigned to `gname` may change in the future.
"""
function savegraph(
    fn::AbstractString,
    g::AbstractGraph,
    gname::AbstractString,
    format::AbstractGraphFormat;
    compress=nothing,
)
    if compress !== nothing
        if !compress
            @info(
                "Note: the `compress` keyword is no longer supported in Graphs. Saving uncompressed."
            )
        else
            Base.depwarn(
                "Saving compressed graphs is no longer supported in Graphs. Use `LGCompressedFormat()` from the `GraphIO.jl` package instead. Saving uncompressed.",
                :savegraph,
            )
        end
    end
    io = open(fn, "w")
    try
        return savegraph(io, g, gname, format)
    catch
        rethrow()
    finally
        close(io)
    end
end

# without graph name
function savegraph(
    fn::AbstractString, g::AbstractGraph, format::AbstractGraphFormat; compress=nothing
)
    return savegraph(fn, g, "graph", format; compress=compress)
end

# without format - default to LGFormat()
function savegraph(fn::AbstractString, g::AbstractSimpleGraph; compress=nothing)
    return savegraph(fn, g, "graph", LGFormat(); compress=compress)
end

"""
    savegraph(file, d, format=LGFormat())

Save a dictionary `d` of `graphname => graph` to `file` in the format `format`.
Return the number of graphs written.

# Examples
```jldoctest
julia> using Graphs

julia> g1 = SimpleGraph(5,8)
{5, 8} undirected simple Int64 graph

julia> g2 = SimpleGraph(7,10)
{7, 10} undirected simple Int64 graph

julia> d = Dict("graph_1" => g1, "graph_2" => g2);

julia> savegraph("myfile.txt", d, LGFormat())
2
```

### Implementation Notes
Will only work if the file format supports multiple graph types.
"""
function savegraph(
    fn::AbstractString, d::Dict{T,U}, format::AbstractGraphFormat; compress=nothing
) where {T<:AbstractString} where {U<:AbstractGraph}
    compress === nothing || Base.depwarn(
        "Saving compressed graphs is no longer supported in Graphs. Use `LGCompressedFormat()` from the `GraphIO.jl` package instead. Saving uncompressed.",
        :savegraph,
    )
    io = open(fn, "w")

    try
        return savegraph(io, d, format)
    catch
        rethrow()
    finally
        close(io)
    end
end

savegraph(fn::AbstractString, d::Dict) = savegraph(fn, d, LGFormat())
