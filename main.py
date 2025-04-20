from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from models import MsgPayload
import httpx

app = FastAPI()
messages_list: dict[int, MsgPayload] = {}

# Proxy configuration
MICROSERVICES = {
    "trains": "http://trains:4600"  # using Docker service name and port from docker-compose
}

async def proxy_request(service: str, request: Request):
    if service not in MICROSERVICES:
        return JSONResponse(
            status_code=404,
            content={"error": f"Service {service} not found"}
        )
    
    client = httpx.AsyncClient(base_url=MICROSERVICES[service])
    url = request.url.path.replace(f"/{service}", "")
    
    try:
        response = await client.request(
            method=request.method,
            url=url,
            headers=request.headers,
            params=request.query_params,
            content=await request.body()
        )
        return JSONResponse(
            content=response.json(),
            status_code=response.status_code
        )
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": f"Error proxying to {service}: {str(e)}"}
        )
    finally:
        await client.aclose()

@app.get("/")
def root() -> dict[str, str]:
    return {"message": "Server API"}

# About page route
@app.get("/about")
def about() -> dict[str, str]:
    return {"message": "This is the about page."}

# Route to add a message
@app.post("/messages/{msg_name}/")
def add_msg(msg_name: str) -> dict[str, MsgPayload]:
    # Generate an ID for the item based on the highest ID in the messages_list
    msg_id = max(messages_list.keys()) + 1 if messages_list else 0
    messages_list[msg_id] = MsgPayload(msg_id=msg_id, msg_name=msg_name)
    return {"message": messages_list[msg_id]}

# Route to list all messages
@app.get("/messages")
def message_items() -> dict[str, dict[int, MsgPayload]]:
    return {"messages": messages_list}

# Proxy all /trains requests to the trains microservice
@app.api_route("/trains/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def trains_proxy(request: Request, path: str):
    return await proxy_request("trains", request)
