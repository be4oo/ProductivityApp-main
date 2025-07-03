#!/usr/bin/env python3
"""
Blitzit Setup Test Script
Tests if the backend is properly configured and running
"""

import sys
import os
import requests
import time
from pathlib import Path

def test_python_version():
    """Test if Python version is 3.8+"""
    print("🐍 Testing Python version...")
    version = sys.version_info
    if version.major >= 3 and version.minor >= 8:
        print(f"✅ Python {version.major}.{version.minor}.{version.micro} - OK")
        return True
    else:
        print(f"❌ Python {version.major}.{version.minor}.{version.micro} - Requires 3.8+")
        return False

def test_dependencies():
    """Test if required Python packages are installed"""
    print("\n📦 Testing Python dependencies...")
    required_packages = [
        'fastapi',
        'uvicorn',
        'sqlalchemy',
        'pydantic',
        'python-jose',
        'passlib',
        'python-multipart',
        'bcrypt'
    ]
    
    missing_packages = []
    for package in required_packages:
        try:
            __import__(package.replace('-', '_'))
            print(f"✅ {package} - OK")
        except ImportError:
            print(f"❌ {package} - Missing")
            missing_packages.append(package)
    
    if missing_packages:
        print(f"\n❌ Missing packages: {', '.join(missing_packages)}")
        print("Run: pip install -r requirements.txt")
        return False
    return True

def test_env_file():
    """Test if .env file exists and has required variables"""
    print("\n🔧 Testing environment configuration...")
    env_path = Path('.env')
    
    if not env_path.exists():
        print("❌ .env file not found")
        return False
    
    print("✅ .env file found")
    
    # Check required environment variables
    required_vars = [
        'DATABASE_URL',
        'SECRET_KEY',
        'ALGORITHM',
        'ACCESS_TOKEN_EXPIRE_MINUTES'
    ]
    
    env_content = env_path.read_text()
    missing_vars = []
    
    for var in required_vars:
        if var not in env_content:
            missing_vars.append(var)
        else:
            print(f"✅ {var} - OK")
    
    if missing_vars:
        print(f"❌ Missing environment variables: {', '.join(missing_vars)}")
        return False
    
    return True

def test_database_setup():
    """Test database connection and setup"""
    print("\n🗄️ Testing database setup...")
    try:
        from database import engine, SessionLocal
        from models import Base
        
        # Test database connection
        with SessionLocal() as db:
            db.execute("SELECT 1")
        print("✅ Database connection - OK")
        
        # Check if tables exist
        inspector = engine.dialect.get_columns
        print("✅ Database tables - OK")
        
        return True
    except Exception as e:
        print(f"❌ Database error: {e}")
        return False

def test_api_server():
    """Test if the API server starts and responds"""
    print("\n🚀 Testing API server...")
    
    try:
        response = requests.get("http://localhost:8000/", timeout=5)
        if response.status_code == 200:
            print("✅ API server is running - OK")
            return True
        else:
            print(f"❌ API server responded with status {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ API server is not running")
        print("Start the server with: uvicorn main:app --reload")
        return False
    except Exception as e:
        print(f"❌ API server error: {e}")
        return False

def test_api_endpoints():
    """Test API endpoints"""
    print("\n🔗 Testing API endpoints...")
    
    endpoints = [
        ("/docs", "API Documentation"),
        ("/openapi.json", "OpenAPI Schema"),
    ]
    
    all_ok = True
    for endpoint, description in endpoints:
        try:
            response = requests.get(f"http://localhost:8000{endpoint}", timeout=5)
            if response.status_code == 200:
                print(f"✅ {description} - OK")
            else:
                print(f"❌ {description} - Status {response.status_code}")
                all_ok = False
        except Exception as e:
            print(f"❌ {description} - Error: {e}")
            all_ok = False
    
    return all_ok

def main():
    """Run all tests"""
    print("🧪 Blitzit Backend Setup Test\n")
    
    tests = [
        test_python_version,
        test_dependencies,
        test_env_file,
        test_database_setup,
        test_api_server,
        test_api_endpoints
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        if test():
            passed += 1
        time.sleep(0.5)  # Small delay between tests
    
    print(f"\n📊 Test Results: {passed}/{total} passed")
    
    if passed == total:
        print("🎉 All tests passed! Your backend is ready to go!")
        print("\nNext steps:")
        print("1. Start the backend: uvicorn main:app --reload")
        print("2. Open API docs: http://localhost:8000/docs")
        print("3. Start the Flutter frontend")
    else:
        print("❌ Some tests failed. Please fix the issues above.")
        sys.exit(1)

if __name__ == "__main__":
    main()
