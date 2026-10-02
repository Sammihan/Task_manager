from fastapi import APIRouter, HTTPException, Depends, Header
from fastapi import status
from sqlalchemy.orm import Session

import models
import schemas

from database import SessionLocal
from dependencies import (
    get_db,
    get_current_user,
)

from auth import (
    hash_password,
    verify_password,
    create_access_token,
)

router = APIRouter()


@router.post(
    "/signup",
    status_code=status.HTTP_201_CREATED,
)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    existing_email = (
        db.query(models.User).filter(models.User.email == user.email).first()
    )

    if existing_email:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already exists",
        )

    existing_username = (
        db.query(models.User).filter(models.User.username == user.username).first()
    )

    if existing_username:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Username already exists",
        )

    hashed_pw = hash_password(user.password)

    new_user = models.User(
        username=user.username,
        email=user.email,
        password=hashed_pw,
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {"message": "User created successfully"}


@router.post("/login")
def login(user: schemas.UserLogin, db: Session = Depends(get_db)):
    existing_user = (
        db.query(models.User).filter(models.User.email == user.email).first()
    )

    if not existing_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not verify_password(
        user.password,
        existing_user.password,
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    access_token = create_access_token(
        data={
            "user_id": existing_user.id,
            "email": existing_user.email,
        }
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
    }
