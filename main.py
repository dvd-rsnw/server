from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from models import MsgPayload
import httpx

app = FastAPI(
    title="Server API", 
    docs_url="/docs",
    openapi_url="/api/openapi.json",
    servers=[
        {"url": "http://server.local:4599", "description": "Raspberry Pi deployment"}
    ]
)
messages_list: dict[int, MsgPayload] = {}

# Proxy configuration
MICROSERVICES = {
    "trains": "http://trains:4599"  # using Docker service name and port from docker-compose
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

# Proxy all /trains requests to the trains microservice
@app.api_route("/trains/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def trains_proxy(request: Request, path: str):
    return await proxy_request("trains", request)
