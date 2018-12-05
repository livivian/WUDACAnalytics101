#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 21 14:30:03 2018

@author: Max Roling
"""

import pandas as pd
from statsmodels.tsa.ar_model import AR
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split
import matplotlib.pylab as plt

#read csv, create month variable
gas = pd.read_csv('RSGASSN.csv')
gas['DATE'] = pd.to_datetime(gas['DATE'], format = '%Y-%m-%d')
gas['month'] = gas['DATE'].dt.month
gas = gas.head(100)

#create new dummy variables for each month, labeled "1" if that datapoint is in that month
months = pd.get_dummies(gas['month']).rename(columns=lambda x: 'month_' + str(x))
gas = pd.concat([gas, months], axis=1)

#create time and time^2 counters
gas = gas.drop(columns=['DATE', 'month'])
gas['time'] = pd.Series(list(range(1, len(gas) + 1)))
gas['time_2'] = gas['time']**2

plt.plot(gas['RSGASSN'])
plt.show()


#%%



#build a basic lagged model
labels = gas.pop('RSGASSN')
X_train, X_test, y_train, y_test = train_test_split(gas, labels, test_size=.25, shuffle=False)

model = AR(y_train)
model = model.fit()

print('Lag: ' + str(model.k_ar))
print('Coefficients: ' + str(model.params))

predictions = model.predict(start = len(y_train), end = len(gas) - 1)


plt.plot(y_test)
plt.plot(predictions, color='red')
plt.show()

#%%



#now build a lagged model usng all features
from statsmodels.tsa.vector_ar.var_model import VAR

gas = pd.concat([gas,labels], axis = 1)

model = VAR(endog = gas[:75])
model = model.fit()

print('Lag: ' + str(model.k_ar))
print('Coefficients: ' + str(model.params))

predictions = pd.DataFrame(model.forecast(model.y, steps = 25))

#predictions gets predictions for every row, we just want the last row with RSGASSN variable
predicted_prices = predictions[14]
plt.plot(y_test.reset_index(), color = 'blue')
plt.plot(predicted_prices, color='red')
plt.show()


