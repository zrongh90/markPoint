# auth token设计

## 引入itsdangerous

```python
from itsdangerous import JSONWebSignatureSerializer as UnExpiredSerializer
from itsdangerous import TimedJSONWebSignatureSerializer as ExpiredSerializer
from itsdangerous import SignatureExpired, BadSignature
```

## 设置token

```python
# 使用会超时的token
s_obj = ExpiredSerializer(app.config['SECRET_KEY'], expires_in=6000)
s_obj.dumps({'user_id': user_id})
# 使用不会超时的token
s_obj = UnExpiredSerializer(app.config['SECRET_KEY'])
s_obj.dumps({'user_id': user_id})
```

## 验证token

```python
    try:
        in_user_id = s_obj.loads(token)['user_id']
    except SignatureExpired:
        # 如果token过期，将认证失败
        return False
    except BadSignature:
        return False
    else:
        # 如果token未过期，则进行用户的认证
        pass
```
