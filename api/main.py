import os
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
from starlette.concurrency import run_in_threadpool

app = FastAPI()

FILES_DIR = Path(os.getenv("FILES_DIR", "/app/files"))
CHUNK_SIZE = 64 * 1024


@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "service is running"}


@app.get("/files/{filename}")
async def serve_file(filename: str):
    root = FILES_DIR.resolve()
    target = (root / filename).resolve()

    if not target.is_relative_to(root) or not target.is_file():
        raise HTTPException(status_code=404, detail="File not found")

    async def stream():
        with open(target, "rb") as f:
            while True:
                chunk = await run_in_threadpool(f.read, CHUNK_SIZE)
                if not chunk:
                    break
                yield chunk

    return StreamingResponse(
        stream(),
        media_type="application/octet-stream",
        headers={
            "Content-Length": str(target.stat().st_size),
            "Content-Disposition": f'attachment; filename="{target.name}"',
        },
    )
