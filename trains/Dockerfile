FROM python:3.11-slim

WORKDIR /app

# Copy requirements from parent directory
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Ensure we have the train types module available
COPY train_types.py .

# Copy the trains application
COPY . .

# Set Python to not buffer output
ENV PYTHONUNBUFFERED=1

# Expose the port the app runs on
EXPOSE 4600

# Command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "4600", "--reload"] 