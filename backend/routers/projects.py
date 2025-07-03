from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from database import get_db
import crud
from schemas import Project, ProjectCreate, ProjectUpdate, User
from auth import get_current_active_user

router = APIRouter(prefix="/projects", tags=["projects"])

@router.get("/", response_model=List[Project])
def read_projects(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    return crud.get_projects(db, user_id=current_user.id)

@router.post("/", response_model=Project)
def create_project(
    project: ProjectCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    return crud.create_project(db=db, project=project, user_id=current_user.id)

@router.get("/{project_id}", response_model=Project)
def read_project(
    project_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    db_project = crud.get_project(db, project_id=project_id, user_id=current_user.id)
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    return db_project

@router.put("/{project_id}", response_model=Project)
def update_project(
    project_id: int,
    project_update: ProjectUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    db_project = crud.update_project(
        db, project_id=project_id, 
        project_update=project_update.dict(exclude_unset=True),
        user_id=current_user.id
    )
    if db_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    return db_project

@router.delete("/{project_id}")
def delete_project(
    project_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    success = crud.delete_project(db, project_id=project_id, user_id=current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Project not found")
    return {"message": "Project deleted successfully"}
