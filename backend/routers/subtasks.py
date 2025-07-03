from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from database import get_db
import crud
from schemas import SubTask, SubTaskCreate, SubTaskUpdate, User
from auth import get_current_active_user

router = APIRouter(prefix="/subtasks", tags=["subtasks"])

@router.get("/task/{task_id}", response_model=List[SubTask])
def read_subtasks(
    task_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    return crud.get_subtasks(db, task_id=task_id, user_id=current_user.id)

@router.post("/", response_model=SubTask)
def create_subtask(
    subtask: SubTaskCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    db_subtask = crud.create_subtask(db=db, subtask=subtask, user_id=current_user.id)
    if db_subtask is None:
        raise HTTPException(status_code=404, detail="Parent task not found")
    return db_subtask

@router.put("/{subtask_id}", response_model=SubTask)
def update_subtask(
    subtask_id: int,
    subtask_update: SubTaskUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    db_subtask = crud.update_subtask(
        db, subtask_id=subtask_id, 
        subtask_update=subtask_update.dict(exclude_unset=True),
        user_id=current_user.id
    )
    if db_subtask is None:
        raise HTTPException(status_code=404, detail="Subtask not found")
    return db_subtask

@router.delete("/{subtask_id}")
def delete_subtask(
    subtask_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    success = crud.delete_subtask(db, subtask_id=subtask_id, user_id=current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Subtask not found")
    return {"message": "Subtask deleted successfully"}
