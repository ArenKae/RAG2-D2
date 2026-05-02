import json
from pathlib import Path
from uuid import uuid5, NAMESPACE_URL

from qdrant_client.models import PointStruct

from app.services.qdrant_service import QdrantService
from app.ingestion.chunk_entries import chunk_text
from app.services.embedding_service import EmbeddingService
from app.ingestion.normalize_entries import (
    is_usable_entry,
    build_indexable_text,
    build_payload,
)

RAW_DIR = Path(__file__).resolve().parents[2] / "data"

def load_entries() -> list[dict]:
    entries = []

    for path in sorted(RAW_DIR.glob("*.json")):
        with path.open("r", encoding="utf-8") as file:
            data = json.load(file)

        if not isinstance(data, list):
            raise ValueError(f"{path.name} should contain a JSON list")

        entries.extend(data)

    return entries

# Return a stable uuid string for the qdrant entry. uuid5 is deterministic :
# the same parameters will always produce the same id as output
def make_point_id(entry_id: str, chunk_index: int) -> str:
    raw_id = f"{entry_id}-chunk-{chunk_index}"
    return str(uuid5(NAMESPACE_URL, raw_id))


def main():
    entries = load_entries()
    usable_entries = []
    for entry in entries:
        if is_usable_entry(entry):
            usable_entries.append(entry)

    print(f"Loaded entries: {len(entries)}")
    print(f"Usable entries: {len(usable_entries)}")
    print(f"Indexing entries: {len(usable_entries)}")

    # Instanciate classes
    qdrant_service = QdrantService()
    embedding_service = EmbeddingService()

    print("Recreating Qdrant collection...")
    qdrant_service.recreate_collection()

    points = []
    total_points = 0
    BATCH_SIZE = 128
    
    for entry_index, entry in enumerate(usable_entries, start=1):
        indexable_text = build_indexable_text(entry)
        chunks = chunk_text(indexable_text)

        chunk_vectors = embedding_service.embed_texts(chunks)

        for chunk_index, (chunk, vector) in enumerate(zip(chunks, chunk_vectors)):
            # PointStruct is the format expected by the Qdrant client
            point = PointStruct(
                id=make_point_id(entry["id"], chunk_index),
                vector=vector,
                payload=build_payload(entry, chunk, chunk_index),
            )

            points.append(point)

			# Upsert points by batch (qdrant refuses requests bigger than the ~33mb limit)
            if len(points) >= BATCH_SIZE:
                qdrant_service.upsert_points(points)
                total_points += len(points)
                print(f"Upserted {total_points} points...")
                points = []

    if points:
        qdrant_service.upsert_points(points)
        total_points += len(points)

    print(f"Ingestion complete. Total points: {total_points}")


if __name__ == "__main__":
    main()