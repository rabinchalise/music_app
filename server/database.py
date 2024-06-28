from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os

load_dotenv()
db_pass = os.getenv('MY_POSTGRESS_KEY')

DATABASE_URL = f'postgresql://{db_pass}:postgres@127.0.0.1:5433/musicapp'

engine =  create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit = False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()