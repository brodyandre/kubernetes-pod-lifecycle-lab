FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

ENV PYTHONUNBUFFERED=1
ENV GRACEFUL_SHUTDOWN_SECONDS=15

EXPOSE 8080

CMD ["python", "app.py"]
