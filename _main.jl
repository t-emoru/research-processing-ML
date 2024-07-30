#-------------------------------------------------------------------------------
# Introduction
#-------------------------------------------------------------------------------


"
Cummulative Algorithm Function:
    [main CASH ACCOUNTS & subsidiary MARGIN ACCOUNTS for Shorting]
    *****need margin account for Shorting with Alpaca

    Asynchronous Operation Modes: High Risk & Low Risk


    ##LOW RISK - long term holds
    1. Finding Top Traded Most Profitable Companies
        i) Search 
        ii) Srub and produce List of Companies
            a) Produce List of Articles related to search
            b) Srub articles for list of companies (and stock name)

        iii) Produce list of news article lists (within set time period) 
        relating to each company in the list above


    2. Finding Top Traded Most Stable Industries 
        i) Search
        ii) Srub and produce List of Industries & Commodies to traded 
        iii) Produce list of news article lists (within set time period) relating to each
            company in the list above



    ##HIGH RISK - short term holds [HFT mode on a Timeframe of Seconds to Weeks]
    3. Finding Volatile Currently high value stock, Swing Trade Stocks and HTF Stocks
        i) Search
        ii) Srub and produce List of commodities
        iii) Produce list of news article lists (within set time period) relating to each
            company in the list above

    
    Trading Strategy is developed through processing 3 data streams

    Current Market Data [Previous & Current]: MooMoo, Alpaca
    Company Financial Data: 
    Sentiment Data: Google News Search, Reddit

    Trades are executed using: [insert BROKER] API*


    The Algorithm then takes the list of companines generated from these two Modes
    then develops an individual portfolio that rountinely checks the 'required data'
    to decide wheter to buy, sell or short the traded stock 

    Algorithmically this is done by dynamic readjustments of parameters in base trading
    model. AND constant retrianing and reapplication of data models. 
    


"



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
using Gumbo
using Dates

#-------------------------------------------------------------------------------
# current testing block from old file
#-------------------------------------------------------------------------------


# Search



### SEARCH TESTING
query = "best stocks"

## - Obtain Search Result URLS
raw = Search.GOOGLE_search(query, 3)
raww = Search.STEM_search(query, 3)
rawww = Search.MEDIA_search("search", query, 3)
rawwww = Search.MEDIA_search("posts", query, 3) # QUERY MUST BE A SUBREDDIT NAME

## - looking at the first result
Search.tagged_print(raw[2])
Search.tagged_print(raww[1][1])
Search.tagged_print(rawww[1])
Search.tagged_print(rawwww[1])






### EXTRACTION TESTING
"due to varrying data types for tagged data, extraction has to consider this condition"

## - data formatting 
raw[1].data
parsed = parsehtml(string(raw[2].data))
input = parsed.root




## - next stage data extraction


# doesnt go deep enough into the HTML Structure
function version1(body::HTMLElement)


    for elem in PostOrderDFS(body) 

        try
            println(typeof(elem))
            
            # Process the current node (e.g., extract URL if applicable)
            # Example (pseudo-code, adjust to your actual use case):
            # url = extract_url(node)
            # push!(clean_URLs, url) if url
    
            # Recursively process children
    
    
            try 
                d_elem = elem.children
    
                # if length(d_elem) > 0
                    println(length(d_elem))
    
                    for i in eachindex(d_elem)
                        println("   ", typeof(d_elem[i]))
                        # println("done with this node")
    
                    end
                # end
    
            
            catch er
                println("error: $er")
                nothing
            end 
    
            
            println("   ")
    
            
        catch er
            println("error: $er")
            println("   ")
    
        end

    end


    return 0
end

# doesnt go deep enough into the HTML Structure
function version2(body::HTMLElement)
    
    urls_new = []

    for elem in PreOrderDFS(body)

        try
            println(typeof(elem))

            push!(urls_new, elem)



            try 
                d_elem = elem.children
    

    
            
            catch er
                println("error: $er")
                nothing
            end 


        catch
            println("")
        end

    end

    return urls_new

end

# PreOrderDFS can be called again to go deeper into node 
# Recursively enter each node (that may be in a HTMLvector) till there is no children while checking for atags



# trying yo view the tree

# how deep does DFS go? - all the way in, so why does it work for google search?


"
potential solutions 

revisit intial code structure in main file

redesign functions from scratch 
      with DFS (recurrsion)  - SOMMY
      without DFS ~ (hardcode) - TOMI


"
























# Analysis

model = Analysis.load_model("model_4")
prediction = Analysis.predict(model, "This project is execellent")




# Threading

versioninfo()
" 24 threads available on home device"
Threads.nthreads()
Threads.threadid()

