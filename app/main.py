from fastapi import FastAPI
from database.db import create_tables
from routes.user import user_routes

app = FastAPI()

app.include_router(user_routes, prefix="/user")

@app.on_event("startup")
def startup_db_client():
    """
    This function runs ONLY when the app starts up (e.g., via uvicorn).
    It does NOT run when pytest imports this module.
    """
    create_tables()
