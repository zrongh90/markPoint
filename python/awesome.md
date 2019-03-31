# 常用的库

## 环境类

### [python-dotenv](https://github.com/theskumar/python-dotenv)

Reads the key,value pair from .env file and adds them to environment variable.

pip安装

```python
pip install python-dotenv
```

新建`.env`文件

```config
SECRET_KEY='1234'
REDIS_URL='http://localhost:6379'
```

py文件中使用

```python
import os
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'))
```

## 数据库类

### peewee

## 认证类

### [itsdangrous](https://pythonhosted.org/itsdangerous/)

Given a key only you know, you can cryptographically sign your data and hand it over to someone else. When you get the data back you can easily ensure that nobody tampered with it.

#### 签名

- Signer
- TimestampSigner

#### 序列化

- 不带超时时间：
  - URLSafeSerializer
  - JSONWebSignatureSerializer

- 带超时时间
  - URLSafeTimedSerializer
  - TimedJSONWebSignatureSerializer

#### 异常

- BadSignature
- SignatureExpired

#### 用法

```python
from itsdangerous import URLSafeSerializer
secert_key = 'you_secert_key'
s = URLSafeSerializer(secert_key)
res.dumps(40)
Out[23]: 'NDA.j_6pYeAR-uDtZRoLhLPwpP7oI90'
res.loads('NDA.j_6pYeAR-uDtZRoLhLPwpP7oI90')
Out[24]: 40
```
