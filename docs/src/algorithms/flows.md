# Flows

This code was originally part of [GraphsFlows.jl](https://github.com/JuliaGraphs/GraphsFlows.jl).

## Maximum flow

```@docs
maximum_flow
EdmondsKarpAlgorithm
DinicAlgorithm
BoykovKolmogorovAlgorithm
PushRelabelAlgorithm
```

## Multi-route flow

```@docs
multiroute_flow
KishimotoAlgorithm
ExtendedMultirouteFlowAlgorithm
```

## Min-cut

```@docs
mincut_flow
```

## Internals

These functions are not part of the public API and can change or disappear between releases.

### Types

```@docs
Graphs.AbstractFlowAlgorithm
Graphs.AbstractMultirouteFlowAlgorithm
Graphs.DefaultCapacity
```

### Implementations

```@docs
Graphs.boykov_kolmogorov
Graphs.ext_multiroute_flow
Graphs.edmonds_karp
Graphs.push_relabel
Graphs.kishimoto
Graphs.dinic
```

### Utils

```@docs
Graphs.dinic_blocking_flow
Graphs.dinic_blocking_flow!
Graphs.edmonds_karp_augment_path!
Graphs.edmonds_karp_fetch_path!
Graphs.edmonds_karp_fetch_path
Graphs.ext_multiroute_flow_approximately_equal
Graphs.ext_multiroute_flow_auxiliaryPoints
Graphs.ext_multiroute_flow_breakingPoints
Graphs.ext_multiroute_flow_intersection
Graphs.ext_multiroute_flow_minmaxCapacity
Graphs.ext_multiroute_flow_slope
Graphs.push_relabel_discharge!
Graphs.push_relabel_enqueue_vertex!
Graphs.push_relabel_push_flow!
Graphs.push_relabel_gap!
Graphs.push_relabel_relabel!
Graphs.residual
```
