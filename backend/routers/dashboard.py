from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
import crud
from schemas import User, DashboardStats
from auth import get_current_active_user

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

@router.get("/stats", response_model=DashboardStats)
def get_dashboard_stats(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    return crud.get_dashboard_stats(db, user_id=current_user.id)
