from flask import Flask, request, jsonify
import datetime
import pickle
import numpy as np

with open('./models/model_task_7_6.pkl', 'rb') as pkl_file:
    model = pickle.load(pkl_file)

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

# Задание 7.6
# Используя только что обретённые знания, напишите Flask-приложение, которое по эндпоинту /predict
# будет слушать POST-запросы на предсказания.
# В теле POST-запроса — список из четырёх чисел в формате JSON (один объект, четыре признака)
# Так как на вход модели необходимо подать numpy-массив определённой размерности, а не список, не забудьте
# перевести результат в тип np.array() и скорректировать его под размер (1, 4) с помощью reshape()
# Ответом на запрос должен быть JSON-формат {"prediction": *число - предсказание модели*}.
@app.route('/predict', methods=['POST'])
def predict():
    features = np.array(request.json)
    features = features.reshape(1, 4)
    prediction = model.predict(features)
    return  jsonify({'prediction': prediction[0]})




# ======================================================================================
if __name__ == '__main__':

    # app.run('localhost', 5000)
    app.run('127.0.0.1', 5000)

