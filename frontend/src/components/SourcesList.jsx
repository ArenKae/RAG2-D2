function getScoreClass(score) {
  if (score >= 0.8) return "score-high";
  if (score >= 0.6) return "score-medium";
  return "score-low";
}

export default function SourcesList({ sources }) {
  if (!sources || sources.length === 0) {
    return null;
  }

  return (
    <section className="sources-panel">
      <header className="sources-header">
        <div className="sources-icon">▧</div>

        <div>
          <h2>Sources</h2>
          <p>Documents retrieved within the vector database (top-k).</p>
        </div>
      </header>

      <div className="sources-list">
        {sources.map((source, index) => (
          <article
            className="source-card"
            key={`${source.entry_id}-${source.chunk_index}-${index}`}
          >
            <div className="source-rank">{index + 1}</div>

            <div className="source-thumbnail">
              {source.source_type?.[0]?.toUpperCase() || "S"}
            </div>

            <div className="source-content">
              <h3>{source.title}</h3>

              <p className="source-meta">
                {source.source}
                {source.page ? ` — page ${source.page}` : ""}
              </p>

              <div className="source-tags">
                {source.source_type && <span>{source.source_type}</span>}
                {source.page && <span>p. {source.page}</span>}
                {source.chunk_index !== undefined && (
                  <span>chunk {source.chunk_index}</span>
                )}
              </div>

              <details className="source-details">
                <summary>Inspect chunk</summary>
                <p>{source.text}</p>
              </details>
            </div>

            <div className="source-score-block">
              <span>Score</span>
              <strong className={getScoreClass(source.score)}>
                {source.score?.toFixed(2) ?? "—"}
              </strong>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}