import asyncio
import websockets
import json
import logging
from datetime import datetime
from colorama import Fore, Back, Style, init
from typing import Optional

# Import configuration
from config import WEBSOCKET_HOST, WEBSOCKET_PORT, WEBSOCKET_RECONNECT_DELAY

# Initialize colorama
init(autoreset=True)

class RobloxWebSocketServer:
    def __init__(self):
        self.clients = set()
        self.server = None
        self.loop: Optional[asyncio.AbstractEventLoop] = None

        # Setup logging
        logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
        self.logger = logging.getLogger(__name__)

    def log(self, message, color=Fore.WHITE):
        """Log message with timestamp and color"""
        timestamp = datetime.now().strftime('%H:%M:%S')
        print(f"[{timestamp}] [WEBSOCKET] {color}{message}{Style.RESET_ALL}")

    async def start(self):
        """Start WebSocket server"""
        self.log(f"🚀 Starting WebSocket server on ws://{WEBSOCKET_HOST}:{WEBSOCKET_PORT}", Fore.GREEN)

        self.server = await websockets.serve(
            self.handle_client,
            WEBSOCKET_HOST,
            WEBSOCKET_PORT
        )

        self.log("✅ WebSocket server started successfully", Fore.GREEN)

        try:
            # Keep server running
            await self.server.wait_closed()
        except KeyboardInterrupt:
            self.log("ℹ️ WebSocket server shutting down...", Fore.YELLOW)
            await self.stop()

    async def stop(self):
        """Stop WebSocket server"""
        if self.server:
            self.server.close()
            await self.server.wait_closed()
            self.log("🔌 WebSocket server stopped", Fore.RED)

    async def handle_client(self, websocket):
        """Handle new WebSocket client connection"""
        client_address = websocket.remote_address
        self.clients.add(websocket)

        self.log(f"🔗 New Roblox client connected: {client_address}", Fore.GREEN)

        try:
            async for message in websocket:
                await self.handle_client_message(websocket, message)
        except websockets.exceptions.ConnectionClosed:
            self.log(f"🔌 Roblox client disconnected: {client_address}", Fore.YELLOW)
        except Exception as e:
            self.log(f"❌ Error handling client {client_address}: {e}", Fore.RED)
        finally:
            self.clients.discard(websocket)

    async def handle_client_message(self, websocket, message):
        """Handle message from Roblox client"""
        try:
            # Parse message from Roblox client
            data = json.loads(message)

            if data.get('type') == 'status':
                status = data.get('status', 'unknown')
                self.log(f"📱 Roblox client status: {status}", Fore.BLUE)

            elif data.get('type') == 'log':
                log_message = data.get('message', '')
                self.log(f"📱 Roblox: {log_message}", Fore.CYAN)

        except json.JSONDecodeError:
            self.log("❌ Invalid JSON received from Roblox client", Fore.RED)

    async def send_to_clients(self, data):
        """Send data to all connected Roblox clients"""
        if not self.clients:
            self.log("⚠️ No Roblox clients connected", Fore.YELLOW)
            return

        # Create list of clients to avoid modification during iteration
        clients_to_send = list(self.clients)

        for client in clients_to_send:
            try:
                await client.send(data)
                self.log(f"📤 Data sent to {client.remote_address}", Fore.GREEN)
            except websockets.exceptions.ConnectionClosed:
                self.clients.discard(client)
                self.log(f"🔌 Removing disconnected client: {client.remote_address}", Fore.YELLOW)
            except Exception as e:
                self.clients.discard(client)
                self.log(f"❌ Error sending to client {client.remote_address}: {e}", Fore.RED)

    async def broadcast_server_info(self, server_data):
        """Broadcast server information to all clients"""
        # Format data for Roblox client
        formatted_data = f"name={server_data.get('name', '')}|money={server_data.get('money', 0)}|players={server_data.get('players', '')}|job_id={server_data.get('job_id', '')}|script={server_data.get('script', '')}|is_10m_plus={server_data.get('is_10m_plus', False)}"

        await self.send_to_clients(formatted_data)

    def get_connected_clients_count(self):
        """Get number of connected clients"""
        return len(self.clients)

    async def reconnect_client(self, client_address):
        """Handle client reconnection"""
        self.log(f"🔄 Client reconnection requested: {client_address}", Fore.YELLOW)
        self.log("✅ Client reconnection handled", Fore.GREEN)

def start_websocket_server():
    """Start the WebSocket server in a new event loop"""
    server = RobloxWebSocketServer()
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(server.start())
