# Load project settings once and make them available to every workflow layer.
from dataclasses import dataclass
from pathlib import Path
import os

from dotenv import load_dotenv

load_dotenv()


@dataclass
class ProjectSettings:
    # Operational switches can be changed without editing Python code.
    use_ollama: bool = os.getenv("USE_OLLAMA", "false").lower() == "true"
    ollama_model: str = os.getenv("OLLAMA_MODEL", "llama3.2")
    confidence_threshold: float = float(os.getenv("CONFIDENCE_THRESHOLD", "80"))
    database_path: Path = Path(os.getenv("DATABASE_PATH", "insurance_claims.db"))
    claims_file: Path = Path(os.getenv("CLAIMS_FILE", "data/claims.csv"))
    policies_file: Path = Path(os.getenv("POLICIES_FILE", "data/policies.csv"))
    output_dir: Path = Path("outputs")
    report_dir: Path = Path("reports")
    guidelines_file: Path = Path(os.getenv("GUIDELINES_FILE", "data/clinical_guidelines.json"))
    reimbursement_rate: float = float(os.getenv("REIMBURSEMENT_RATE", "0.8"))
    ollama_retries: int = int(os.getenv("OLLAMA_RETRIES", "2"))
    ollama_timeout: float = float(os.getenv("OLLAMA_TIMEOUT", "30"))
    currency_code: str = os.getenv("CURRENCY_CODE", "EUR")
    currency_symbol: str = os.getenv("CURRENCY_SYMBOL", "€")
    auto_load_sample_data: bool = (
        os.getenv("AUTO_LOAD_SAMPLE_DATA", "true").lower() == "true"
    )


settings = ProjectSettings()
# Create output locations early so logging and reporting can use them safely.
settings.output_dir.mkdir(exist_ok=True)
settings.report_dir.mkdir(exist_ok=True)
