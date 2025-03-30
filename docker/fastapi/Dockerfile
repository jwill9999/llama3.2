FROM python:3.10-slim

WORKDIR /app

# Copy requirements file
COPY requirements.txt /app/requirements.txt

# Install dependencies
RUN echo "Installing dependencies" && \
    pip install --no-cache-dir -r /app/requirements.txt && \
    echo "✅ Install dependencies complete"

# Copy source code
COPY main.py /app/main.py

# Output info message
RUN echo "✅ FastAPI server ready to start"

# Start FastAPI server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]