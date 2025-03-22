FROM python:3.10-slim

WORKDIR /app

# Copy the root requirements.txt file
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the main.py file
COPY main.py /app/main.py

# Use uvicorn to run the FastAPI app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]