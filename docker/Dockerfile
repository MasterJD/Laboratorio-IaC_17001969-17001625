FROM python:latest
ADD app.py /app/app.py
RUN apt-get update && apt-get install -y curl
WORKDIR /app
EXPOSE 5000
CMD ["python", "app.py"]
