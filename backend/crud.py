from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from models import User, Project, Task, SubTask
from schemas import UserCreate, ProjectCreate, TaskCreate, SubTaskCreate
from datetime import datetime, timedelta
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# User CRUD operations
def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def get_user_by_username(db: Session, username: str):
    return db.query(User).filter(User.username == username).first()

def create_user(db: Session, user: UserCreate):
    hashed_password = pwd_context.hash(user.password)
    db_user = User(
        email=user.email,
        username=user.username,
        full_name=user.full_name,
        hashed_password=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def authenticate_user(db: Session, username: str, password: str):
    user = get_user_by_username(db, username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

# Project CRUD operations
def get_projects(db: Session, user_id: int):
    return db.query(Project).filter(Project.owner_id == user_id).all()

def create_project(db: Session, project: ProjectCreate, user_id: int):
    db_project = Project(**project.dict(), owner_id=user_id)
    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project

def get_project(db: Session, project_id: int, user_id: int):
    return db.query(Project).filter(
        and_(Project.id == project_id, Project.owner_id == user_id)
    ).first()

def update_project(db: Session, project_id: int, project_update: dict, user_id: int):
    db_project = get_project(db, project_id, user_id)
    if db_project:
        for key, value in project_update.items():
            if value is not None:
                setattr(db_project, key, value)
        db_project.updated_at = datetime.utcnow()
        db.commit()
        db.refresh(db_project)
    return db_project

def delete_project(db: Session, project_id: int, user_id: int):
    db_project = get_project(db, project_id, user_id)
    if db_project:
        # Delete all tasks in this project first
        db.query(Task).filter(Task.project_id == project_id).delete()
        db.delete(db_project)
        db.commit()
        return True
    return False

# Task CRUD operations
def get_tasks(db: Session, user_id: int, project_id: int = None):
    query = db.query(Task).filter(Task.owner_id == user_id)
    if project_id:
        query = query.filter(Task.project_id == project_id)
    return query.all()

def create_task(db: Session, task: TaskCreate, user_id: int):
    db_task = Task(**task.dict(), owner_id=user_id)
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

def get_task(db: Session, task_id: int, user_id: int):
    return db.query(Task).filter(
        and_(Task.id == task_id, Task.owner_id == user_id)
    ).first()

def update_task(db: Session, task_id: int, task_update: dict, user_id: int):
    db_task = get_task(db, task_id, user_id)
    if db_task:
        for key, value in task_update.items():
            if value is not None:
                setattr(db_task, key, value)
        db_task.updated_at = datetime.utcnow()
        
        # Set completed_at if task is moved to Done
        if task_update.get('column') == 'Done' and db_task.completed_at is None:
            db_task.completed_at = datetime.utcnow()
        elif task_update.get('column') != 'Done':
            db_task.completed_at = None
            
        db.commit()
        db.refresh(db_task)
    return db_task

def delete_task(db: Session, task_id: int, user_id: int):
    db_task = get_task(db, task_id, user_id)
    if db_task:
        # Delete all subtasks first
        db.query(SubTask).filter(SubTask.parent_task_id == task_id).delete()
        db.delete(db_task)
        db.commit()
        return True
    return False

# SubTask CRUD operations
def get_subtasks(db: Session, task_id: int, user_id: int):
    # Ensure the parent task belongs to the user
    parent_task = get_task(db, task_id, user_id)
    if not parent_task:
        return []
    return db.query(SubTask).filter(SubTask.parent_task_id == task_id).all()

def create_subtask(db: Session, subtask: SubTaskCreate, user_id: int):
    # Ensure the parent task belongs to the user
    parent_task = get_task(db, subtask.parent_task_id, user_id)
    if not parent_task:
        return None
    
    db_subtask = SubTask(**subtask.dict())
    db.add(db_subtask)
    db.commit()
    db.refresh(db_subtask)
    return db_subtask

def update_subtask(db: Session, subtask_id: int, subtask_update: dict, user_id: int):
    db_subtask = db.query(SubTask).filter(SubTask.id == subtask_id).first()
    if db_subtask:
        # Ensure the parent task belongs to the user
        parent_task = get_task(db, db_subtask.parent_task_id, user_id)
        if not parent_task:
            return None
            
        for key, value in subtask_update.items():
            if value is not None:
                setattr(db_subtask, key, value)
        db.commit()
        db.refresh(db_subtask)
    return db_subtask

def delete_subtask(db: Session, subtask_id: int, user_id: int):
    db_subtask = db.query(SubTask).filter(SubTask.id == subtask_id).first()
    if db_subtask:
        # Ensure the parent task belongs to the user
        parent_task = get_task(db, db_subtask.parent_task_id, user_id)
        if not parent_task:
            return False
            
        db.delete(db_subtask)
        db.commit()
        return True
    return False

# Analytics and reporting
def get_dashboard_stats(db: Session, user_id: int):
    now = datetime.utcnow()
    today = now.date()
    week_start = today - timedelta(days=today.weekday())
    
    # Basic counts
    total_tasks = db.query(Task).filter(Task.owner_id == user_id).count()
    completed_tasks = db.query(Task).filter(
        and_(Task.owner_id == user_id, Task.column == 'Done')
    ).count()
    pending_tasks = db.query(Task).filter(
        and_(Task.owner_id == user_id, Task.column != 'Done')
    ).count()
    
    # Overdue tasks
    overdue_tasks = db.query(Task).filter(
        and_(
            Task.owner_id == user_id,
            Task.column != 'Done',
            Task.due_date < now
        )
    ).count()
    
    # Today and this week tasks
    today_tasks = db.query(Task).filter(
        and_(Task.owner_id == user_id, Task.column == 'Today')
    ).count()
    
    this_week_tasks = db.query(Task).filter(
        and_(Task.owner_id == user_id, Task.column == 'This Week')
    ).count()
    
    # Completion rate
    completion_rate = (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0
    
    return {
        "total_tasks": total_tasks,
        "completed_tasks": completed_tasks,
        "pending_tasks": pending_tasks,
        "overdue_tasks": overdue_tasks,
        "today_tasks": today_tasks,
        "this_week_tasks": this_week_tasks,
        "completion_rate": round(completion_rate, 2)
    }
