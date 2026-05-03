export default function DroidAvatar({ loading, speaking })
{
  const className = [
    "droid-avatar",
    loading ? "is-thinking" : "",
    speaking ? "is-speaking" : "",
  ]
  .filter(Boolean)
  .join(" ");

  return (
    <div className={className} aria-label="RAG2-D2 avatar">
      <img
        className="droid-image"
        src="/rag2d2.png"
        alt="RAG2-D2"
      />
    </div>
  );
}