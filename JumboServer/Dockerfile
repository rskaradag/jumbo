FROM alpine:latest

RUN apk add py3-pip

RUN pip3 install flask

WORKDIR /app

COPY . .

EXPOSE 80

CMD ["--host=0.0.0.0", "--port=80"]

ENTRYPOINT ["python3", "main.py"]