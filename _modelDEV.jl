"CONVERT THIS PREVIOUS CODE INTO A BACKGROUND FILE THAT RUNS CONTINOUSLY TRYING TO INCREASE ACCURACY"


cd("C:\\Users\\Tomi\\Documents\\_School & Exams\\_University\\Education & Classes\\_Coop\\Predictive Algorithm\\Machine Learning\\stock-trading-ML\\data")

using Pkg
Pkg.add("TextAnalysis")


using TextAnalysis
using TextAnalysis: NaiveBayesClassifier, fit!, predict
using DataFrames
using CSV
using Random
using Serialization
using Dates


"""Remove after Final Model has been created and saved """
#-----------------------------------------------------------------------
## Initialisations
#-----------------------------------------------------------------------

classes1 = [:positive, :negative]
classes2 = [:positive, :negative, :neutral]

# Base Model

## Varaition Tests
# with Neutral
model_1 = NaiveBayesClassifier(classes2) # Total [Neutral] Dataset 
model_3 = NaiveBayesClassifier(classes2) # 1500 Dataset

# without Neutral
model_4 = NaiveBayesClassifier(classes1) # Total Dataset [800K] 
model_5 = NaiveBayesClassifier(classes1) # [400K]
model_6 = NaiveBayesClassifier(classes1) # [100K]


#-----------------------------------------------------------------------
## Loading Data
#-----------------------------------------------------------------------

###--Training Data 1--
file_1 = "stock_data.csv"
df_1 = DataFrame(CSV.File(file_1))

# vscodedisplay(df_1)

negative_1 = filter(row -> row.Sentiment == -1, df_1)[!, :Text]
positive_1 = filter(row -> row.Sentiment == 1, df_1)[!, :Text]



###--Training Data 2--
file_2 = "data.csv"
df_2 = DataFrame(CSV.File(file_2))
# vscodedisplay(df_2)

negative_2 = filter(row -> row.Sentiment == "negative", df_2)[!, :Sentence]
positive_2 = filter(row -> row.Sentiment == "positive", df_2)[!, :Sentence]
neutral_2 = filter(row -> row.Sentiment == "neutral", df_2)[!, :Sentence]


###--Training Data 3--
file_3 = "tweet_data.csv"
df_3 = DataFrame(CSV.File(file_3))
# vscodedisplay(df_3)


negative_3 = filter(row -> row.Sentiment == 0, df_3)[!, :Sentence]
positive_3 = filter(row -> row.Sentiment == 4, df_3)[!, :Sentence]

# how does vcat work? if it doesnt shuffle shuffle
positive = vcat(positive_1, positive_2, positive_3)
negative = vcat(negative_1, negative_2, negative_3)
neutral = vcat(neutral_2)



#-----------------------------------------------------------------------
## Cleaning & Dataset Diviison
#-----------------------------------------------------------------------


function semantic_cleaning(list)

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


semantic_cleaning(positive)
semantic_cleaning(negative)
semantic_cleaning(neutral)

# Shuffle Datasets Contents

shuffle!(positive)
shuffle!(negative)
shuffle!(neutral)

# Split into Testing and Training [60:40]

pos_train = positive[1:600000]
pos_test = positive[600000:length(positive)]


neg_train = negative[1:600000]
neg_test = negative[600000:length(negative)]

neu_train = neutral[1:1500]
neu_test = neutral[1500:length(neutral)]



    #-----------------------------------------------------------------------
    ## Training
    #-----------------------------------------------------------------------


    ## Modularise this process into a function that 
    # Based Model

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


    # Benchmarking

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
    
    ## accuracy test wrong doesnt account for no neutral [last 3]

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


    # Example usage:
    accuracy1 = test_model_accuracy(model_1, pos_test, neg_test, neu_test)
    accuracy3 = test_model_accuracy(model_3, pos_test, neg_test, neu_test)

    accuracy4 = test_model_accuracy1(model_4, pos_test, neg_test)
    accuracy5 = test_model_accuracy1(model_5, pos_test, neg_test)
    accuracy6 = test_model_accuracy1(model_6, pos_test, neg_test)
    

    prediction = predict(model_1, "today was cool")

    ## SAVE MODELS


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
        load_path = "C:\\Users\\Tomi\\Documents\\_School & Exams\\_University\\Education & Classes\\_Coop\\Predictive Algorithm\\Machine Learning\\stock-trading-ML\\storage\\$(model_name).dat"

        # Check if the file exists
        if isfile(load_path)
            # Deserialize and load the model
            return open(deserialize, load_path)
        else
            error("Model file for '$model_name' does not exist.")
        end
    end

    
    save_model(model_1, "model_1")
    save_model(model_3, "model_3")
    save_model(model_4, "model_4")
    save_model(model_5, "model_5")
    save_model(model_6, "model_6")
