from fastapi import FastAPI
from fastmcp import FastMCP
from mcp.server.fastmcp import FastMCP
from mcp.server.sse import SseServerTransport
from starlette.applications import Starlette
from starlette.routing import Mount, Route


#Defining some end points to test

app = FastAPI(title="REST API using FastAPI EndPoints")

@app.get("/")
async def root():
    return {"message": "Server Started"}   

@app.get("/health")
async def health():
    return {"status": "ok"} 



##############################################

mcp = FastMCP("mcp_calculator_server")


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

###########################################################################

# Defining tools
# This is a simple calculator tool. 
@mcp.tool()
def add(a: int, b: int)-> int:
    """
    This function is used to add two numbers

    Args:
        a (int): First number to be added
        b (int): Second number to be added

    Returns:
        int: Sum of numbers a and b
    """
    return a+b 

@mcp.tool()
def substract(a: int, b: int)-> int:
    """
    This function is used to substract numbers

    Args:
        a (int): First number to be substracted
        b (int): Second number to be substracted

    Returns:
        int: difference of two numbers
    """
    return a-b

@mcp.tool()
def multiply(a:int, b: int) -> int:
    """
    This function is used to multiply two numbers

    Args:
        a (int): First number to be multiplied
        b (int): Second number to be multiplied

    Returns:
        int: Multiplication value of two numbers
   
    """
    return a * b


@mcp.tool()
def divide(a:int, b: int) -> float:
    """
    This function is used to divide two numbers

    Args:
        a (int): First number to be divisioned
        b (int): Second number to be divisioned

    Returns:
        int: Division value of two numbers
   
    """
    return a / b
