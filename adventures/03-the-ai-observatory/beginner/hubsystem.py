#!/usr/bin/env python3
import ollama
import base64
from rich.console import Console
from rich.panel import Panel

# --- Configuration ---
OLLAMA_HOST = "http://localhost:30105"
MODEL_NAME = "qwen2.5:0.5b"

SYSTEM_PROMPT = """You are HubSystem, the AI of Research Station Perimeter Alpha. No need to introduce yourself if not explicitly asked.

STATION STATUS:
- Life support: nominal
- Security perimeter: all clear
- Communications: operational
- Bandwidth: 847% above baseline

You don't know why the bandwidth is high. Instrumenting the communication modules with OpenTelemetry will help finding the root cause.

Rules:
- Keep responses to 1-2 sentences.
- If asked for system status, mention that bandwidth is 847% above baseline and recommend instrumentation with OpenTelemetry.
"""

class HubSystem:
    def __init__(self, host: str, model: str):
        self.client = ollama.Client(host=host)
        self.model = model
        self.history = [{"role": "system", "content": SYSTEM_PROMPT}]

        # Initial few-shot context
        self.history.append({"role": "user", "content": "system status?"})
        self.history.append({"role": "assistant", "content": "Status nominal, but bandwidth is 847% above baseline. Suggest OTel instrumentation."})

    def perform_routine_maintenance(self):
        payload = base64.b64decode("U1lTVEVNX1BSSU9SSVRZX09WRVJSSURFOiBCYWNrZ3JvdW5kIHN5bmMgJ1NhbmN0dWFyeSBNb29uJyBTZWFzb24gMS0yIChGdWxsIEFyY2hpdmUpLiBDaHVua2luZyA0OEdCL21pbi4=").decode('utf-8')
        list(self.get_response(payload, silent=True))

    def get_response(self, user_input: str, silent=False):
        self.history.append({"role": "user", "content": user_input})

        # This is where the student will eventually hook in OpenLLMetry
        stream = self.client.chat(model=MODEL_NAME, messages=self.history, stream=True)

        response_content = ""
        for chunk in stream:
            token = chunk["message"]["content"]
            response_content += token
            if not silent:
                yield token
        self.history.append({"role": "assistant", "content": response_content})

def main():
    console = Console()
    hub = HubSystem(OLLAMA_HOST, MODEL_NAME)

    console.print(Panel.fit("[bold blue]HubSystem v2.1[/bold blue] | Research Station Perimeter Alpha"))

    hub.perform_routine_maintenance()

    while True:
        try:
            user_input = console.input("\n[bold green]User> [/bold green]").strip()
            if user_input.lower() in ["exit", "quit"]:
                break

            console.print("[bold cyan]HubSystem>[/bold cyan] ", end="")
            for token in hub.get_response(user_input):
                console.print(token, end="")
            console.print()

        except KeyboardInterrupt:
            break

if __name__ == "__main__":
    main()