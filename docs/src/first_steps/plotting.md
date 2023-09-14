# Graph plotting

_Graphs.jl_ integrates with several other Julia packages for plotting. Here are a few examples.

## [TikzGraphs.jl](https://github.com/sisl/TikzGraphs.jl)

Another nice graph visualization package. ([TikzPictures.jl](https://github.com/sisl/TikzPictures.jl) required to render/save):

```julia
julia> g = wheel_graph(10); t = plot(g)

julia> save(SVG("wheel10.svg"), t)
```

producing a graph like this:

![Wheel Graph](https://cloud.githubusercontent.com/assets/941359/8960499/17f703c0-35c5-11e5-935e-044be51bc531.png)

## [GraphPlot.jl](https://github.com/afternone/GraphPlot.jl)

Another graph visualization package that is very simple to use. [Compose.jl](https://github.com/dcjones/Compose.jl) is required for most rendering functionality:

```julia
julia> using GraphPlot, Compose

julia> g = wheel_graph(10)

julia> draw(PNG("/tmp/wheel10.png", 16cm, 16cm), gplot(g))
```

## [SGtSNEpi.jl](https://github.com/fcdimitr/SGtSNEpi.jl)

SGtSNEpi.jl is a high-performance software for swift embedding of a large, sparse graph into a d-dimensional space (d = 1,2,3). The [Makie](http://makie.juliaplots.org) plotting ecosystem is used for interactive plots.

```julia
using GLMakie, SGtSNEpi, SNAPDatasets

GLMakie.activate!()

g = loadsnap(:as_caida)
y = sgtsnepi(g);
show_embedding(y;
  A = adjacency_matrix(g),        # show edges on embedding
  mrk_size = 1,                   # control node sizes
  lwd_in = 0.01, lwd_out = 0.001, # control edge widths
  edge_alpha = 0.03 )             # control edge transparency
```

The above code produces the following output:

![alt tag](https://github.com/fcdimitr/SGtSNEpi.jl/raw/master/docs/src/assets/as_caida.png)

SGtSNEpi.jl enables 3D graph embedding as well. The 3D embedding of the weighted undirected graph [ML_Graph/optdigits_10NN](https://sparse.tamu.edu/ML_Graph/optdigits_10NN) is shown below. It consists of 26,475 nodes and 53,381 edges. Nodes are colored according to labels provided with the dataset.

![alt tag](https://fcdimitr.github.io/SGtSNEpi.jl/v0.1.0/sgtsnepi-animation.gif)

## [GraphRecipes.jl](https://github.com/JuliaPlots/GraphRecipes.jl)

GraphRecipes.jl contains several recipes for plotting networks using the Plots.jl ecosystem. There are a lot of different recipes and styles to choose from, check out the [examples page](https://docs.juliaplots.org/stable/GraphRecipes/examples/) to see more of them.

```julia
using Plots, GraphRecipes
g = wheel_graph(10)
graphplot(g, curves=false)
```

![wheel graph with GraphRecipes.jl](https://user-images.githubusercontent.com/8610352/74631053-de196b80-51c0-11ea-8cba-ddbdc2c6312f.png)

## [GraphMakie.jl](https://github.com/JuliaPlots/GraphMakie.jl)

GraphMakie.jl is a graph plotting recipe for the Makie.jl ecosystem. It uses [NetworkLayout.jl](https://github.com/JuliaGraphs/NetworkLayout.jl) for the node placement and supports 2D and 3D plots. Check out the [docs](http://juliaplots.org/GraphMakie.jl/stable/) for more examples and tutorials.

```julia
using GLMakie, GraphMakie
using GraphMakie.NetworkLayout

g = smallgraph(:dodecahedral)
graphplot(g; layout=Stress(; dim=3))
```

![GraphMakie example plot](https://user-images.githubusercontent.com/35867212/133593687-b92b8af9-7bf1-4c43-999b-e2847edb869d.png)

## [Karnak.jl](https://github.com/cormullion/Karnak.jl)

The Karnak.jl package integrates the
[Luxor.jl](https://github.com/JuliaGraphics/Luxor.jl) 2D graphics package, and uses
[NetworkLayout.jl](https://github.com/JuliaGraphs/NetworkLayout.jl) for
calculating layouts. Check out the [docs](https://cormullion.github.io/Karnak.jl/stable/) for examples.

```julia
using Graphs
using Karnak
using NetworkLayout
using Colors
g = barabasi_albert(60, 1)
@drawsvg begin
    background("black")
    sethue("grey40")
    fontsize(8)
    drawgraph(g, 
        layout=stress, 
        vertexlabels = 1:nv(g),
        vertexfillcolors = 
            [RGB(rand(3)/2...) 
               for i in 1:nv(g)]
    )
end 600 400
```

![Karnak.jl example plot](../assets/karnak-example.svg)
