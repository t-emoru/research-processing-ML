module Analysis
    
    """Leave here for now, can be pushed to
    designed SETUP FILE """

    using Pkg   
    using TextAnalysis
    using TextAnalysis: NaiveBayesClassifier, fit!, predict
    using DataFrames
    using CSV
    using Random
    using Serialization
    using Dates


    ## ORGANISE
    #-----------------------------------------------------------------------
    ## Cleaning & Dataset Diviison
    #-----------------------------------------------------------------------


    function sentiment_data_cleaning(list)

        for i in 1:length(list)
            
            sd = StringDocument(list[i])
            
            remove_corrupt_utf8!(sd)
            
            # Convert to lowercase
            remove_case!(sd)
    
            # Remove URLs and user mentions
            prepare!(sd, strip_html_tags)
    
            # Remove punctuation and special characters, keeping words and spaces
            prepare!(sd, strip_punctuation)
    
            # Remove stop words**
            #prepare!(sd, strip_stopwords)
            prepare!(sd, strip_pronouns)
    

            list[i] = text(sd)
        end
    end

    
    function gen_path_string(length::Int = 5)
        chars = ['A':'Z'; 'a':'z'; '0':'9']  # Character set (uppercase, lowercase, digits)
        return join(rand(chars, length))
    end
    


    #-----------------------------------------------------------------------
    ## Training
    #-----------------------------------------------------------------------



    function semantic_training(model, positive, negative, neutral, pos_num::Int, neg_num::Int, neu_num::Int, classes::Int)
        
        
        if classes == 2  # no neutral
            for i in positive[1:pos_num]
                fit!(model, i, :positive)
            end

            for i in negative[1:neg_num]
                fit!(model, i, :negative)
            end
        elseif classes == 3  # include neutral
            for i in positive[1:pos_num]
                fit!(model, i, :positive)
            end

            for i in negative[1:neg_num]
                fit!(model, i, :negative)
            end

            for i in neutral[1:neu_num]
                fit!(model, i, :neutral)
            end
        end


    end


    #-----------------------------------------------------------------------
    ## Benchmarking
    #-----------------------------------------------------------------------


    function test_model_accuracy(model, pos_test, neg_test, neu_test)
        # Counters for correct predictions
        correct_pos = 0
        correct_neg = 0
        correct_neu = 0
    
        # Test positive instances
        for text in pos_test
            #println(pos_test[text])
            prediction = predict(model, text)
            if argmax(prediction) == :positive
                correct_pos += 1
            end
        end
    
        # Test negative instances
        for text in neg_test
            prediction = predict(model, text)
            if argmax(prediction) == :negative
                correct_neg += 1
            end
        end
    
        # Test neutral instances
        for text in neu_test
            prediction = predict(model, text)
            if argmax(prediction) == :neutral
                correct_neu += 1
            end
        end
    
        # Total number of test instances
        total_test = length(pos_test) + length(neg_test) + length(neu_test)
    
        # Calculate accuracy
        total_correct = correct_pos + correct_neg + correct_neu
        accuracy = total_correct / total_test
    
        return accuracy
    end
    
    ## accuracy test for 2 classes
    function test_model_accuracy1(model, pos_test, neg_test)
        # Counters for correct predictions
        correct_pos = 0
        correct_neg = 0
    
        # Test positive instances
        for text in pos_test
            #println(pos_test[text])
            prediction = predict(model, text)
            if argmax(prediction) == :positive
                correct_pos += 1
            end
        end
    
        # Test negative instances
        for text in neg_test
            prediction = predict(model, text)
            if argmax(prediction) == :negative
                correct_neg += 1
            end
        end
    
    
        # Total number of test instances
        total_test = length(pos_test) + length(neg_test)
    
        # Calculate accuracy
        total_correct = correct_pos + correct_neg
        accuracy = total_correct / total_test
    
        return accuracy
    end

    #-----------------------------------------------------------------------
    ## Saving & Loading
    #-----------------------------------------------------------------------


    
    function save_model(model, model_name)
        # Create the file path based on the model_name
        save_path = "C:\\Users\\Tomi\\Documents\\_School & Exams\\_University\\Education & Classes\\_Coop\\Predictive Algorithm\\Machine Learning\\stock-trading-ML\\storage\\$(model_name).dat"
    
        # Check if the file already exists and throw an error if it does
        if isfile(save_path)
            error("Model file for '$model_name' already exists.")
        else
            # Serialize and save the model
            open(save_path, "w") do file
                serialize(file, model)
            end
        end
    end


    function load_model(model_name::String)
        # Construct the file path based on the model name
        ### CHANGE PATH BASED ON USER?
        load_path = "C:\\Users\\Tomi\\Documents\\_School & Exams\\_University\\Education & Classes\\_Coop\\Predictive Algorithm\\Machine Learning\\stock-trading-ML\\storage\\$(model_name).dat"

        # Check if the file exists
        if isfile(load_path)
            # Deserialize and load the model
            return open(deserialize, load_path)
        else
            error("Model file for '$model_name' does not exist.")
        end
    end





 
end



