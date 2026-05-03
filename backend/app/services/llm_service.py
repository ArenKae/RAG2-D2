import requests
import os

class LLMService:
    def __init__(self, model: str = "llama3.2"):
        self.model = os.getenv("OLLAMA_MODEL", "llama3.2:1b")
        self.base_url = os.getenv("OLLAMA_URL", "http://localhost:11434")

    def generate(self, prompt: str) -> str:
        response = requests.post(
            f"{self.base_url}/api/generate",
            json={
                "model": self.model,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.1,
                    "num_ctx": 4096
                }
            },
            timeout=500,
        )

        response.raise_for_status()
        return response.json().get("response", "").strip()