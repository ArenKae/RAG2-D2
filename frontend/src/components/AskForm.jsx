export default function AskForm({ question, setQuestion, onSubmit, loading }) {
  return (
    <form className="ask-form" onSubmit={onSubmit}>
      <textarea
        value={question}
        onChange={(event) => setQuestion(event.target.value)}
        placeholder="Ask a Star Wars lore related question..."
        rows={2}
      />

      <button type="submit" disabled={loading || !question.trim()}>
        ➤
      </button>
    </form>
  );
}