from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct

from app.config import QDRANT_URL, COLLECTION_NAME, EMBEDDING_SIZE


class QdrantService:
    def __init__(self):
        self.client = QdrantClient(url=QDRANT_URL)

    def recreate_collection(self):
        self.client.recreate_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=VectorParams(
                size=EMBEDDING_SIZE,
                distance=Distance.COSINE,
            ),
        )

	# Update/insert point into the collection
    def upsert_points(self, points: list[PointStruct]):
        self.client.upsert(
            collection_name=COLLECTION_NAME,
            points=points,
        )