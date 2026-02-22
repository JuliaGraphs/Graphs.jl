#Planar maximally filtered graph

"""
    pmfg(g, distmx=weights(g))

Return a graph representing the planar maximally filtered graph of a connected, undirected graph `g` with optional
distance matrix `distmx`. 

### References
- Tumminello et al. 2005, [https://doi.org/10.1073/pnas.0500298102](https://doi.org/10.1073/pnas.0500298102)
"""

pmfg(g::SimpleGraph, distmx=weights(g))