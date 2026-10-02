# Smart Task Manager 🚀

A modern full-stack task management application featuring a **Flutter** frontend and a **FastAPI** backend with JWT authentication and SQLite/SQLAlchemy database support.

---

## 🌟 Features

- 🔐 **Authentication & Authorization**: Secure user registration and login using JWT tokens and bcrypt password hashing.
- 📋 **Task Management**: Create, update, view, and soft-delete tasks.
- 🎯 **Priority & Categories**: Assign task priority levels (`High`, `Medium`, `Low`) and categories (e.g. `Coding`, `Academics`, `Health`, `Personal`).
- 🔍 **Search & Filtering**: Search tasks by title and filter by category in real-time.
- 📊 **Progress Tracker**: Visual progress indicator showing completed vs total tasks.
- 💻 **Cross-Platform**: Flutter UI runs on Windows, Web, Android, and macOS.

---

## 🛠 Tech Stack

### Frontend
- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **HTTP Client**: `http`
- **Storage**: `shared_preferences` (for secure local JWT persistence)

### Backend
- **Framework**: [FastAPI](https://fastapi.tiangolo.com) (Python)
- **ORM / Database**: [SQLAlchemy](https://www.sqlalchemy.org) with SQLite
- **Security**: `bcrypt` (password hashing) & `python-jose` (JWT)
- **Validation**: [Pydantic v2](https://docs.pydantic.dev) with `email-validator`

---

## 📁 Project Structure

```text
Task_manager/
├── smart_task_manager/          # Flutter Frontend Application
│   ├── lib/
│   │   ├── models/              # Data models
│   │   ├── screens/             # UI Screens (Login, Signup, Home, Create, Edit)
│   │   ├── services/            # API client service
│   │   └── main.dart            # Flutter entry point
│   └── pubspec.yaml
│
└── smart_task_manager_backend/  # FastAPI Backend API
    ├── routers/                 # API Routes (auth_router, task_router)
    ├── auth.py                  # JWT & password hashing logic
    ├── database.py              # SQLite database session configuration
    ├── dependencies.py          # Auth & DB dependencies
    ├── main.py                  # FastAPI application entry point
    ├── models.py                # SQLAlchemy DB models
    ├── schemas.py               # Pydantic request/response schemas
    ├── requirements.txt         # Python dependencies
    └── .env.example             # Environment variables template
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0+)
- [Python 3.10+](https://www.python.org/downloads/)
- [Git](https://git-scm.com/)

---

### 1. Backend Setup (FastAPI)

1. Navigate to the backend directory:
   ```bash
   cd smart_task_manager_backend
   ```

2. Create and activate a Python virtual environment:
   - **Windows (PowerShell)**:
     ```powershell
     python -m venv venv
     .\venv\Scripts\Activate.ps1
     ```
   - **Linux / macOS**:
     ```bash
     python3 -m venv venv
     source venv/bin/activate
     ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Configure environment variables (optional):
   ```bash
   cp .env.example .env
   ```

5. Start the backend server:
   ```bash
   uvicorn main:app --reload --port 8001
   ```

6. Verify the API is running by visiting the interactive Swagger UI:
   - **Swagger Docs**: [http://127.0.0.1:8001/docs](http://127.0.0.1:8001/docs)

---

### 2. Frontend Setup (Flutter)

1. Open a new terminal and navigate to the frontend directory:
   ```bash
   cd smart_task_manager
   ```

2. Install Flutter packages:
   ```bash
   flutter pub get
   ```

3. Run the app:
   - **Windows Desktop**:
     ```bash
     flutter run -d windows
     ```
   - **Web (Chrome)**:
     ```bash
     flutter run -d chrome
     ```
   - **Default Connected Device**:
     ```bash
     flutter run
     ```

---

## 📡 API Endpoints Overview

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/signup` | Register a new user | ❌ |
| `POST` | `/login` | Authenticate & get JWT token | ❌ |
| `GET` | `/tasks` | Get paginated tasks for user | ✅ |
| `POST` | `/tasks` | Create a new task | ✅ |
| `GET` | `/tasks/{task_id}` | Get single task details | ✅ |
| `PUT` | `/tasks/{task_id}` | Update task details | ✅ |
| `DELETE` | `/tasks/{task_id}` | Soft delete task | ✅ |
| `GET` | `/search` | Search tasks by title | ✅ |
| `GET` | `/tasks/category/{cat}` | Filter tasks by category | ✅ |

---

## 🔒 Security Best Practices
- Passwords are salted and hashed using `bcrypt` before storage.
- Authentication tokens use standard HMAC-SHA256 signatures with JWT expiration.
- Sensitive environment configurations (`.env`) and local database files (`*.db`) are ignored in version control via `.gitignore`.
