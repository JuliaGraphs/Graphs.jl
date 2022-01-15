module Parallel

using Graphs
using Base.Threads: @threads, nthreads

include("traversals/gdistances.jl")

end
