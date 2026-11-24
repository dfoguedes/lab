#!/usr/bin/env python
# coding: utf-8

# ### 1. Import to Cloud storage the data from local file system (Iris dataset)
# 

# ### 2. Create a workbench instance in Vertex AI or local instance with Vertex AI SDK installed
# 
# if locally run in shell :
# 
# `conda activate <env_name>`
# 

# In[6]:


import pandas as pd
import os


# In[4]:


pd.__version__


# In[9]:


df = pd.read_csv("gs://vertexai-storage11/IRIS.csv")


# In[4]:


df


# In[ ]:


from sklearn.model_selection import train_test_split
array = df.values

# Inspect DataFrame and array to determine correct slicing
print("DataFrame shape (rows, cols):", df.shape)
print("Array shape (rows, cols):", array.shape)
num_cols = df.shape[1]
print(f"Total columns: {num_cols}")
print(f"Feature columns are 0 to {num_cols-2}, label column is {num_cols-1}")

X = array[:, :4]
y = array[:, 4]


# Split the data into train and test sets (X inputs, y outputs)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.20, random_state=1
)


# In[21]:


X_train.shape # 120 , because we allocated a test size of 20%, which means 150*0.20 = 30 (150-30=120)


# In[22]:


X_test.shape


# In[31]:


from sklearn.svm import SVC
# Choosed SVC because works well in a small-medium tabular dataset with only 4 features. 

svn = SVC()
svn.fit(X_train,y_train)
predictions = svn.predict(X_test)
predictions


# In[ ]:


from sklearn.metrics import accuracy_score
accuracy_score(y_test,predictions)


# In[33]:


# Dump model file

# import pickle
# import logging

# with open("model.pkl",'wb') as model_f:
#      pickle.dump(svn,model_f) 


# In[42]:


# Upload model to bucket (Commented for now)
# from google.cloud import storage
# bucket_name = "vertexai-storage11"
# model_name = "model.pkl"
# storage_client = storage.Client()
# storage_bucket = storage_client.bucket(bucket_name=bucket_name)
# storage_bucket.blob(model_name).upload_from_filename(model_name)


# ### Convert jupyter notebook to python script
# 
# `jupyter nbconvert vertexai_custom_training.ipynb --to python`
# 

# 
