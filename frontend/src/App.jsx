import {  useMemo, useState } from "react";

import AskForm from "./components/AskForm";
import AnswerPanel from "./components/AnswerPanel";
import SourcesList from "./components/SourcesList";
import DroidAvatar from "./components/DroidAvatar";
import TypewriterText from "./components/TypewriterText";
import { droidIdleLines } from "./data/droidLines";


import "./App.css";

const API_BASE_URL = "http://localhost:8000";

export default function App() {
  const [question, setQuestion] = useState("");
  const [lastQuestion, setLastQuestion] = useState("");
  const [answer, setAnswer] = useState("");
  const [sources, setSources] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const idleLine = useMemo(() => {
    const randomIndex = Math.floor(Math.random() * droidIdleLines.length);
    return droidIdleLines[randomIndex];
  }, []);

  async function handleSubmit(event) {
    event.preventDefault();

    const trimmedQuestion = question.trim();

    if (!trimmedQuestion) {
      return;
    }

    setLastQuestion(trimmedQuestion);
    setLoading(true);
    setError("");
    setAnswer("");
    setSources([]);

    try {
      const params = new URLSearchParams({
        q: trimmedQuestion,
        limit: "5",
      });

      const response = await fetch(`${API_BASE_URL}/ask?${params.toString()}`);

      if (!response.ok) {
        throw new Error(`Request failed with status ${response.status}`);
      }

      const data = await response.json();

      setAnswer(data.answer);
      setSources(data.sources || []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="app-shell">
      <section className="chat-card">
        <header className="chat-header">
          <div>
            <h1>RAG2-D2</h1>
            <p>Star Wars lore assistant</p>
          </div>

          <span className="rag-badge">Powered by RAG</span>
        </header>

        <section className="dialog-window">
          {lastQuestion && (
            <div className="message-row user-row">
              <div className="message-bubble user-bubble">{lastQuestion}</div>
            </div>
          )}

         <div className="assistant-zone">
          <div className="assistant-character">
          {!answer && (
            <div className="thinking-bubble">
              {loading ? (
                <>
                  <span>RAG2-D2 is thinking</span>
                  <div className="typing-dots">
                    <span />
                    <span />
                    <span />
                  </div>
                </>
              ) : (
                <TypewriterText text={idleLine} speed={50} />
              )}
            </div>
          )}

            <DroidAvatar loading={loading} speaking={Boolean(answer)} />
          </div>

            <AnswerPanel answer={answer} />
         </div>
        </section>

        {error && <p className="error-message">{error}</p>}

        <AskForm
          question={question}
          setQuestion={setQuestion}
          onSubmit={handleSubmit}
          loading={loading}
        />
      </section>

      <SourcesList sources={sources} />
    </main>
  );
}