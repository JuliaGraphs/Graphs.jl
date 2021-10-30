# Integration with other packages

*Graphs.jl*'s integration with other Julia packages is designed to be straightforward. Here are some examples.


## [Metis.jl](https://github.com/JuliaSparse/Metis.jl)

The Metis graph partitioning package can interface with *Graphs.jl*:

```julia
julia> using Graphs

julia> g = SimpleGraph(100,1000)
{100, 1000} undirected graph

julia> partGraphKway(g, 6)  # 6 partitions
```
