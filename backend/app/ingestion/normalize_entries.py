def is_usable_entry(entry: dict) -> bool:
    content = entry.get("content", "").strip()
    metadata = entry.get("metadata", {})

    if not content:
        return False

    if metadata.get("is_alias") is True:
        return False

    return True

def build_indexable_text(entry: dict) -> str:
    title = entry.get("title", "").strip()
    content = entry.get("content", "").strip()

    return f"Title: {title}\n\n{content}"

def build_payload(entry: dict, chunk_text: str, chunk_index: int) -> dict:
    metadata = entry.get("metadata", {})

    return {
        "entry_id": entry.get("id"),
        "title": entry.get("title"),
        "text": chunk_text,
        "chunk_index": chunk_index,

        "source": metadata.get("source"),
        "source_type": metadata.get("source_type"),
        "language": metadata.get("language"),
        "continuity": metadata.get("continuity"),
        "entry_index": metadata.get("entry_index"),
        "title_slug": metadata.get("title_slug"),
        "page": metadata.get("page"),
        "is_alias": metadata.get("is_alias", False),
        "alias_target": metadata.get("alias_target"),
    }