from fastapi import APIRouter, Depends, HTTPException, Header
import jwt
from database import get_db
from middleware.auth_middleware import auth_middleware
from models.user import User
from pydantic_schemas.user_create import UserCreate
from sqlalchemy.orm import Session, joinedload
import uuid
import bcrypt
from pydantic_schemas.user_login import UserLogin


router = APIRouter()

@router.post('/signup', status_code=201)
def signup_user(user: UserCreate, db:Session=Depends(get_db)):
   
    # check if the user already exists in db
    user_db =db.query(User).filter(User.email == user.email).first()
    if  user_db:
        raise HTTPException(status_code=400, detail='User with same email already exists!')
    
    # check if the password is strong
    if len(user.password) < 6:
        raise HTTPException(status_code=400, detail='Password must be at least 6 characters long!')
        
    # add the user to the db
    hased_pwd = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())
    user_db = User(id = str(uuid.uuid4()), email=user.email, password=hased_pwd, name=user.name)

    db.add(user_db)
    db.commit()
    db.refresh(user_db)

    return user_db



@router.post('/login')
def login_user(user: UserLogin, db:Session=Depends(get_db)):
    
    # check if the user already exists in db
    user_db = db.query(User).filter(User.email == user.email).first()
    if not user_db:
        raise HTTPException(status_code=400, detail='User with this email does not exist!')
    
    # check if the password is correct or not
    is_match = bcrypt.checkpw(user.password.encode(), user_db.password)
    if not is_match:
        raise HTTPException(status_code=400, detail='Incorrect password!')
    
    # create a jwt token

    token = jwt.encode({'id': user_db.id},'password_key')

    


    return {'token': token, 'user': user_db}


@router.get('/')
def current_user_data( db:Session=Depends(get_db), 
                      user_dict=Depends(auth_middleware)):
    user = db.query(User).filter(User.id == user_dict['user_id']).options(
        joinedload(User.favorites)).first()
    if not user:
        raise HTTPException(status_code=404, detail='User not found')
    
    return user
