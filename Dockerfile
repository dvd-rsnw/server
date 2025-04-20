FROM python:3.11-slim

WORKDIR /app

<<<<<<< HEAD
# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Set Python to not buffer output
ENV PYTHONUNBUFFERED=1

# Expose the port the app runs on
EXPOSE 4599

# Command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "4599", "--reload"]
=======
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD uvicorn main:app --host 0.0.0.0 --port ${PORT:-4599} --reload
>>>>>>> master
