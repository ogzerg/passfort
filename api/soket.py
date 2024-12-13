import asyncio
import os
import time
import jwt
import websockets.server as websockets
from requests import post
import json
from dotenv import load_dotenv
from websockets import exceptions as websockets_exceptions
from DBConnection import DBConnection

load_dotenv()
connected_clients = set()
waiting_clients = set()


# region Checkers
def check_session(auth_header):
    """
    Checks the session validity using the provided authentication header.

    Args:
        auth_header (str): The authentication header containing the session token.

    Returns:
        tuple: A tuple containing a boolean indicating the session validity and the user ID if the session is valid.
               If the session is invalid, returns (False, None).
    """
    url = "http://localhost:5000/check_session"
    headers = {"Cookie": f"session={auth_header}"}
    res = post(url, headers=headers)
    if res.status_code == 200:
        js = json.loads(res.text)
        return True, js["user_id"]
    return False, None


async def check_jwt(jwt_str):
    """
    Checks the validity of the JWT token.

    Args:
        jwt_str (str): The JWT token.

    Returns:
        tuple: A tuple containing a boolean indicating the token validity and the user ID if the token is valid.
               If the token is invalid, returns (False, None).
    """
    secret_key = os.getenv("JWT_SECRET")
    try:
        payload = jwt.decode(jwt_str, secret_key, algorithms=["HS256"])
        return True, payload["user_id"]
    except jwt.ExpiredSignatureError:
        return False, None
    except jwt.InvalidTokenError:
        return False, None


# endregion


async def handle_client(websocket: websockets.WebSocketServerProtocol):
    connected_clients.add(websocket)
    print(f"new connection: {websocket.remote_address}")
    try:
        async for message in websocket:
            print(f"message received: {message}")
            js = json.loads(message)
            if "action" not in js:
                out = {"status": False, "msg": "Action is missing"}
                await websocket.send(json.dumps(out))
            else:
                action = js["action"]
                # region Get Passwords
                if action == "getPasswords":
                    db = DBConnection()
                    res = db.get_users_password(websocket.user_id)
                    out = {"status": True, "action": "getPasswords", "passwords": res}
                    await websocket.send(json.dumps(out))
                # endregion
                # region Add Password
                elif action == "addPassword":
                    db = DBConnection()
                    if "service" not in js or "password" not in js or "login" not in js:
                        out = {
                            "status": False,
                            "msg": "Service, login or password is missing",
                        }
                        await websocket.send(json.dumps(out))
                    db.insert_password(
                        websocket.user_id, js["service"], js["login"], js["password"]
                    )
                    out = {
                        "status": True,
                        "action": "addPassword",
                        "msg": "Password set successfully",
                    }
                    await websocket.send(json.dumps(out))
                # endregion
                # region Get User Informations
                elif action == "getUserInformations":
                    db = DBConnection()
                    res = db.get_user_informations(websocket.user_id)
                    out = {
                        "status": True,
                        "action": "getUserInformations",
                        "informations": res,
                    }
                    await websocket.send(json.dumps(out))
                # endregion
    except websockets_exceptions.ConnectionClosed:
        print(f"Connection shutted down: {websocket.remote_address}")
    finally:
        await websocket.close()
        connected_clients.remove(websocket)


async def main():
    # region Check Processes
    async def check(websocket: websockets.WebSocketServerProtocol):
        headers = websocket.request_headers
        if "auth_device" not in headers:
            await websocket.send("auth_device is missing")
            await websocket.close()
            return
        else:
            if ("gen_key" not in headers) and ("Authorization" not in headers):
                out = {"status": False, "msg": "gen_key or Authorization is missing"}
                await websocket.send(json.dumps(out))
                await websocket.close()
                return
            if headers.get("auth_device") == "mobile":
                # region Mobile Authorization
                res, uid = check_session(headers.get("Authorization"))
                if not res:
                    out = {"status": False, "msg": "Unauthorized"}
                    await websocket.send(json.dumps(out))
                    await websocket.close()
                    return
                else:
                    gen_key = headers.get("gen_key")
                    clients = [
                        client
                        for client in waiting_clients
                        if client.gen_key == gen_key
                    ]
                    if clients:
                        ws = clients.pop()
                        ws.user_id = uid
                        ws.gen_key = None
                        waiting_clients.discard(ws)

                        def create_jwt_token():
                            secret_key = os.getenv("JWT_SECRET")
                            payload = {
                                "user_id": uid,
                                "iat": int(time.time()),
                                "exp": int(time.time()) + 2592000,
                            }
                            token = jwt.encode(payload, secret_key, algorithm="HS256")
                            return token

                        token = create_jwt_token()
                        out = {"status": True, "msg": "Authorized"}
                        await websocket.send(json.dumps(out))
                        await websocket.close()
                        out = {
                            "status": True,
                            "action": "login",
                            "msg": "Authorized",
                            "token": token,
                        }
                        await ws.send(json.dumps(out))
                        await handle_client(ws)
                    else:
                        out = {"status": False, "msg": "No client found"}
                        await websocket.send(json.dumps(out))
                        await websocket.close()
                # endregion
            elif headers.get("auth_device") == "desktop":
                # region Desktop Authorization
                if "Authorization" not in headers:
                    generated_key = headers.get("gen_key")
                    websocket.gen_key = generated_key
                    waiting_clients.add(websocket)
                    out = {"status": True, "msg": "Waiting for mobile authorization"}
                    await websocket.send(json.dumps(out))
                    try:
                        while websocket in waiting_clients:
                            await asyncio.sleep(10)
                    except websockets_exceptions.ConnectionClosed:
                        print(f"Connection closed: {websocket.remote_address}")
                else:
                    res, uid = await check_jwt(headers.get("Authorization"))
                    if not res:
                        out = {"status": False, "msg": "Unauthorized"}
                        await websocket.send(json.dumps(out))
                        await websocket.close()
                        return
                    websocket.user_id = uid
                    out = {"status": True, "msg": "Authorized"}
                    await websocket.send(json.dumps(out))
                    await handle_client(websocket)
                # endregion
    # endregion
    server = await websockets.serve(check, "0.0.0.0", 5001)
    print("WebSocket server is running...")
    await server.wait_closed()


if __name__ == "__main__":
    asyncio.run(main())
