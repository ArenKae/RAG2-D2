# RAG2-D2

Mini pipeline RAG sur un corpus encyclopédique Star Wars structuré en JSON.

## Objectif

- Charger des entrées encyclopédiques JSON
- Générer des embeddings
- Indexer les chunks dans Qdrant
- Rechercher les passages pertinents
- Générer une réponse sourcée via un LLM
- Interagir avec le système via une UI React simple

## Architecture

```txt
React frontend
  -> FastAPI backend
    -> Embedding service
    -> Qdrant vector database
    -> LLM service