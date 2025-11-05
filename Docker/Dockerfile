FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y python3 python3-venv && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY app.py .

RUN python3 -m venv venv && \
    ./venv/bin/pip install --no-cache-dir flask

EXPOSE 8080

CMD ["./venv/bin/python", "app.py"]