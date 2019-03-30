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