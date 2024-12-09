import asyncio
import websockets


SERVER_URI = "ws://localhost:5001"


async def websocket_client():
    try:
        
        async with websockets.connect(SERVER_URI) as websocket:
            
            
            # Dinleme ve gönderme görevlerini paralel olarak başlat
            await asyncio.gather(
                listen_to_server(websocket),
                send_to_server(websocket)
            )
    except Exception as e:
        print(f"Hata: {e}")

# Sunucudan gelen mesajları dinleme
async def listen_to_server(websocket):
    try:
        while True:
            message = await websocket.recv()
            print(f"Sunucudan gelen mesaj: {message}")
    except websockets.ConnectionClosed:
        print("Sunucu bağlantısı kapandı.")
    except Exception as e:
        print(f"Dinleme sırasında hata: {e}")

# Sunucuya mesaj gönderme
async def send_to_server(websocket):
    try:
        while True:
            message = input("Sunucuya gönderilecek mesaj: ")
            await websocket.send(message)
            
    except websockets.ConnectionClosed:
        print("Sunucu bağlantısı kapandı.")
    except Exception as e:
        print(f"Gönderme sırasında hata: {e}")

# İstemciyi başlat
if __name__ == "__main__":
    asyncio.run(websocket_client())
