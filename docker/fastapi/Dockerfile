FROM python:3.10-slim

WORKDIR /app

RUN echo "Coping dependencies file" && \
    COPY requirements.txt /app/requirements.txt && \
    pip install --no-cache-dir -r /app/requirements.txt && \
    echo "✅ Install dependencies"


RUN echo "Coping source code" && \
    COPY main.py /app/main.py && \
     echo "✅ Copy source code"

RUN echo "Staring FastAPI server" && \
    echo "✅ FastAPI server started"
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]