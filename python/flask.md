# flask point

## 错误处理

### 注册

注册errorhandler,处理程序返回的自定义exception,两种注册方式
errorhandler(code_or_exception)

```python
@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404
```

```python
def internal_error(e):
    return render_template('500.html'), 500
app.register_error_handler(Exception, internal_error)
```

### 抛出

对于状态码，直接通过flask的abort(code)方法进行异常抛出；
对于exception，在代码中raise 对应的Exception.
flask程序会到

```python
@app.route('/404')
def r_404():
    # 通过flask的abort接口返回404的结果
    abort(404)

@app.route('/500')
def r_500():
    # 抛出异常给errorhandler捕获处理
    raise Exception
```