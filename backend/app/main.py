from fastapi import FastAPI

app = FastAPI(title="RAG2-D2")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/")
def root():
    return {
        "message": "RAG2-D2",
        "status": "running"
    }