from pydantic import BaseModel, EmailStr, Field
from typing import Literal


class TaskCreate(BaseModel):
    title: str = Field(min_length=3, max_length=100)
    category: str = Field(min_length=3, max_length=30)
    completed: bool = False
    priority: Literal["High", "Medium", "Low"] = "Medium"


class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=30)
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)


class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)
