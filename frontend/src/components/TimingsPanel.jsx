function normalizeTimingValue(value)
{
  if (typeof value === "number") {
    return value;
  }
  if (typeof value === "string") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }
  if (value && typeof value === "object" && "parsedValue" in value)
    return normalizeTimingValue(value.parsedValue);
  return null;
}

function formatSeconds(value)
{
  if (value === null || value === undefined)
    return "—";
  return `${value.toFixed(3)}s`;
}

export default function TimingsPanel({ timings, timeout })
{
  if (!timings)
    return null;

  const timingRows = [
    ["Embedding", normalizeTimingValue(timings.embedding)],
    ["Qdrant search", normalizeTimingValue(timings.qdrant_search)],
    ["Prompt building", normalizeTimingValue(timings.prompt_building)],
    ["LLM generation", normalizeTimingValue(timings.llm_generation)],
    ["Total", normalizeTimingValue(timings.total)],
  ];

  const nonTotalRows = timingRows.filter(([label]) => label !== "Total");

  const validNonTotalValues = nonTotalRows
    .map(([, value]) => value)
    .filter((value) => typeof value === "number");

  const maxNonTotalTiming = validNonTotalValues.length > 0 ? Math.max(...validNonTotalValues) : null;

  return (
    <section className="timings-panel">
      <header className="timings-header">
        <div>
          <h2>Performance timings</h2>
          <p>Backend operation durations for the last query.</p>
        </div>

        <div className="timeout-pill">
          Timeout: <strong>{timeout}s</strong>
        </div>
      </header>

      <div className="timings-grid">
        {timingRows.map(([label, value]) => {
          const isTotal = label === "Total";
          const isSlowest = !isTotal && value === maxNonTotalTiming;

          return (
            <div
              className={`timing-card 
                ${isTotal ? "timing-card-total" : ""} 
                ${isSlowest ? "timing-card-slowest" : ""}`}
              key={label}
            >
              <span>{label}</span>
              <strong>{formatSeconds(value)}</strong>
            </div>
          );
        })}
      </div>
    </section>
  )
}