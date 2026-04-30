export default function AnswerPanel({ answer }) {
  if (!answer) {
    return null;
  }

  return (
    <section>
      <h2>Answer</h2>
      <p>{answer}</p>
    </section>
  );
}