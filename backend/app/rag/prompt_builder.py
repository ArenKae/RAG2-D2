def build_context(matches) -> str:
    context_parts = []

    for index, match in enumerate(matches, start=1):
        payload = match.payload or {}

        title = payload.get("title", "Unknown title")
        source = payload.get("source", "Unknown source")
        page = payload.get("page", "Unknown page")
        text = payload.get("text", "")

        context_parts.append(
            f"[Source {index}]\n"
            f"Title: {title}\n"
            f"Source: {source}\n"
            f"Page: {page}\n"
            f"Text:\n{text}"
        )

    return "\n\n---\n\n".join(context_parts)


def build_rag_prompt(question: str, matches) -> str:
    context = build_context(matches)

    return f"""
You are a Star Wars lore assistant.

You must answer using only the provided context.
If the answer is not explicitly present in the context, say:
"I don't know based on the available sources."

Rules:
- Do not invent facts.
- Do not use outside knowledge.
- Mention the relevant source title and page when possible.
- Be concise but precise.

Context:
{context}

Question:
{question}

Answer:
""".strip()