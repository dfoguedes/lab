 -- BigQuery ML: Iris Dataset Model Creation
 -- Create bqml_tutorial dataset

 
SELECT

  *

FROM

  `bigquery-public-data.ml_datasets.iris`

-- Create the dataset if it does not exist
CREATE OR REPLACE MODEL

  `bqml_tutorial.irisdata_model`

OPTIONS

  ( model_type='LOGISTIC_REG', -- aglorithm to use for classification

    auto_class_weights=TRUE, -- automatically compute class weights

    data_split_method='NO_SPLIT', -- do not split into train and test data, use the entire dataset

    input_label_cols=['species'], -- the column we want to predict

    max_iterations=10) AS

SELECT

  *

FROM

  `bigquery-public-data.ml_datasets.iris`



---  -- Evaluate the model using the same dataset

  SELECT * FROM ML.EVALUATE(MODEL bqml_tutorial.irisdata_model,

   (

SELECT

*

FROM `bigquery-public-data.ml_datasets.iris`)) -- evaluate the model on the same dataset 

-- predict using the model 

select * from ML.PREDICT(MODEL bqml_tutorial.irisdata_model, (SELECT

5.1 as sepal_length,

2.5 as petal_length,

3.0 as petal_width,

1.1 as sepal_width))


