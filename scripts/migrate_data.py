import sqlite3
import sys
import os
from datetime import datetime

# Add the backend directory to the path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'backend'))

from sqlalchemy.orm import Session
from database import get_db, engine
from models import Base, User, Project, Task
import crud
from schemas import UserCreate, ProjectCreate, TaskCreate

# Create tables
Base.metadata.create_all(bind=engine)

def migrate_data():
    # Connect to old database
    old_db_path = '../Blitzit_App/data/tasks.db'
    if not os.path.exists(old_db_path):
        print(f"Old database not found at {old_db_path}")
        return
    
    old_conn = sqlite3.connect(old_db_path)
    old_conn.row_factory = sqlite3.Row
    
    # Get new database session
    db = next(get_db())
    
    try:
        # Create a default user for migration
        default_user = UserCreate(
            email="admin@blitzit.com",
            username="admin",
            full_name="Admin User",
            password="admin123"  # Change this in production
        )
        
        # Check if user already exists
        existing_user = crud.get_user_by_email(db, default_user.email)
        if not existing_user:
            user = crud.create_user(db, default_user)
            print(f"Created default user: {user.username}")
        else:
            user = existing_user
            print(f"Using existing user: {user.username}")
        
        # Migrate projects
        print("\nMigrating projects...")
        old_projects = old_conn.execute("SELECT * FROM projects").fetchall()
        project_mapping = {}
        
        for old_project in old_projects:
            existing_project = db.query(Project).filter(
                Project.name == old_project['name'],
                Project.owner_id == user.id
            ).first()
            
            if not existing_project:
                new_project = ProjectCreate(
                    name=old_project['name'],
                    color=old_project.get('color', '#909dab')
                )
                project = crud.create_project(db, new_project, user.id)
                project_mapping[old_project['id']] = project.id
                print(f"  Migrated project: {project.name}")
            else:
                project_mapping[old_project['id']] = existing_project.id
                print(f"  Project already exists: {existing_project.name}")
        
        # Migrate tasks
        print("\nMigrating tasks...")
        old_tasks = old_conn.execute("SELECT * FROM tasks").fetchall()
        
        for old_task in old_tasks:
            # Check if task already exists
            existing_task = db.query(Task).filter(
                Task.title == old_task['title'],
                Task.owner_id == user.id
            ).first()
            
            if not existing_task:
                # Map the project ID
                project_id = project_mapping.get(old_task.get('project_id', 1), 1)
                
                # Convert due_date string to datetime if present
                due_date = None
                if old_task.get('due_date'):
                    try:
                        due_date = datetime.fromisoformat(old_task['due_date'])
                    except:
                        due_date = None
                
                new_task = TaskCreate(
                    title=old_task['title'],
                    notes=old_task.get('notes', ''),
                    column=old_task.get('column', 'Backlog'),
                    estimated_time=old_task.get('estimated_time', 0),
                    actual_time=old_task.get('actual_time', 0),
                    task_type=old_task.get('task_type'),
                    task_priority=old_task.get('task_priority'),
                    due_date=due_date,
                    reminder_enabled=bool(old_task.get('reminder_enabled', 0)),
                    reminder_offset=old_task.get('reminder_offset', 0),
                    project_id=project_id
                )
                
                task = crud.create_task(db, new_task, user.id)
                
                # Set completed_at if task was completed
                if old_task.get('completed_at'):
                    try:
                        completed_at = datetime.fromisoformat(old_task['completed_at'])
                        task.completed_at = completed_at
                        db.commit()
                    except:
                        pass
                
                print(f"  Migrated task: {task.title}")
            else:
                print(f"  Task already exists: {existing_task.title}")
        
        print("\nMigration completed successfully!")
        
    except Exception as e:
        print(f"Migration failed: {e}")
        db.rollback()
        raise
    finally:
        old_conn.close()
        db.close()

if __name__ == "__main__":
    migrate_data()
