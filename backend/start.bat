@echo off
echo Starting Blitzit Backend API...

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate

REM Install dependencies
echo Installing dependencies...
pip install -r requirements.txt

REM Run migrations (create tables)
echo Setting up database...
python -c "from database import engine; from models import Base; Base.metadata.create_all(bind=engine); print('Database tables created')"

REM Start the API server
echo Starting API server...
uvicorn main:app --reload --host 0.0.0.0 --port 8000
