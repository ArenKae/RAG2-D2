from fastapi import FastAPI

from app.services.embedding_service import EmbeddingService
from app.services.qdrant_service import QdrantService

app = FastAPI(title="RAG2-D2")

embedding_service = EmbeddingService()
qdrant_service = QdrantService()

@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/")
def root():
    return {
        "message": "RAG2-D2",
        "status": "running"
    }

@app.get("/search")
def search(q: str, limit: int = 5):
    query_vector = embedding_service.embed_text(q)
    matches = qdrant_service.search(query_vector=query_vector, limit=limit)

    results = []

    for match in matches:
        payload = match.payload or {}

        results.append(
            {
                "score": match.score,
                "entry_id": payload.get("entry_id"),
                "title": payload.get("title"),
                "text": payload.get("text"),
                "chunk_index": payload.get("chunk_index"),
                "source": payload.get("source"),
                "source_type": payload.get("source_type"),
                "language": payload.get("language"),
                "continuity": payload.get("continuity"),
                "page": payload.get("page"),
            }
        )

    return {
        "query": q,
        "limit": limit,
        "matches": results,
    }