from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
import requests
import json
from typing import Any
import uvicorn

app = FastAPI()

LATTICE_SERVICE_DNS = "skills-app-service-skills-app-service-network.vpc-lattice-svcs.ap-southeast-1.on.aws"

class PrettyJSONResponse(JSONResponse):
    def render(self, content: Any) -> bytes:
        return (json.dumps(content, indent=2) + "\n").encode("utf-8")

app.default_response_class = PrettyJSONResponse

@app.get("/health")
async def health_check():
    return {"status": "OK"}

@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def proxy_request(request: Request, path: str):
    try:
        url = f"http://{LATTICE_SERVICE_DNS}/{path}"
        
        headers = dict(request.headers)
        headers.pop("host", None)
        
        body = None
        if request.method in ["POST", "PUT"]:
            body = await request.body()
        
        response = requests.request(
            method=request.method,
            url=url,
            headers=headers,
            data=body,
            params=dict(request.query_params),
            timeout=30
        )
        
        return JSONResponse(
            status_code=response.status_code,
            content=response.json() if response.content else {}
        )
        
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Service unavailable: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
