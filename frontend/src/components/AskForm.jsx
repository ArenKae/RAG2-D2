export default function AskForm({ question, setQuestion, onSubmit, loading }) {
  return (
    <form onSubmit={onSubmit}>
      <textarea
        value={question}
        onChange={(event) => setQuestion(event.target.value)}
        placeholder="Ask a Star Wars lore question..."
        rows={4}
      />

      <button type="submit" disabled={loading || !question.trim()}>
        {loading ? "Searching..." : "Ask"}
      </button>
    </form>
  );
}