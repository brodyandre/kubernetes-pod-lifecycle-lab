import os
import signal
import threading
import time
from datetime import datetime, timezone

from flask import Flask, jsonify, request

app = Flask(__name__)

PORT = 8080
GRACEFUL_SHUTDOWN_SECONDS = int(os.getenv("GRACEFUL_SHUTDOWN_SECONDS", "5"))
is_shutting_down = False


def now_utc() -> str:
    return datetime.now(timezone.utc).isoformat()


def graceful_shutdown() -> None:
    print(
        f"[{now_utc()}] Iniciando encerramento gracioso "
        f"({GRACEFUL_SHUTDOWN_SECONDS}s).",
        flush=True,
    )
    time.sleep(GRACEFUL_SHUTDOWN_SECONDS)
    print(f"[{now_utc()}] Encerramento finalizado.", flush=True)
    os._exit(0)


def handle_sigterm(signum: int, _frame) -> None:
    global is_shutting_down
    signal_name = signal.Signals(signum).name

    if is_shutting_down:
        return

    is_shutting_down = True
    print(f"[{now_utc()}] Sinal {signal_name} recebido.", flush=True)

    # SIGTERM pode ser tratado pela aplicacao para finalizar tarefas em andamento.
    # SIGKILL (kill -9) NAO pode ser interceptado nem tratado pelo processo.
    threading.Thread(target=graceful_shutdown, daemon=True).start()


signal.signal(signal.SIGTERM, handle_sigterm)


@app.before_request
def log_request() -> None:
    print(
        f"[{now_utc()}] Requisicao recebida: {request.method} {request.path}",
        flush=True,
    )


@app.get("/")
def index():
    return jsonify({"message": "Aplicacao rodando com sucesso."}), 200


@app.get("/health")
def health():
    return jsonify({"status": "OK"}), 200


if __name__ == "__main__":
    print(f"[{now_utc()}] Aplicacao iniciada na porta {PORT}.", flush=True)
    app.run(host="0.0.0.0", port=PORT, debug=False)
