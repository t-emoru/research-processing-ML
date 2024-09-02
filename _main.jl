#-------------------------------------------------------------------------------
# Introduction
#-------------------------------------------------------------------------------



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
query = "Types of Cancer"


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

# search url function
test = Search.url_access("https://ca.news.yahoo.com/netflix-the-deliverance-caleb-mclaughlin-andra-day-and-glenn-close-star-in-lee-daniels-exorcism-film-021720023.html")



####    Article Sraping Function   #####

function v1scrape_webpage(html_element::HTMLElement{:body})
    

    
    # Define CSS selectors for headings, titles, and body text
    selectors = Dict(
        "titles" => "title",
        "body" => "p"
    )
    
    # Extract the text for each selector
    extracted_data = Dict{String, Vector{String}}()
    
    for (key, selector) in selectors
        elements = eachmatch(Selector(selector), html_element)
        if key == "body"
            # Join all body text elements without limiting their length
            body_text = join([text(node) for node in elements], " ")
            extracted_data[key] = [body_text]
        else
            # Store titles as a list of strings
            extracted_data[key] = [text(node) for node in elements]
        end
    end

    return extracted_data
end

function v2scrape_webpage(html_element::HTMLElement{:body})
    
    # Define CSS selectors for titles, body text, and date stamps
    selectors = Dict(
        "titles" => "title",
        "body" => "p",
        "dates" => "time, .date, .published-date"  # Example selectors for dates
    )
    
    # Extract the text for each selector
    extracted_data = Dict{String, Vector{String}}()
    
    for (key, selector) in selectors
        elements = eachmatch(Selector(selector), html_element)
        if key == "body"
            # Join all body text elements without limiting their length
            body_text = join([text(node) for node in elements], " ")
            extracted_data[key] = [body_text]
        else
            # Store other data (titles and dates) as a list of strings
            extracted_data[key] = [text(node) for node in elements]
        end
    end

    return extracted_data
end

function scrape_webpage(html_element::HTMLElement{:body})
    
    # Define CSS selectors for titles, body text, and potential date stamps
    selectors = Dict(
        "titles" => "title",
        "body" => "p",
        "dates" => "time, .date, .published-date, span, div"  # Added span and div for potential dates
    )
    
    # Function to parse and validate dates from text
    function extract_dates(texts::Vector{String})
        dates = []
        # List of month names to look for
        month_names = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        
        for text in texts
            for month in month_names
                if occursin(month, text)
                    push!(dates, text)
                    break  # Stop looking for other months once one is found
                end
            end
        end
        return dates
    end
    
    # Extract the text for each selector
    extracted_data = Dict{String, Vector{String}}()
    
    for (key, selector) in selectors
        elements = eachmatch(Selector(selector), html_element)
        texts = [string(text(node)) for node in elements]  # Convert SubString{String} to String
        
        if key == "body"
            # Join all body text elements without limiting their length
            body_text = join(texts, " ")
            extracted_data[key] = [body_text]
        else
            if key == "dates"
                # Extract and validate date stamps
                dates = extract_dates(texts)
                extracted_data[key] = dates
            else
                # Store other data (titles) as a list of strings
                extracted_data[key] = texts
            end
        end
    end

    return extracted_data
end



## - data formatting 
parsed = parsehtml(String(test))
input = parsed.root[2]

data = v2scrape_webpage(input) 
## BEST Wroking version - needs more testing of dates, then include tables and pdfs




## Displaying 
println("Titles: ", data["titles"])
println("Body: ", data["body"])
println("Dates: ", data["dates"])











#---PDF to Text Testing
pdf_file = "C:\\Users\\Tomi\\Downloads\\New folder\\Resume.pdf"
out = "C:\\Users\\Tomi\\Downloads\\New folder"

Pkg.add("Taro")
using Taro
Taro.init()


meta, text = Taro.extract(pdf_file);
text
println(text)














# Analysis

model = Analysis.load_model("model_4")
prediction = Analysis.predict(model, "This project is execellent")




# Threading

versioninfo()
" 24 threads available on home device"
Threads.nthreads()
Threads.threadid()

