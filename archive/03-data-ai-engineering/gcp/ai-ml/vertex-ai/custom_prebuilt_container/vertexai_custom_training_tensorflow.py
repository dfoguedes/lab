#!/usr/bin/env python
# coding: utf-8

# In[1]:


import tensorflow
import keras
print(keras.__version__)
print(tensorflow.__version__)


# In[16]:


from keras.models import Sequential
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import KFold
import numpy as np
import pandas as pd
np.random.seed(7)
df = pd.read_csv("gs://vertexai-storage11/IRIS.csv")


# In[3]:


df


# In[4]:


X = df.drop(["species"],axis=1) # species is what im trying to predict
Y = df['species'].map({'Iris-setosa': 0, 'Iris-versicolor': 1, 'Iris-virginica': 2}) # converts the names into numbers
Y


# In[ ]:


encoder = LabelEncoder()
encoder.fit(Y)
encoded_Y = encoder.transform(Y)
classes_y = keras.utils.to_categorical(Y) # convert to binary vectors
# classes_y creates classes , for later we have the capability to multi classify using our model


# In[22]:


model = Sequential()
model.add(keras.layers.Dense(8,activation='relu'))
model.add(keras.layers.Dense(3,activation='softmax'))
model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])


# In[ ]:


model.fit(X, classes_y, epochs=150, batch_size=5) # epochs means, you will train the model 150 times.


# In[26]:


scores = model.evaluate(X, classes_y)


# In[27]:


predictions = model.predict(X)


# In[30]:


test = np.argmax(predictions,axis=1)
test


# In[ ]:


model.save('gs://vertexai-storage11/model_output')

