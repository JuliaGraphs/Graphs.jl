require("Graphs")
using Graphs

#
# Read edgelist format
#

pathname = file_path("test", "data", "graph1.edgelist")
g = Graphs.read_edgelist(pathname)
