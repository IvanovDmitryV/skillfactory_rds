from flask import Flask, request, jsonify
import datetime

app = Flask(__name__)

@app.route('/hello')
def hello_func():
    name = request.args.get('name')
    return f'hello, {name}!'

# Задание 7.3
# Напишите новую функцию index(), которая будет возвращать строку "Test message. The server is running".
# Оберните эту функцию в декоратор app.route(), указав в качестве эндпоинта '/'. Данный эндпоинт будет
# соответствовать обращению к сайту по дефолтному адресу: http://localhost:5000/.
@app.route('/')
def index():
    return "Test message. The server is running"

# Задание 7.4
# Напишите функцию current_time, которая будет возвращать словарь, где ключ — 'time',
# а значение — текущее время.
# Оберните эту функцию в декоратор app.route() с эндпоинтом /time.
@app.route('/time')
def current_time():
    now = datetime.datetime.now()
    return {'time': now}
# ===
@app.route('/add', methods=['POST'])
def add():
    num = request.json.get('num')
    if num > 10:
        return 'too much', 400
    return jsonify({
        'result': num + 1
    })

# ======================================================================================
if __name__ == '__main__':

    # app.run('localhost', 5000)
    app.run('127.0.0.1', 5000)

