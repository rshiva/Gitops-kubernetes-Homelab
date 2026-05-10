from fastapi import APIRouter

from database.user import create_user, delete_user, get_user, get_users, update_user
from models.user import User

user_routes = APIRouter()

# CREATE USER
@user_routes.post("/create", response_model=User)
def create(user: User):
    return create_user(user.model_dump())

# GET USER BY ID
@user_routes.get("/get/{id}")
def get_by_id(id: str):
    return get_user(id)


# GET USERS
@user_routes.get("/all")
def get_all():
    return get_users()


# DELETE USER
@user_routes.delete("/delete")
def delete(user: User):
    return delete_user(user.model_dump())


# UPDATE USER
@user_routes.put("/update")
def update(user: User):
    return update_user(user.model_dump())

# health-check
@user_routes.get("/health")
def health():
    return {"status": "healthy"}
