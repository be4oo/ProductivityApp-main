from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional, List

# User schemas
class UserBase(BaseModel):
    email: EmailStr
    username: str
    full_name: Optional[str] = None

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    full_name: Optional[str] = None

class User(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

# Project schemas
class ProjectBase(BaseModel):
    name: str
    description: Optional[str] = None
    color: str = "#909dab"

class ProjectCreate(ProjectBase):
    pass

class ProjectUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    color: Optional[str] = None

class Project(ProjectBase):
    id: int
    owner_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Task schemas
class TaskBase(BaseModel):
    title: str
    notes: Optional[str] = None
    column: str = "Backlog"
    estimated_time: int = 0
    actual_time: int = 0
    task_type: Optional[str] = None
    task_priority: Optional[str] = None
    due_date: Optional[datetime] = None
    reminder_enabled: bool = False
    reminder_offset: int = 0
    is_urgent: bool = False
    is_important: bool = False

class TaskCreate(TaskBase):
    project_id: int

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    notes: Optional[str] = None
    column: Optional[str] = None
    estimated_time: Optional[int] = None
    actual_time: Optional[int] = None
    task_type: Optional[str] = None
    task_priority: Optional[str] = None
    due_date: Optional[datetime] = None
    reminder_enabled: Optional[bool] = None
    reminder_offset: Optional[int] = None
    is_urgent: Optional[bool] = None
    is_important: Optional[bool] = None

class Task(TaskBase):
    id: int
    project_id: int
    owner_id: int
    created_at: datetime
    updated_at: datetime
    completed_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# SubTask schemas
class SubTaskBase(BaseModel):
    title: str
    is_completed: bool = False

class SubTaskCreate(SubTaskBase):
    parent_task_id: int

class SubTaskUpdate(BaseModel):
    title: Optional[str] = None
    is_completed: Optional[bool] = None

class SubTask(SubTaskBase):
    id: int
    parent_task_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Authentication schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

# Response schemas
class TaskWithSubtasks(Task):
    subtasks: List[SubTask] = []

class ProjectWithTasks(Project):
    tasks: List[Task] = []

class DashboardStats(BaseModel):
    total_tasks: int
    completed_tasks: int
    pending_tasks: int
    overdue_tasks: int
    today_tasks: int
    this_week_tasks: int
    completion_rate: float
