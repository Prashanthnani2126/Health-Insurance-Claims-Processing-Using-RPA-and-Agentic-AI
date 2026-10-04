# Health Insurance Claims Processing using RPA and Agentic AI

This Python 3.11+ university assessment demonstrates two distinct forms of automation in one To-Be process:

`Claim submitted → extraction → eligibility/coverage → documents → medical necessity → confidence gateway → automatic decision or human review → payment notification`

- **RPA-style automation** performs deterministic import, normalisation, policy and document validation, duplicate detection, transparent risk indicators, reimbursement calculation, notices, audit logging, and exports.
- **Agentic AI automation** reviews the fictional clinical context and local guideline file through optional Ollama. Its Pydantic-validated result contains `decision`, `confidence`, `reasoning`, `recommended_action`, `evidence_used`, and `risk_flags`. A deterministic fallback is used when Ollama is disabled or unavailable.

This is an academic demonstration. It is not a real doctor, medical device, production claims system, or substitute for qualified clinical and insurance review. All sample people and claims are fictional.

The demonstration dataset is localised to Ireland. Names and providers are
fictional Irish examples, dates use ISO format, and all monetary values are in
euro (`EUR`).

## Windows and VS Code setup

1. Install Python 3.11 or later and VS Code with the Python extension.
2. Open this project folder in VS Code.
3. Open **Terminal → New Terminal**, then run:

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
Copy-Item .env.example .env
```

If PowerShell blocks activation, run `Set-ExecutionPolicy -Scope Process Bypass` in that terminal and activate again. Select `.venv\Scripts\python.exe` with **Python: Select Interpreter**.

## Verified commands

```powershell
python app.py
python run_demo.py
pytest
uvicorn web.main:app --reload
```

Open <http://127.0.0.1:8000>. The dashboard provides Dashboard, Upload Claim, Claims, Claim Details, AI Decisions, Human Review Queue, Payments, Reports, and Analytics pages.

For one-click Windows operation, double-click `start.bat` to launch the
dashboard and open it in the browser. Double-click `stop.bat` to stop the
server. Runtime logs are saved as `outputs/dashboard.out.log` and
`outputs/dashboard.err.log`. If port 8000 is already occupied, the launcher
automatically selects the first free port from 8001 through 8010 and displays
the selected URL.

For a fresh demonstration, delete the demo database manually or set a new path in `.env`, for example `DATABASE_PATH=demo_run.db`. Re-running against the same database intentionally identifies the claim IDs as duplicates.

## Running without Ollama

The default `.env.example` sets `USE_OLLAMA=false`. The local fallback uses explicit rules, returns the same validated schema, and escalates incomplete, ambiguous, contradictory, and unmatched cases. No model download or network access is required.

On the first dashboard launch, `AUTO_LOAD_SAMPLE_DATA=true` automatically
processes `data/claims.csv` when the active database has no claims. It never
reloads or overwrites a database that already contains claim records.

## Optional Ollama

1. Install Ollama for Windows from <https://ollama.com/download/windows>.
2. In a terminal, download and test a local model:

```powershell
ollama pull llama3.2
ollama run llama3.2
```

3. Set:

```text
USE_OLLAMA=true
OLLAMA_MODEL=llama3.2
```

Ollama must be running locally. If it is unavailable or returns invalid JSON, retry handling logs the problem and safely uses the fallback. Models can be changed through `OLLAMA_MODEL`; suitability and hardware requirements vary.

## Inputs, configuration, and outputs

Claims can be imported from CSV, JSON, or field-labelled, text-based PDF files. `pdfplumber` performs PDF extraction. Optional OCR uses `pytesseract` and OpenCV; OCR also requires the external Tesseract executable installed and available on `PATH`.

Configuration lives in `.env`; paths, confidence threshold, retry count, model, and reimbursement default are not hard-coded into workflow logic.

- `outputs/`: JSON decisions, notices, and central log
- `reports/`: individual ReportLab PDFs, processed-claims CSV, audit CSV, summary JSON, and Matplotlib charts
- SQLite: policies, claims, documents, AI decisions, human reviews, payments, audits, and metrics

Approved automated claims create a scheduled payment record. Escalations preserve the original AI recommendation and enter the review queue. A reviewer can approve/reject and add notes; a human approval then creates a payment.

## Project structure

```text
app/
  ai_agent/       optional Ollama and deterministic fallback
  database/       safe table initialisation and repository functions
  models/         typed claim and validated decision models
  rpa/            import, policy, documents, duplicates, and risk rules
  services/       orchestration, notices, payments, and reports
web/              FastAPI routes and Bootstrap/Jinja templates
data/             20 fictional claims, policies, and local guidelines
tests/            important rule and workflow branches
```

## Screenshots for assessment submission

Add captured images after running the project:

- `docs/screenshots/bpmn-to-be.png` — BPMN To-Be process
- `docs/screenshots/dashboard.png` — dashboard KPIs and audit activity
- `docs/screenshots/ai-result.png` — structured AI assessment
- `docs/screenshots/human-review.png` — reviewer decision form
- `docs/screenshots/report-output.png` — PDF/CSV/chart outputs

## Scope notes

Risk flags are transparent verification indicators, not accusations. The local guideline file is intentionally small and fictional. Authentication, secure storage, regulatory validation, production-grade coding/terminology services, and real payment integrations are deliberately outside this academic project.
