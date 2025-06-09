using Pkg; Pkg.activate(".")
using Revise
using Toolips
using ExploreTheCorners
toolips_process = start!(ExploreTheCorners, "192.168.1.28":8000)
