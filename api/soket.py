import asyncio
import websockets


connected_clients = set()

async def handle_client(websocket):
    
    connected_clients.add(websocket)
    print(f"new connection: {websocket.remote_address}")

    try:
        
        async for message in websocket:
            print(f"message received: {message}")

           
            await asyncio.gather(
                *[client.send(message) for client in connected_clients if client != websocket]
            )
    except websockets.exceptions.ConnectionClosed:
        print(f"Connection shutted down: {websocket.remote_address}")
    finally:
       
        connected_clients.remove(websocket)

async def main():
    
    server = await websockets.serve(handle_client, "localhost", 8765)
    print("WebSocket server is running...")

    
    await server.wait_closed()

if __name__ == "__main__":
    asyncio.run(main())
