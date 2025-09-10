FROM public.ecr.aws/docker/library/python:3.11-alpine

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --disable-pip-version-check -r requirements.txt

COPY app.py .

EXPOSE 8080

CMD ["python", "app.py"]
