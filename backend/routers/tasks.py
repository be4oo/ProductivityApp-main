from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from database import get_db
import crud
from schemas import Task, TaskCreate, TaskUpdate, User, TaskWithSubtasks
from auth import get_current_active_user

router = APIRouter(prefix="/tasks", tags=["tasks"])

@router.get("/", response_model=List[Task])
def read_tasks(
    project_id: Optional[int] = Query(None),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    return crud.get_tasks(db, user_id=current_user.id, project_id=project_id)

@router.post("/", response_model=Task)
def create_task(
    task: TaskCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Verify the project belongs to the user
    db_project = crud.get_project(db, project_id=task.project_id, user_id=current_user.id)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    
    return crud.create_task(db=db, task=task, user_id=current_user.id)

@router.get("/{task_id}", response_model=TaskWithSubtasks)
def read_task(
    task_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    db_task = crud.get_task(db, task_id=task_id, user_id=current_user.id)
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # Get subtasks
    subtasks = crud.get_subtasks(db, task_id=task_id, user_id=current_user.id)
    
    # Convert to TaskWithSubtasks
    task_dict = db_task.__dict__.copy()
    task_dict['subtasks'] = subtasks
    
    return task_dict

@router.put("/{task_id}", response_model=Task)
def update_task(
    task_id: int,
    task_update: TaskUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    db_task = crud.update_task(
        db, task_id=task_id, 
        task_update=task_update.dict(exclude_unset=True),
        user_id=current_user.id
    )
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return db_task

@router.delete("/{task_id}")
def delete_task(
    task_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    success = crud.delete_task(db, task_id=task_id, user_id=current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Task not found")
    return {"message": "Task deleted successfully"}

@router.put("/{task_id}/move")
def move_task(
    task_id: int,
    column: str,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Move a task to a different column (Backlog, This Week, Today, Done)"""
    valid_columns = ["Backlog", "This Week", "Today", "Done"]
    if column not in valid_columns:
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid column. Must be one of: {valid_columns}"
        )
    
    db_task = crud.update_task(
        db, task_id=task_id, 
        task_update={"column": column},
        user_id=current_user.id
    )
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return db_task

@router.put("/{task_id}/matrix")
def update_task_matrix(
    task_id: int,
    is_urgent: bool,
    is_important: bool,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Update task's position in Eisenhower Matrix"""
    # Determine column based on urgency
    column = "Today" if is_urgent else "This Week"
    
    # Determine priority based on importance
    priority = "High" if is_important else "Medium"
    
    db_task = crud.update_task(
        db, task_id=task_id, 
        task_update={
            "is_urgent": is_urgent,
            "is_important": is_important,
            "column": column,
            "task_priority": priority
        },
        user_id=current_user.id
    )
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return db_task
