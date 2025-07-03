#!/bin/bash

# Backend startup script for Blitzit API

echo "Starting Blitzit Backend API..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
fi

# Activate virtual environment
source venv/Scripts/activate  # Windows
# source venv/bin/activate  # Linux/Mac

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Run migrations (create tables)
echo "Setting up database..."
python -c "from database import engine; from models import Base; Base.metadata.create_all(bind=engine); print('Database tables created')"

# Start the API server
echo "Starting API server..."
uvicorn main:app --reload --host 0.0.0.0 --port 8000
