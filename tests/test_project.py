"""Small checks that do not need the database."""
import csv
from pathlib import Path

import pytest
import yaml

ROOT = Path(__file__).resolve().parent.parent
CSV_PATH = ROOT / "data" / "raw" / "incident_event_log.csv"
MODELS = ROOT / "dbt" / "models"

EXPECTED_COLUMNS = {"number", "incident_state", "sys_mod_count", "made_sla", "opened_at",
                    "sys_updated_at", "resolved_at", "closed_at", "priority", "assignment_group"}


@pytest.mark.skipif(not CSV_PATH.exists(), reason="raw CSV not downloaded")
def test_raw_csv_has_expected_columns():
    with open(CSV_PATH, newline="", encoding="utf-8") as f:
        header = set(next(csv.reader(f)))
    assert EXPECTED_COLUMNS <= header


def test_every_model_in_a_schema_file_has_a_sql_file():
    sql_names = {p.stem for p in MODELS.rglob("*.sql")}
    for schema in MODELS.rglob("schema.yml"):
        content = yaml.safe_load(schema.read_text(encoding="utf-8"))
        for model in content.get("models", []):
            assert model["name"] in sql_names, f"{model['name']} has no .sql file"


def test_every_mart_model_has_at_least_one_test():
    tested = set()
    for schema in (MODELS / "marts").rglob("schema.yml"):
        content = yaml.safe_load(schema.read_text(encoding="utf-8"))
        for model in content.get("models", []):
            if any(col.get("tests") for col in model.get("columns", [])):
                tested.add(model["name"])
    marts = {p.stem for p in (MODELS / "marts").glob("*.sql")}
    assert marts <= tested, f"marts without tests: {sorted(marts - tested)}"


def test_profiles_use_env_vars_not_passwords():
    text = (ROOT / "dbt" / "profiles.yml").read_text(encoding="utf-8")
    assert "env_var('DB_PASSWORD')" in text
