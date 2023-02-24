from flask import Flask

app = Flask(__name__)

@app.route('/')

def index():
    return "Test message. The server is running"

@app.route('/h')
def hello_func():
    return 'hello!'

if __name__ == '__main__':

    # app.run('localhost', 5000)
    app.run('127.0.0.1', 5000)
