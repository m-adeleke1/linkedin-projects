# Creating FastAPI application and couple of end points to test once deployed

from fastapi import FastAPI
from fastmcp import FastMCP
from mcp.server.fastmcp import FastMCP
from mcp.server.sse import SseServerTransport
from starlette.applications import Starlette
from starlette.routing import Mount, Route
import uvicorn

#Defining some end points to test

app = FastAPI(title="REST API using FastAPI EndPoints")

@app.get("/")
async def root():
    return {"message": "Server Started"}   

@app.get("/health")
async def health():
    return {"status": "ok"}

# Creating MCP instance and SSE End point
# The SSE end point is required to capture SSE requests coming from MCP clients.

mcp = FastMCP("mcp_weather_server")

def create_sse_server(mcp: FastMCP):
    """Create a Starlette app that handles SSE connections and message handling"""
    transport = SseServerTransport("/messages/")

    # Define handler functions
    async def handle_sse(request):
        async with transport.connect_sse(
            request.scope, request.receive, request._send
        ) as streams:
            await mcp._mcp_server.run(
                streams[0], streams[1], mcp._mcp_server.create_initialization_options()
            )

    # Create Starlette routes for SSE and message handling
    routes = [
        Route("/sse/", endpoint=handle_sse),
        Mount("/messages/", app=transport.handle_post_message),
    ]

    # Create a Starlette app
    return Starlette(routes=routes)

app.mount("/", create_sse_server(mcp))

# Creating MCP tools

# in main.py
# Defining tools
# For the example I am using hardcoded weather data. In real scenarios it can be integrated with real weather sources.
@mcp.tool()
def get_weather(city: str) -> str:
    """
    Get the weather for a given city.
    
    args:
        city (str): The name of the city to get the weather for.
    returns:
        str: The weather for the given city.
    """
    result = f"""
            *************************
            Weather in {city} is sunny
            Temperature - 30 deg
            Humidity - 70%
            Cloud Cover - 60%
            Visibility - 7 KM
            ****************************
    """
    return result
