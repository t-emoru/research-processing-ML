module Extraction
    
    using HTTP, Gumbo
    using HTTP.Cookies
    using AbstractTrees
    using ReadableRegex
    using Cascadia
    using DataFrames
    using CSV
    using Gumbo

    # EXPORT DEFINITIONS
    export extraction_url
    export traverse_and_extract_urls
    export extraction_content
    export extract_company
    export extract_c_rank



    # FUNCTION CONSTANTS


    "TRY COMBINING JSON & Cascadia"

    # FUNCTION DEFINITIONS  

    function extraction_url(body)

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
                println(tag(elem))  #  creates tree
                if tag(elem) == :a
                    push!(raw_URLs, elem)

                    # href = getattr(elem, "href")
                    # push!(dirty_URLs, href)


                end

            catch
                println("error")
            end

        end


        
        return raw_URLs
    end



    # Remanants [use as referenece in redesigning]
    function extraction_content(status, response)

        "
        Function: extracts title data, body data and all tables from html data 
        Returns:
            title data --> list [words, sentences]
            body data --> list [words, sentences]
            tables --> list [datafrmaes...]
    
        "
    
        # Initiatisation Library
        title_sentence = []
        title_word = []
        body_sentence = []
        body_word = []
        table_list = []
        df_list = []
    
    
    
        # Extraction if Access was granted
        if status == 1
    
    
            html_content = String(HTTP.body(response))
    
            ##Packaging Data
            parsed_article = parsehtml(html_content)
    
    
    
            ## Finidng words of Title
            title_sentence = []
            title_word = []
            title_element = eachmatch(Selector("title"), parsed_article.root)
    
            # Words: Split the text into words using whitespace
            for element in title_element
                title = split(text(element), r"\s+")
                append!(title_word, title)
            end
    
            # Sentences: Split the text into words using whitespace
            for element in title_element
                title = split(text(element), r"\.")
                append!(title_sentence, title)
            end
    
    
    
            ## Finding words of Body
            body_sentence = []
            body_word = []
            body_elements = eachmatch(Selector("p"), parsed_article.root)
    
            # Words: Split the text into words using whitespace
            for element in body_elements
                body = split(text(element), r"\s+") # Split the text into words using whitespace
                append!(body_word, body)
            end
    
            # Sentences: Split the text into words using whitespace
            for element in body_elements
                title = split(text(element), r"\.")  # Split the text at full stops
                append!(body_sentence, title)
            end
    
    
    
    
            #-----------------------------------------------------------------------------
            # EXTRACTING TABLES
            #-----------------------------------------------------------------------------
    
    
            ## Finding Tables
            body = parsed_article.root[2]
            table_data_raw = eachmatch(sel"table", body) #returns table data. NOW CLEAN !!
    
    
            #Formatting Rows & Colums
            ntables = length(table_data_raw)
            table_list = []
    
            for i in range(1, ntables)
    
                table = []
    
                rows = eachmatch(sel"tr", table_data_raw[i])
    
                for row in rows
                    cells = []
                    for cell in eachmatch(sel"td", row)
                        push!(cells, nodeText(cell))
                    end
                    push!(table, cells)
                end
    
    
                table = permutedims(table) #columns format
                t_table = permutedims(table) #rows format
    
                # push!(table_list, [])
                push!(table_list, t_table)
    
            end
    
    
            # Creating DataFrame
            for i in range(1, length(table_list))
                table_list[i] = [x for x in table_list[i] if x ≠ []] #removes empty indexes
    
                df = DataFrame(table_list[i], :auto)
                df = permutedims(df)
    
                vscodedisplay(df)
    
                push!(df_list, df)
            end
    
    
    
        else
            println("Access Denied")
        end
    
    
        # Output Organisation
        title_data = [title_word, title_sentence]
        body_data = [body_word, body_sentence]
    
    
    
        return title_data, body_data, df_list
    
    end


    
    function extract_c_rank(rankings)
        "
        Function: produces weighed master ranking from link of companies
        Returns: company master ranking
        
        "
    
    
        "from body Information create list of companies in the order they appear
        Count the number of occurrences of a certain company name 
        Rank all number 1s first then arrange number 1 based on occurrence 
        Then repeat for every rank checking
        make sure there are no repetitions"
    
    
        # -----------------------------------------------------------------------------
        # Number of Occurrences per String
        # -----------------------------------------------------------------------------
    
        # Create an empty dictionary to store counts
        record = Dict{String,Int}()
    
        # Loop through the nested lists and count occurrences
        for sublist in rankings
    
            flattened_list = vcat(sublist...) #flatten list
    
            for item in flattened_list
                if haskey(record, item)
    
                    record[item] += 1
    
                else
                    record[item] = 1
                end
            end
        end
    
    
    
        # -----------------------------------------------------------------------------
        # Company Rankings from Website
        # -----------------------------------------------------------------------------
    
    
    
        # -----------------------------------------------------------------------------
        # Accounting for Website Traffick 
        # -----------------------------------------------------------------------------
    
        "Accounting for Website Traffick
        https://www.similarweb.com/
    
        decide wether to put here or add to url extractoin output!
    
        "
    
    
        # -----------------------------------------------------------------------------
        # Final Evaluation
        # -----------------------------------------------------------------------------
    
    
    
    end
    

    # for commodities screening use AI API
 

end

