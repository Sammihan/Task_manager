from fastapi import Header, HTTPException
from database import SessionLocal
from auth import verify_token


# Database Dependency
def get_db():

    db = SessionLocal()

    try:
        yield db

    finally:
        db.close()


def get_current_user(authorization: str = Header(...)):
    try:
        parts = authorization.split(" ")
        if len(parts) != 2 or parts[0].lower() != "bearer":
            raise HTTPException(status_code=401, detail="Invalid authorization header format")
        token = parts[1]
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid authorization header")

    payload = verify_token(token)

    if payload is None:
        raise HTTPException(status_code=401, detail="Invalid Token")

    return payload
