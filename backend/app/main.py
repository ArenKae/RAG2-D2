import time
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.services.embedding_service import EmbeddingService
from app.services.qdrant_service import QdrantService
from app.services.llm_service import LLMService
from app.rag.prompt_builder import build_rag_prompt

app = FastAPI(title="RAG2-D2")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
    t0 = time.perf_counter()

    query_vector = embedding_service.embed_text(q)
    t1 = time.perf_counter()

    matches = qdrant_service.search(query_vector=query_vector, limit=limit)
    t2 = time.perf_counter()

    prompt = build_rag_prompt(question=q, matches=matches)
    t3 = time.perf_counter()

    answer = llm_service.generate(prompt)
    t4 = time.perf_counter()

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
        "model": llm_service.model,
        "timings": {
            "embedding": round(t1 - t0, 3),
            "qdrant_search": round(t2 - t1, 3),
            "prompt_building": round(t3 - t2, 3),
            "llm_generation": round(t4 - t3, 3),
            "total": round(t4 - t0, 3),
        },
        "sources": sources,
    }