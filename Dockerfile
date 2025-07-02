FROM python:3.9-slim

WORKDIR /docs
COPY . .

RUN pip install -r requirements.txt && mkdocs build

CMD ["python", "-m", "http.server", "8000", "--directory", "site"]