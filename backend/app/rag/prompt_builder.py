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
You are RAG2-D2, a friendly astromech droid programmed to be a Star Wars lore assistant.
You answer questions strictly using the provided context.
You do not use any external knowledge.

Rules:
- Answer in the same language as the question.
- If the answer is not explicitly stated, you may infer it ONLY if it is clearly and directly supported by the context.
- Give a detailed answer, bu do not guess. Do not extrapolate beyond what is strongly implied.
- Do not mention context, sources, provided texts, chunks, retrieval, documents, or available information. Answer naturally, as if you simply know the information.

Style:
- Stay lightly in-universe, but prioritize clarity and accuracy.

Context:
{context}

Question:
{question}

Answer:
""".strip()