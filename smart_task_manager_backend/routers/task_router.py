from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import status

import models
import schemas

from dependencies import (
    get_db,
    get_current_user,
)

router = APIRouter()


# CREATE TASK
@router.post(
    "/tasks",
    status_code=status.HTTP_201_CREATED,
)
def create_task(
    task: schemas.TaskCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    new_task = models.Task(
        title=task.title,
        category=task.category,
        priority=task.priority,
        completed=task.completed,
        user_id=current_user["user_id"],
    )

    db.add(new_task)

    db.commit()

    db.refresh(new_task)

    return {"message": "Task created successfully"}


# GET ALL TASKS
@router.get("/tasks")
def get_tasks(
    page: int = 1,
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    offset = (page - 1) * limit

    tasks = (
        db.query(models.Task)
        .filter(
            models.Task.user_id == current_user["user_id"],
            models.Task.is_deleted == False,
        )
        .offset(offset)
        .limit(limit)
        .all()
    )

    return tasks


# GET SINGLE TASK
@router.get("/tasks/{task_id}")
def get_task(
    task_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    task = (
        db.query(models.Task)
        .filter(
            models.Task.id == task_id,
            models.Task.user_id == current_user["user_id"],
            models.Task.is_deleted == False,
        )
        .first()
    )

    if task is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found",
        )

    return task


# DELETE TASK
@router.delete("/tasks/{task_id}")
def delete_task(
    task_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    task = (
        db.query(models.Task)
        .filter(
            models.Task.id == task_id,
            models.Task.user_id == current_user["user_id"],
            models.Task.is_deleted == False,
        )
        .first()
    )

    if task is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found",
        )

    task.is_deleted = True

    db.commit()

    return {"message": "Task deleted successfully"}


# UPDATE TASK
@router.put("/tasks/{task_id}")
def update_task(
    task_id: int,
    updated_task: schemas.TaskCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    task = (
        db.query(models.Task)
        .filter(
            models.Task.id == task_id,
            models.Task.user_id == current_user["user_id"],
        )
        .first()
    )

    if task is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found",
        )

    task.title = updated_task.title
    task.category = updated_task.category
    task.completed = updated_task.completed
    task.priority = updated_task.priority

    db.commit()

    db.refresh(task)

    return {"message": "Task updated successfully"}


# SEARCH TASK BY TITLE
@router.get("/search")
def search_task(
    title: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    tasks = (
        db.query(models.Task)
        .filter(
            models.Task.title.contains(title),
            models.Task.user_id == current_user["user_id"],
            models.Task.is_deleted == False,
        )
        .all()
    )

    return tasks


# FILTER TASKS BY CATEGORY
@router.get("/tasks/category/{category}")
def search_by_category(
    category: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    tasks = (
        db.query(models.Task)
        .filter(
            func.lower(models.Task.category).contains(category.lower()),
            models.Task.user_id == current_user["user_id"],
            models.Task.is_deleted == False,
        )
        .all()
    )

    return tasks
