from fastapi import HTTPException, Header
import jwt


def auth_middleware(x_auth_token: str = Header()):
    try:
        #get user token from headers
        if not x_auth_token:
           raise HTTPException(status_code=401, detail='No auth token, access denied')
        #decode the token
        verified_token = jwt.decode(x_auth_token, 'password_key', algorithms=['HS256'])

        if not verified_token:
           raise HTTPException(status_code=401, detail='Token verification failed, authorization denied')
        #get the id from the token
        user_id = verified_token.get('id')

        return {'user_id': user_id, 'token': x_auth_token}
        #postgress database get user info

    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail='Token is not valid, authorization failed')