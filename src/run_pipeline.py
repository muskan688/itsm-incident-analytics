"""Run the whole pipeline: load raw data, build and test the dbt models, export for Power BI.

    python src/run_pipeline.py
"""
from pathlib import Path

from dbt.cli.main import dbtRunner
from dotenv import load_dotenv

import export_for_powerbi
import load_raw

ROOT = Path(__file__).resolve().parent.parent
DBT_DIR = str(ROOT / "dbt")

load_dotenv(ROOT / ".env")


def main() -> None:
    print("== 1. load raw data ==")
    load_raw.main()

    print("\n== 2. dbt build (models + tests) ==")
    result = dbtRunner().invoke(["--no-use-colors", "build", "--profiles-dir", DBT_DIR, "--project-dir", DBT_DIR])
    if not result.success:
        raise SystemExit("dbt build failed: a model or an error-level test failed")

    print("\n== 3. export for Power BI ==")
    export_for_powerbi.main()


if __name__ == "__main__":
    main()
