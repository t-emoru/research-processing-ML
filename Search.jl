module Search
    
    using HTTP, Gumbo
    using HTTP.Cookies
    using AbstractTrees
    using ReadableRegex
    using Cascadia
    using DataFrames
    using CSV
    using Gumbo
    using JSON
    using Dates

    
    # EXPORT DEFINITIONS
    export URL_search
    export GOOGLE_search
    export STEM_search
    export MEDIA_search
    export prompt_gen
    export request_access
    
    export TaggedData
    export tagged_print


    # RELEVANT OBJECTS 
    mutable struct TaggedData
        data::Any
        created_at::Union{DateTime, Nothing}
        stored_at::DateTime
        other_tags::Dict{String, Any}
    
        # Single Constructor
        function TaggedData(data::Any, created_at::Union{DateTime, Nothing}; other_tags=Dict{String, Any}())
            
            # Potential validation: Ensure created_at is not in the future
            if created_at !== nothing && created_at > now()
                error("created_at cannot be in the future")
            end


            stored_at = now()
            new(data, created_at, stored_at, other_tags)
        end



    end
        
    
    function tagged_print(tagged_data::TaggedData)
        println("TaggedData Details:")
        println("  Data: ", length(string(tagged_data.data)) > 10 ? string(tagged_data.data)[1:10] * "..." : tagged_data.data)
        println("  Created at: ", tagged_data.created_at)
        println("  Stored at: ", tagged_data.stored_at)
        println("  Other tags:")
        for (key, value) in tagged_data.other_tags
            println("    ", key, ": ", value)
        end
    end




    # FUNCTION DEFINITIONS

    function URL_search(query::String)
        return 0
    end

    function GOOGLE_search(query::String, pages::Int=1)
        "
        Function: searches google using default query.
        Return: produces list of hmtl content of search webpages
        
        "

        # Initialize base URL for Google search
        url = "https://www.google.com/search?q=" * query

        # Set up headers to mimic a browser
        headers = Dict("User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3")

        # Set up cookies container
        cookiejar = CookieJar()

        # List to store results from each page
        results = Vector{TaggedData}()

        # Iterate through the specified number of pages
        for page in 0:(pages-1)
            # Calculate the starting result index for each page (Google uses 10 results per page by default)
            start_index = page * 10

            # Set up query parameters for each page
            params = Dict("q" => query, "start" => string(start_index))

            # Send the request for each page
            search_result = HTTP.get(url, query=params, headers=headers, cookies=cookiejar)

            #Create TaggedData instances

            data = TaggedData(search_result, nothing, other_tags=Dict("url" => url))


            # Append the result to the list
            push!(results, data)
        end

        return results

    end


    function STEM_search(query::String, pages::Int=1)

        "
        Function: searches Scientific Paper websites using query.
        Return: produces multilist list of hmtl content of search webpages
        
        "


        # Action Modularization
        function fetch_search_results(w_url, query, start_param, pages)
            url = w_url * query
            headers = Dict("User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3")
            cookiejar = CookieJar()
            results = []

            for page in 0:(pages-1)
                start_index = page * 10
                params = Dict(query => query, start_param => string(start_index))
                search_result = HTTP.get(url, query=params, headers=headers, cookies=cookiejar)
                
                data = TaggedData(search_result, nothing, other_tags=Dict("url" => url))
                push!(results, data)
            end

            return results
        end

        # Google Scholar Search
        google_scholar_url = "https://scholar.google.com/scholar?q="
        google_scholar_results = fetch_search_results(google_scholar_url, query, "start", pages)

        # PubMed Search
        pubmed_url = "https://pubmed.ncbi.nlm.nih.gov/?term="
        pubmed_results = fetch_search_results(pubmed_url, query, "start", pages)

        # Web of Science Search
        wos_url = "https://www.webofscience.com/wos/woscc/basic-search?search_mode=GeneralSearch&SID=XXXX&input_invalid=true&value(input1)="
        wos_results = fetch_search_results(wos_url, query, "start", pages)

        return [google_scholar_results, pubmed_results, wos_results]

    end


    function MEDIA_search(mode::String, query::String, pages::Int=1, limit::Int=25)

        "
        Function: takes in query (company) and searches Social Media & Media Outlets platforms 
        Return: produces list of html content from each platform

        *** CURRENT VERSION: only REDDIT Call
        
        "
        #--------Reddit-----------------
            "
            API Rules and Authentication: For more complex interactions or higher volume requests, 
            you should use authenticated API requests as per Reddit's API guidelines. 
            This might require registering your script as an application on Reddit to obtain an API key.
        
            "
        
            ## Returns REDDIT Search [STRING]
        
            # Combined function for Reddit operations
            # Query = search query and name of subreddit determining on mode
            # Search = returns an Array of TAGGED HTML Content
            # Posts = returns an Array of TAGGED Dicts Content
    
        function REDDIT(mode::String, query::String, pages::Int=1, limit::Int=25)
            
            user_agent = "Mozilla/5.0 (Julia script; combined Reddit functionality)"
            headers = Dict("User-Agent" => user_agent)
        
            if mode == "search"
                # Functionality for searching Reddit
                base_url = "https://www.reddit.com/search/?q="
                results = []
                
                for page in 1:pages
                    url = "$(base_url)$(HTTP.escapeuri(query))&page=$(page)"
                    response = HTTP.get(url, headers=headers)
                    
                    if HTTP.status(response) == 200
                        parsed_html = Gumbo.parsehtml(String(response.body))
                        data = TaggedData(parsed_html, nothing, other_tags=Dict("url" => url))

                        push!(results, data)
                    else
                        println("Failed to fetch the page: Status code ", HTTP.status(response))
                    end
                end
        
                return results
                
            # QUERY MUST BE A SUBREDDIT
            elseif mode == "posts"
                encoded_query = HTTP.escapeuri(query)
                url = "https://www.reddit.com/r/$(encoded_query)/new.json?limit=$(limit)"
                response = HTTP.get(url, headers=headers)
                post_details = []

                if HTTP.status(response) == 200
                    json_response = JSON.parse(String(response.body))

                    for post in json_response["data"]["children"]
                        post_data = post["data"]
                        title = post_data["title"]
                        url = post_data["url"]
                        permalink = "https://www.reddit.com" * post_data["permalink"]
                        
                        post_info = Dict("title" => title, "url" => url, "permalink" => permalink)
                        data = TaggedData(post_info, nothing, other_tags=Dict("url" => url))
                        push!(post_details, data)
                    end
                else
                    println("Failed to fetch posts: Status code ", HTTP.status(response))
                end

                return post_details

            else
                println("Invalid mode. Please choose 'search' or 'posts'.")
            end
        end

        
        return REDDIT(mode, query, pages, limit)
    
        #--------Twitter--------------------------------------
    
        #--------Direct Outlets(Yahoo Finance)----------------
    
        # HOLD OFF ON DEVELOPMENT TO PREVENT IP BAN [start work on Level 3]

    end
    
    

    function request_access(urls, link)
        "
        Function: request to access html data of link
        Returns: Status (1 meaning Yes) and Response (contains html data)
        "
    
    
        subject = urls[link]
        response = HTTP.request("GET", subject)
    
    
        #check is request was successful
        if HTTP.status(response) == 200
            status = 1
        else
            println("Failed to access the website. Status code: ", HTTP.status(response))
        end
    
    
        return status, response
    end
    
  
    #Functions for Financial Data Search

   
end



