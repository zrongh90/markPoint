import numpy as np
import pandas as pd
from datetime import datetime

s = pd.Series([i for i in range(5)], index=['a','b','c','d', 'e'])

s = pd.Series([-1.21231, -2.123123, 4.123123,124.123,123.1231],index=['a','b','c','d', 'e'], dtype='int8')

s = pd.Series(np.random.randn(5), index=[i for i in 'abcde'])

s = pd.Series({'a':1, 'b':2, 'c': 3}, index=[i for i in 'abcde'])
#s = pd.Series(5, index=[i for i in 'ubcde'])

#print(s.values)
#print(s.index)
#print(s['a'])
#print(s[['a', 'b']])
#print(s[:2])

#df = pd.DataFrame({'one': [i for i in range(5)], 'two': [j for j in range(5,10)]})
#print(df)

data = np.zeros((2,), dtype=[('A', 'i4'), ('B', 'f4'), ('C', 'a10')])
data[:] = [(1,2.,'hello'), (2,3.,'world')]

df = pd.DataFrame(data, index=['first', 'second'], columns=['C', 'A', 'B'])


# 以series组成字典创建dataframe

data = {
    'one': pd.Series([i for i in range(3)], index=[j for j in 'abc']),
    'two': pd.Series([i for i in range(4)], index=[j for j in 'abcd'])
}

df = pd.DataFrame(data, index=['c', 'b', 'a'], columns=['two', 'one'])

# 以字典的形式创建dataframe

data = [{'a': 1, 'b':2}, {'a':5, 'b':10, 'c':20}]
df = pd.DataFrame(data, index=['first', 'second'], columns=['a', 'b'])
#print(df[0:1])
#print('*' * 20)
#print(df)
#print('*' * 20)
#print(df.loc[['first'], ['b']])
#print('*' * 20)
#print(df.iloc[0:2,0:1])
#print('*' * 20)
#print(df.ix[df.a > 1,:])


# 以字典的字典形式创建dataframe
data = {
    ('a', 'b'): {('A', 'B'): 1, ('A', 'C'): 2},
    ('a', 'a'): {('A', 'C'): 3, ('A', 'B'): 4},
    ('a', 'c'): {('A', 'B'): 6, ('A', 'C'): 1},
    ('b', 'a'): {('A', 'B'): 8, ('A', 'C'): 7},
    ('b', 'b'): {('A', 'B'): 10, ('A', 'D'): 9}
}
df = pd.DataFrame(data)
import datetime
from pandas_datareader.data import get_data_yahoo,get_dailysummary_iex
print(get_data_yahoo('000001.SS'))