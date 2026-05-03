export default function AskForm({question, setQuestion, onSubmit, loading, onReset})
{
  return (
    <form className="ask-form" onSubmit={onSubmit}>
      <textarea
        value={question}
        onChange={(event) => setQuestion(event.target.value)}
        placeholder="Ask a Star Wars lore related question..."
        rows={2}
      />

      <button
        className="reset-button"
        type="button"
        onClick={onReset}
        disabled={loading}
        aria-label="Reset conversation"
        title="Reset"
      >
        ↻
      </button>

      <button
        className="submit-button"
        type="submit"
        disabled={loading || !question.trim()}
        aria-label="Send question"
        title="Ask"
      >
        ➤
      </button>
    </form>
  );
}