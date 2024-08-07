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
query = "stock markets most profitable companies"


## - Obtain Search Result URLS
raw = Search.GOOGLE_search(query, 1)
raww = Search.STEM_search(query, 3)
rawww = Search.MEDIA_search("search", query, 3)
rawwww = Search.MEDIA_search("posts", query, 3) # QUERY MUST BE A SUBREDDIT NAME

## - looking at the first result
Search.tagged_print(raw[1])
Search.tagged_print(raww[1][1])
Search.tagged_print(rawww[1])
Search.tagged_print(rawwww[1])






### EXTRACTION TESTING
"due to varrying data types for tagged data, extraction has to consider this condition"

## - data formatting 
raw[1].data
parsed = parsehtml(String(raw[1].data))
input = parsed.root[2]




# YAYY It fucking works
# now work on filterring urls! YAYY
function version3(body)

    "
    Function: extraxts url from html content
    Return: Clean Urls
    
    potentional refinement: import beautifulsoup4 python functions using
    https://gist.github.com/genkuroki/c26f22d3a06a69f917fc98bb07c5c90c
    "


    #URL Types
    raw_URLs = [] # contain anchor tags
    dirty_URLs = []
    clean_URLs = []
    filtered_urls = []
    url_pattern = r"(https?://[^&]+)" # Pattern for cleaning urls


    # Acquiring "Dirty" & "raw" URLs
    " 
    Optimize: try using the built in 'eachmatch' function
    "
    for elem in PreOrderDFS(body)

        try
            # println(tag(elem))  -  creates tree
            if tag(elem) == :a
                push!(raw_URLs, elem)

                href = getattr(elem, "href")
                push!(dirty_URLs, href)


            end

        catch
            println("")
        end

    end



    # # Acquiring "Clean" URLs
    # for urls in dirty_URLs
    #     matches = eachmatch(url_pattern, urls)

    #     if !isempty(matches)
    #         url = first(matches).match
    #         push!(clean_URLs, url)
    #     else
    #         println("No URL found in the input string.")
    #     end

    # end



    # ## Filtering Useless Clean URLs
    # "If it contains 'google' or doesn't equal 200"
    # for str in clean_URLs

    #     if !occursin("google", str)

    #         try
    #             if HTTP.status(HTTP.request("GET", str)) == 200
    #                 push!(filtered_urls, str)

    #             end

    #         catch
    #             println("Can not access site")
    #         end

    #     end
    # end

    

    
    return dirty_URLs
end



version3(input)


####    Article Sraping Function   #####

function scrape_webpage(url::String; body_text_limit::Int = 2200)
    # Fetch the webpage content
    response = HTTP.get(url)
    html_content = String(response.body)
    
    # Parse the HTML content
    parsed_content = parsehtml(html_content)
    
    # Define CSS selectors for headings, titles, and body text
    selectors = Dict(
        "titles" => "title, h1, h2, h3, h4, h5, h6",
        "headings" => "h1, h2, h3, h4, h5, h6",
        "body" => "p, div"
    )
    
    # Extract the text for each selector
    extracted_data = Dict{String, Vector{String}}()
    
    for (key, selector) in selectors
        elements = eachmatch(Selector(selector), parsed_content.root)
        if key == "body"
            body_text = join([text(node) for node in elements], " ")
            extracted_data[key] = [body_text[1:min(end, body_text_limit)]]
        else
            extracted_data[key] = [text(node) for node in elements]
        end
    end
    
    return extracted_data
end

# Example usage
url = "https://finance.yahoo.com/?guccounter=1&guce_referrer=aHR0cHM6Ly93d3cuYmluZy5jb20v&guce_referrer_sig=AQAAANTxpoSKjEBsXZiD6qTdnC2d4sPzS5ulYZ_LsxqL2yLcPQ67Z066QsbejMnTcgIRu7JCy-q87jXTCyxBEU4epfH0jNoaNmjxkeG5o5dlD8RF4V36c3vY1bcNa0yhR9qkJKDj8C9kFbcDnJX-M0ysqIQh4WXbKMnEkedNPHfAvD8h" 
scraped_data = scrape_webpage(url)

println("Titles: ", scraped_data["titles"])
println("Headings: ", scraped_data["headings"])
println("Body: ", scraped_data["body"])


























# Analysis

model = Analysis.load_model("model_4")
prediction = Analysis.predict(model, "This project is execellent")




# Threading

versioninfo()
" 24 threads available on home device"
Threads.nthreads()
Threads.threadid()

