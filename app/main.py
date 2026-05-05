from fastapi import FastAPI
from database.db import create_tables
from routes.user import user_routes

app = FastAPI()

app.include_router(user_routes, prefix="/user")

create_tables()
