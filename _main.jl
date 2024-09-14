#-------------------------------------------------------------------------------
# Introduction
#-------------------------------------------------------------------------------

# CHANGE - look to make changes

# Custom Packaging Import
include("SETUP.jl")

include("Search.jl")
using .Search

include("Extraction.jl")
using .Extraction


include("Analysis.jl")
using .Analysis


# move this somehow? for testing leave here
using HTTP, Gumbo
using HTTP.Cookies
using AbstractTrees
using ReadableRegex
using Cascadia
using DataFrames
using CSV
using Dates
using Downloads
using Random
using DataFrames


#-------------------------------------------------------------------------------
# current testing block from old file
#-------------------------------------------------------------------------------


function print_full_strings(strings::Vector{Any})
    for str in strings
        println(str)
    end
end




