# Basic chunking.
# Cut in the midle of words and sentences, doesn't preserve text structure.
# Later, implement : 
# - cut by sentences/paragraphs
# - token-based chunking (LLM-aware)
# - smart overlap (phrase boundary)

def chunk_text(text: str, max_chars: int = 900, overlap: int = 150) -> list[str]:
    text = text.strip()

    if len(text) <= max_chars:
        return [text]

    chunks = []
    start = 0

    while start < len(text):
        end = start + max_chars
        chunk = text[start:end].strip()	# Create a substring of text from start to end (excluded)

        if chunk:
            chunks.append(chunk)

		# ~150 chars of overlap is crucial so that the next chunk doesn't lose too much context
        start = end - overlap

        if start < 0:
            start = 0

    return chunks