
from fastapi import FastAPI

app = FastAPI(
    title="Universal Inventory API",
    version="0.1.0"
)

@app.get("/")
def root():
    return {
        "app": "Universal Inventory",
        "status": "running",
        "version": "0.1.0"
    }

@app.get("/health")
def health():
    return {"status": "healthy"}
  
