module Extraction
    
    using HTTP, Gumbo
    using HTTP.Cookies
    using AbstractTrees
    using ReadableRegex
    using Cascadia
    using DataFrames
    using CSV
    using Gumbo
    using Random
    using Downloads
    using DataFrames
    using Dates
    using Taro


    # EXPORT DEFINITIONS
    export urls_general
    export urls_google
    export pdfUrls
    export pdfDownload
    export pdfText
    export scrape_webpage



    # FUNCTION CONSTANTS


    # FUNCTION DEFINITIONS  

    "returns valid urls for webpages"
    function urls_general(body::HTMLElement)
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

    "returns urls for google search"
    function urls_google(body::HTMLElement)
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

    "returns pdf urls"
    function pdfUrls(links::Vector{Any})
        return filter(link -> occursin("pdf", link), links)
    end
    
    "downloads pdfs"
    function pdfDownload(url::String, save_path::String = "C:\\Users\\Tomi\\Downloads\\Algorthm\\Resume.pdf")
        # CHANGE to defult to user's download folder not just yours
        # Save_path generated using code function in analysis

        try
            # Download the file and save it to the specified path
            Downloads.download(url, save_path)
            println("PDF downloaded successfully to $save_path")
        catch e
            println("Failed to download the PDF: $e")
        end
    end

    "converts pdfs to text"
    function pdfText(pdf_file::String)
    
        try
            Taro.init()
        
        catch
            print("Already Initialized")
        end 
        
        meta, text = Taro.extract(pdf_file);
        return meta, text
    
    end 
    
    "returns title, body, table and date data from webpage"
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


    

    ## development stages ##
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

    "returns only relevnat urls - /url?esrc=s&"
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
 
    "returns only title, body and date"
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

end

