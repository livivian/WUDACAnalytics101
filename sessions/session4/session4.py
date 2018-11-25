#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 22 00:02:11 2018

@author: Max Roling
"""

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import confusion_matrix
from sklearn.metrics import mean_squared_error as MSE
#from sklearn import *

data = pd.read_csv('data_session4.csv')
data = data[data['intent'].isin(["Accident", "Suicide", "Homicide"])] #remove all other forms of death besides these three
data = data.drop(columns = ['Unnamed: 0'])


#Create new datafrane df; convert categorical vars to "dummy" numerical variables
df = pd.DataFrame()
df['month'] = data['month']
df['intent'] = data['intent'].astype('category').cat.codes
df['sex'] = data['sex'].astype('category').cat.codes # 0 = F, 1 = M
df['age'] = data['age'].astype('category').cat.codes
df['race'] = data['race'].astype('category').cat.codes
df['education'] = data['education'].astype('category').cat.codes
df['outside_factor'] = data['outside_factor'].astype('category').cat.codes


#prepare data for modeling - split into training and testing sets
labels = df.pop('sex')
X_train, X_test, y_train, y_test = train_test_split(df, labels, test_size=.25, shuffle=False)

#First try: Logistic regression!
logistic = LogisticRegression()
logistic.fit(X_train, y_train)
logistic_predictions = logistic.predict(X_test)
logistic_score = logistic.score(X_test, y_test)
print('Logistic regression r^2: ' + str(logistic_score))
print('Logistic regression Mean Squared Error: ' + str(MSE(y_test, logistic_predictions)))
#view confusion matrix
print(confusion_matrix(y_test, logistic_predictions))


#%%

#second try: Random forests

from sklearn.ensemble import RandomForestClassifier as RFC
rf = RFC(n_estimators=25) #try different numbers of trees and see what happens!
rf.fit(X_train, y_train)

rf_predictions = rf.predict(X_test)
rf_score = rf.score(X_test, y_test)

print('Random Forest r^2: ' + str(rf_score))
print('Random Forest Mean Squared Error: ' + str(MSE(y_test, rf_predictions)))
#view confusion matrix
print(confusion_matrix(y_test, rf_predictions))

#Random forests are also neat because they can determine which variables are most important in making a prediction:

feature_list = df.columns
feature_importances = rf.feature_importances_

importances = pd.DataFrame()
importances['feature'] = feature_list
importances['importance'] = feature_importances

print(importances)

#we find that age is the most important determining factor in predicting gender!




