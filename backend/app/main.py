from fastapi import FastAPI

from app.services.embedding_service import EmbeddingService
from app.services.qdrant_service import QdrantService
from app.services.llm_service import LLMService
from app.rag.prompt_builder import build_rag_prompt

app = FastAPI(title="RAG2-D2")

embedding_service = EmbeddingService()
qdrant_service = QdrantService()
llm_service = LLMService()

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

@app.get("/ask")
def ask(q: str, limit: int = 5):
    query_vector = embedding_service.embed_text(q)
    matches = qdrant_service.search(query_vector=query_vector, limit=limit)

    prompt = build_rag_prompt(question=q, matches=matches)
    answer = llm_service.generate(prompt)

    sources = []

    for match in matches:
        payload = match.payload or {}

        sources.append(
            {
                "score": match.score,
                "entry_id": payload.get("entry_id"),
                "title": payload.get("title"),
                "source": payload.get("source"),
                "page": payload.get("page"),
                "chunk_index": payload.get("chunk_index"),
                "text": payload.get("text"),
            }
        )

    return {
        "question": q,
        "answer": answer,
        "sources": sources,
    }