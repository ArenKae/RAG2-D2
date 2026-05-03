export default function AnswerPanel({ answer }) {
  if (!answer) {
    return null;
  }

  return (
    <div className="message-row assistant-row">
      <div className="message-bubble assistant-bubble">
        <p>{answer}</p>
      </div>
    </div>
  );
}