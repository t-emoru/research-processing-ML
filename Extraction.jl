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



    # FUNCTION CONSTANTS
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



    # FUNCTION DEFINITIONS  


    

    ## function stages

    "returns all URLS" 
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

    "retuens only relevnat urls - /url?esrc=s&"
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
 

end

