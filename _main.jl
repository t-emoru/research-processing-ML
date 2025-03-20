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




Extraction.pdfDownload(Extraction.pdfUrls(a)[3])
x, text = Extraction.pdfText("C:\\Users\\Tomi\\Downloads\\Algorthm\\Resume.pdf")

print(text)



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





## Associated Word Generation
# ----------------------------------------


" use GPT API"


## Word Detection and Frequency
# ----------------------------------------

# count occurrences of given string
function count_occurrences(input::Union{String, Vector{String}}, target::String)
    if isa(input, String)
        return count(x -> x == target, split(input))
    elseif isa(input, Vector{String})
        return sum(count_occurrences(str, target) for str in input)
    else
        error("Input must be a string or a list of strings.")
    end
end


# count occurrences of all words in text
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




## TESTING ## 

count_occurrences(x, "neural")
count_words(x)


## Article Qualification: using Tagged Data Strcut





