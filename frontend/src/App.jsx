import { useState } from "react";

import AskForm from "./components/AskForm";
import AnswerPanel from "./components/AnswerPanel";
import SourcesList from "./components/SourcesList";

const API_BASE_URL = "http://localhost:8000";

export default function App() {
  const [question, setQuestion] = useState("");
  const [answer, setAnswer] = useState("");
  const [sources, setSources] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  async function handleSubmit(event) {
    event.preventDefault();

    setLoading(true);
    setError("");
    setAnswer("");
    setSources([]);

    try {
      const params = new URLSearchParams({
        q: question,
        limit: "5",
      });

      const response = await fetch(`${API_BASE_URL}/ask?${params.toString()}`);

      if (!response.ok) {
        throw new Error(`Request failed with status ${response.status}`);
      }

      const data = await response.json();

      setAnswer(data.answer);
      setSources(data.sources);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <main>
      <h1>RAG2-D2</h1>

      <AskForm
        question={question}
        setQuestion={setQuestion}
        onSubmit={handleSubmit}
        loading={loading}
      />

      {error && <p>{error}</p>}

      <AnswerPanel answer={answer} />
      <SourcesList sources={sources} />
    </main>
  );
}