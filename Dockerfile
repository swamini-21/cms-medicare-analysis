FROM python:3.11-slim
WORKDIR /app
COPY requirements-ingest.txt .
RUN pip install --no-cache-dir -r requirements-ingest.txt
COPY ingestion ./ingestion
CMD ["python", "-m", "ingestion.ingest"]