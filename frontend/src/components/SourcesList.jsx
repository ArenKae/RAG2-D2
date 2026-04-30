export default function SourcesList({ sources }) {
  if (!sources || sources.length === 0) {
    return null;
  }

  return (
    <section>
      <h2>Sources</h2>

      {sources.map((source, index) => (
        <article key={`${source.entry_id}-${source.chunk_index}-${index}`}>
          <h3>{source.title}</h3>

          <p>
            <strong>Score:</strong> {source.score?.toFixed(4)}
          </p>

          <p>
            <strong>Source:</strong> {source.source}, page {source.page}
          </p>

          <details>
            <summary>Show retrieved chunk</summary>
            <p>{source.text}</p>
          </details>
        </article>
      ))}
    </section>
  );
}