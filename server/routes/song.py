import uuid
from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.orm import Session, joinedload
from database import get_db
from middleware.auth_middleware import auth_middleware
import cloudinary
import os
import cloudinary.uploader
from dotenv import load_dotenv
from models.favorite import Favorite
from models.song import Song
from pydantic_schemas.favorite_song import FavoriteSong

load_dotenv()
router = APIRouter()

# Configuration       
cloudinary.config( 
    cloud_name = os.getenv("MY_CLOUD_NAME"), 
    api_key = os.getenv("MY_API_KEY"), 
    api_secret = os.getenv("MY_API_SECRET"), # Click 'View Credentials' below to copy your API secret
    secure=True
)

@router.post('/upload', status_code=201)
def upload_song(song: UploadFile = File(...), thumbnail : UploadFile = File(...),  
                artist : str = Form(...), 
                song_name : str = Form(...), 
                hex_code : str = Form(...),
                db: Session = Depends(get_db),
                auth_dict=Depends(auth_middleware)): 
    song_id = str(uuid.uuid4())
    song_res = cloudinary.uploader.upload(song.file, resource_type='auto', folder=f'songs/{song_id}')

    thumbnail_res = cloudinary.uploader.upload(thumbnail.file, resource_type='image', folder=f'songs/{song_id}')

    new_song = Song(
        id = song_id,
        song_name = song_name,
        artist = artist,
        song_url = song_res['url'],
        thumbnail_url = thumbnail_res['url'],
        hex_code = hex_code

    )

    db.add(new_song)
    db.commit()
    db.refresh(new_song)

    return new_song

@router.get('/list')
def list_songs(db: Session = Depends(get_db), auth_dict=Depends(auth_middleware)):
    songs = db.query(Song).all()
    return songs  

@router.post('/favorite')
def favorite_song(song: FavoriteSong, db: Session = Depends(get_db),
                 auth_dict=Depends(auth_middleware)):
    
    #song is already favorited by user
    user_id = auth_dict['user_id']

    fav_song = db.query(Favorite).filter(Favorite.song_id == song.song_id, Favorite.user_id == user_id).first()

    if fav_song:
        db.delete(fav_song)
        db.commit()
        return {'message': False}
    else:
        new_fav = Favorite(
            id = str(uuid.uuid4()),
            user_id = user_id,
            song_id = song.song_id
        )
        db.add(new_fav)
        db.commit()
        db.refresh(new_fav)
        return {'message': True}

    # if the song is already favorited, unfavorite the song
    # if the song is not favorited, fav the song
@router.get('/list/favorites')
def list_fav_songs(db: Session = Depends(get_db), auth_dict=Depends(auth_middleware)):
    user_id = auth_dict['user_id']
    fav_songs = db.query(Favorite).filter(Favorite.user_id == user_id).options(
        joinedload(Favorite.song),
        ).all()
   
    return fav_songs  