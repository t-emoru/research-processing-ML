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
using Dates
using Downloads
using Random
using DataFrames


#-------------------------------------------------------------------------------
# current testing block from old file
#-------------------------------------------------------------------------------


# Search



### SEARCH TESTING
query = "tiredness"


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







## returns all URLS 
function version3(body)


    #URL Types
    raw_URLs = [] # contain anchor tags
    dirty_URLs = []


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


    

    
    return dirty_URLs
end


function version4(body)
    # URL Types
    raw_URLs = []  # contain anchor tags
    dirty_URLs = []

    for elem in PreOrderDFS(body)
        try
            if tag(elem) == :a
                push!(raw_URLs, elem)

                href = getattr(elem, "href")

                # Filter to only include URLs that contain "http"
                if occursin("http", href)
                    push!(dirty_URLs, href)
                end
            end
        catch
            println("")
        end
    end

    return dirty_URLs
end


## for general Webpages *******
function version5(body)
    # URL Types
    raw_URLs = []  # contain anchor tags
    dirty_URLs = []

    for elem in PreOrderDFS(body)
        try
            if tag(elem) == :a
                push!(raw_URLs, elem)

                href = getattr(elem, "href")

                # Filter to only include URLs that contain "http"
                if occursin("http", href)
                    # Find the first occurrence of "http" and remove anything before it
                    http_range = findfirst("http", href)
                    if http_range !== nothing
                        cleaned_href = href[http_range.start:end]  # Use the start of the range
                        push!(dirty_URLs, cleaned_href)
                    end
                end
            end
        catch
            println("")
        end
    end

    return dirty_URLs
end



## retuens only relevnat urls - /url?esrc=s&
function version6(body)
    # URL Types
    raw_URLs = []  # contain anchor tags
    dirty_URLs = []
    relevant_URLs = []

    relevant_start_pattern = "/url?esrc=s&"  # Pattern that relevant URLs start with

    for elem in PreOrderDFS(body)
        try
            if tag(elem) == :a
                push!(raw_URLs, elem)
                href = getattr(elem, "href")
                push!(dirty_URLs, href)
            end
        catch
            println("Error processing an element")  # Improved error handling
        end
    end

    # Filter URLs to include only those starting with the relevant pattern
    for url in dirty_URLs
        if startswith(url, relevant_start_pattern)
            push!(relevant_URLs, url)
        end
    end

    return relevant_URLs
end


## for google search ********
function version7(body)
    # URL Types
    raw_URLs = []  # contain anchor tags
    dirty_URLs = []
    relevant_URLs = []
    cleaned_URLs = []

    relevant_start_pattern = "/url?esrc=s&"  # Pattern that relevant URLs start with
    prefix_to_remove = "/url?esrc=s&q=&rct=j&sa=U&url="  # Prefix to remove from each URL

    for elem in PreOrderDFS(body)
        try
            if tag(elem) == :a
                push!(raw_URLs, elem)
                href = getattr(elem, "href")
                push!(dirty_URLs, href)
            end
        catch e
            println("Error processing an element: ", e)  # Improved error handling
        end
    end

    # Filter URLs to include only those starting with the relevant pattern
    for url in dirty_URLs
        if startswith(url, relevant_start_pattern)
            push!(relevant_URLs, url)
        end
    end

    # Remove the specific prefix from each URL
    prefix_length = length(prefix_to_remove)
    for url in relevant_URLs
        if startswith(url, prefix_to_remove)
            cleaned_url = url[prefix_length + 1:end]  # Remove the prefix
            # Now, remove everything after the first "&"
            amp_index = findfirst('&', cleaned_url)
            if amp_index !== nothing
                cleaned_url = cleaned_url[1:amp_index-1]
            end
            push!(cleaned_URLs, cleaned_url)
        end
    end

    return cleaned_URLs
end


## gets pdf links ******
function extract_pdf(links::Vector{Any})
    return filter(link -> occursin("pdf", link), links)
end

## downloads pdfs ***
function download_pdf(url::String, save_path::String)
    try
        # Download the file and save it to the specified path
        Downloads.download(url, save_path)
        println("PDF downloaded successfully to $save_path")
    catch e
        println("Failed to download the PDF: $e")
    end
end

## pdf file to string
meta, text = Taro.extract(pdf_file);



function generate_unique_string(length::Int = 5)
    chars = ['A':'Z'; 'a':'z'; '0':'9']  # Character set (uppercase, lowercase, digits)
    return join(rand(chars, length))
end



function print_full_strings(strings::Vector{Any})
    for str in strings
        println(str)
    end
end




function v2scrape_webpage(html_element::HTMLElement)
    
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
# use gpt API to format date and transfer data into tagged data struct
# maybe look for more effienct way


### scapes title, date, body and tables from article/any webpage ****
function scrape_webpage(html_element::HTMLElement)
    
    # Define CSS selectors for titles, body text, and date stamps
    selectors = Dict(
        "titles" => "title",
        "body" => "p",
        "dates" => "time, .date, .published-date"  # Example selectors for dates
    )
    
    # Extract the text for each selector
    extracted_data = Dict{String, Vector{Any}}()
    
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

    # Now, scrape all table data
    tables = eachmatch(Selector("table"), html_element)
    table_data = []

    for table in tables
        rows = eachmatch(Selector("tr"), table)
        data = [Vector{String}() for _ in 1:length(rows)]
        
        for (i, row) in enumerate(rows)
            cells = eachmatch(Selector("td, th"), row)
            data[i] = [text(cell) for cell in cells]
        end
        
        # Convert table data into a DataFrame
        if !isempty(data) && all(x -> length(x) == length(data[1]), data)
            df = DataFrame([Symbol("col$i") => [row[i] for row in data] for i in 1:length(data[1])])
            push!(table_data, df)
        end
    end

    # Add table data as a list of DataFrames in the extracted_data dictionary
    extracted_data["tables"] = table_data
    
    return extracted_data
end



#### TESTING ####

x = Search.url_search("https://www.bankrate.com/investing/best-performing-stocks/")

parsed = parsehtml(String(x))
y = parsed.root[2]


out = v3scrape_webpage(parsed.root)



println(out["body"])
println(out["titles"])
vscodedisplay(out["tables"][1])





all = version4(input)
print_full_strings(all)

out = extract_pdf(all)
print_full_strings(extract_pdfs(all))


for url in out
    unique_string = generate_unique_string()

    download_pdf(url, "C:\\Users\\Tomi\\Downloads\\New folder\\$unique_string.pdf")
end



out = v2scrape_webpage(input)





#---PDF to Text Testing
pdf_file = "C:\\Users\\Tomi\\Downloads\\New folder\\Resume.pdf"
out = "C:\\Users\\Tomi\\Downloads\\New folder"

#config
using Pkg
Pkg.add("Taro")
using Taro
Taro.init()

## BEWARE OF CHARACTER LIMIT
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

