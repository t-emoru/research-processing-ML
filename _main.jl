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
using TextAnalysis
using JSON3


#-------------------------------------------------------------------------------
# current testing block from old file
#-------------------------------------------------------------------------------


function print_full_strings(strings::Vector{Any})
    for str in strings
        println(str)
    end
end


x = Search.url_search("https://finance.yahoo.com/markets/stocks/gainers/")
parsed = parsehtml(String(x))
input = parsed.root
out = Extraction.scrape_webpage(input)




a = Extraction.urls_general(input)
a = Extraction.version3(input)
print_full_strings(Extraction.pdfUrls(a))

print_full_strings(a)

print_full_strings(out["body"])
out["tables"]
vscodedisplay(out["tables"][3])
println(parsed)




## Semantic Processing
# ----------------------------------------

# lowercase
# remove urls 
# replace "\n" with whitespace
# whitespace inbtween punctuationn


## look at this...
function clean_text(input::String)
    # Step 1: Store and remove all URLs
    url_pattern = r"http[s]?://[^\s]+"
    cleaned_input = replace(input, url_pattern => "")

    # Step 2: Replace all newlines ("\n") with whitespace
    cleaned_input = replace(cleaned_input, "\n" => " ")


    # Step 3: Insert spaces before and after any punctuation
    punctuation_pattern = r"([.,!?;:])"  # This pattern matches common punctuation
    cleaned_input = replace(cleaned_input, punctuation_pattern => s" \1 ")

    # Step 4: Convert all words to lowercase
    cleaned_input = lowercase(cleaned_input)

    # Step 5: Remove extra spaces created from replacement (optional)
    # cleaned_input = replace(cleaned_input, r"\s+" => " ")


    return cleaned_input
end


x = clean_text(text)
print(x)
print(text) # contains urls






# ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------


function chat_with_openai(prompt::String)
    api_key = get(ENV, "OPENAI_API_KEY", nothing)

    if api_key === nothing
        error("OPENAI_API_KEY is not set. Please set it before running this script.")
    end
    
    url = "https://api.openai.com/v1/chat/completions"

    body = Dict(
        "model" => "gpt-3.5-turbo",
        "messages" => [
            Dict("role" => "system", "content" => "You are a helpful assistant."),
            Dict("role" => "user", "content" => prompt)
        ]
    )

    res = HTTP.post(url,
        ["Authorization" => "Bearer $api_key",
         "Content-Type" => "application/json"],
        JSON3.write(body))

    parsed = JSON3.read(String(res.body))
    return parsed.choices[1].message.content
end

chat_with_openai("hello")

x, text = Extraction.pdfText("C:\\Users\\Tomi\\Downloads\\Research_Papers\\s40303-015-0010-8.pdf")

typeof(text)


"BUILD POOL OF RESEARCH PAPERS"
#####------------------------------------------------
## Items of Data Required

# Metadata Analysis [no LLM]
function extract_pdf_metadata(meta::Dict{String, String})
    return Dict(
        "Title" => get(meta, "dc:title", get(meta, "title", "N/A")),
        "Author" => get(meta, "Author", get(meta, "meta:author", "N/A")),
        "Last Modified" => get(meta, "Last-Modified", get(meta, "pdf:docinfo:modified", "N/A")),
        "Page Count" => get(meta, "xmpTPg:NPages", "N/A"),
        "Publishing Website" => get(meta, "pdf:docinfo:custom:CrossMarkDomains[1]", 
                              get(meta, "pdf:docinfo:custom:CrossMarkDomainExclusive", "N/A"))
    )
end
extract_pdf_metadata(x)


# Number of Citations [variable]
"may require switching scraping approach to API"




# Associated Keywords [LLM]
function get_associated_words(word::String)
    prompt = """
    Act as a word association engine. Given a single input word, return a Julia array of commonly associated terms and short phrases (e.g., co-occurring ideas, functions, tools, fields, use cases). Avoid simple synonyms.

    Respond only with the Julia array of strings, formatted like this: ["item1", "item2", "item3", ...].

    Input word: "$word"
    Output:
    """

    response_str = chat_with_openai(prompt)
    words = collect(JSON3.read(response_str))
    return words
end
p = get_associated_words("robotics")



# Keyword Frequency [no LLM]
#----------count occurrences of given string
function count_occurrences(input::Union{String, Vector{String}}, target::String)
    if isa(input, String)
        return count(x -> x == target, split(input))
    elseif isa(input, Vector{String})
        return sum(count_occurrences(str, target) for str in input)
    else
        error("Input must be a string or a list of strings.")
    end
end
#----------count occurrences of all words in text
function count_words(input::String)
    word_counts = Dict{String, Int64}()
    words = split(lowercase(input), r"\W+")

    for word in words
        if haskey(word_counts, word)
            word_counts[word] += 1
        else
            word_counts[word] = 1
        end
    end
    return word_counts
end





# Topic Modelling [LLM]
 


# Base Relevance Score [no LLM]: score based on frequency and meta data



#####------------------------------------------------
## Trend Analysis

""" Citation Network [varaible]: based on lists of citations from different papapers works can be mapped to one 
another. 

"""


""" Gap Identification [LLM]: program is given uncommon words, generates vertically associated words and 
searches for related article in network (and actively checks in current seraches)
"""

""" Relevance Score [varaible]: combines all scoring metrics

"""









## Word Detection and Frequency
# ----------------------------------------





## TESTING ## 

count_occurrences(x, "neural")
count_words(x)


## Article Qualification: using Tagged Data Strcut





