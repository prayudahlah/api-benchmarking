from fastapi import FastAPI

app = FastAPI()


@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "service is running"}
