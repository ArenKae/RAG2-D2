import sys

from app.services.embedding_service import EmbeddingService
from app.services.qdrant_service import QdrantService


def format_match(match) -> str:
    payload = match.payload or {}

    title = payload.get("title", "Unknown title")
    source = payload.get("source", "Unknown source")
    page = payload.get("page", "Unknown page")
    text = payload.get("text", "")

    preview = text[:700].replace("\n", " ")

    return (
        f"Score: {match.score:.4f}\n"
        f"Title: {title}\n"
        f"Source: {source}\n"
        f"Page: {page}\n"
        f"Text: {preview}\n"
    )


def main():
    if len(sys.argv) < 2:
        print("Usage: python -m app.scripts.search_sample \"your question\"")
        return

    query = sys.argv[1]

    embedding_service = EmbeddingService()
    qdrant_service = QdrantService()

    query_vector = embedding_service.embed_text(query)
    matches = qdrant_service.search(query_vector=query_vector, limit=5)

    print(f"Query: {query}")
    print(f"Matches: {len(matches)}")
    print("=" * 80)

    for match in matches:
        print(format_match(match))
        print("-" * 80)


if __name__ == "__main__":
    main()