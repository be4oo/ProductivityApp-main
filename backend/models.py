from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey, Float
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    username = Column(String, unique=True, index=True)
    full_name = Column(String)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    projects = relationship("Project", back_populates="owner")
    tasks = relationship("Task", back_populates="owner")

class Project(Base):
    __tablename__ = "projects"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(Text)
    color = Column(String, default="#909dab")
    owner_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    owner = relationship("User", back_populates="projects")
    tasks = relationship("Task", back_populates="project")

class Task(Base):
    __tablename__ = "tasks"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    notes = Column(Text)
    column = Column(String, default="Backlog")  # Backlog, This Week, Today, Done
    estimated_time = Column(Integer, default=0)  # in minutes
    actual_time = Column(Integer, default=0)  # in minutes
    task_type = Column(String)  # Work, Personal, Other
    task_priority = Column(String)  # Low, Medium, High
    due_date = Column(DateTime)
    reminder_enabled = Column(Boolean, default=False)
    reminder_offset = Column(Integer, default=0)  # minutes before due date
    is_urgent = Column(Boolean, default=False)
    is_important = Column(Boolean, default=False)
    
    # Foreign Keys
    project_id = Column(Integer, ForeignKey("projects.id"))
    owner_id = Column(Integer, ForeignKey("users.id"))
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    completed_at = Column(DateTime)
    
    # Relationships
    project = relationship("Project", back_populates="tasks")
    owner = relationship("User", back_populates="tasks")
    subtasks = relationship("SubTask", back_populates="parent_task")

class SubTask(Base):
    __tablename__ = "subtasks"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    is_completed = Column(Boolean, default=False)
    parent_task_id = Column(Integer, ForeignKey("tasks.id"))
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    parent_task = relationship("Task", back_populates="subtasks")
