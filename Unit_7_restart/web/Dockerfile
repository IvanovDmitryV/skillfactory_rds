# FROM python:3.8
# WORKDIR /usr/src/app
# COPY ./app ./
# COPY ./requirements.txt ./
# RUN pip install --no-cache-dir -r requirements.txt
# CMD ["python", "./server.py"]
# Задаём базовый образ
FROM tiangolo/uwsgi-nginx-flask:python3.9
# Копируем содержимое папки ./app в рабочую директорию контейнера
COPY ./app ./
# Копируем файл requirements.txt в рабочую директорию контейнера
COPY ./requirements.txt ./
# Копируем файл uwsgi.ini в рабочую директорию контейнера
COPY ./uwsgi.ini ./
# Запускаем установку необходимых зависимостей
RUN pip install -r requirements.txt