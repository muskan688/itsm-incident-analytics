"""Load the UCI incident event log into PostgreSQL (schema raw, every column as text).

Raw means raw: no cleaning here. The '?' values, odd date formats and wrong
types are handled later by dbt (staging models), so the original data stays
available in the database.

    python src/load_raw.py
"""
import csv
import os
from pathlib import Path

import psycopg
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent.parent
CSV_PATH = ROOT / "data" / "raw" / "incident_event_log.csv"

load_dotenv(ROOT / ".env")


def main() -> None:
    url = os.environ.get("DATABASE_URL")
    if not url:
        raise SystemExit("DATABASE_URL is not set. Copy .env.example to .env and fill it in.")
    if not CSV_PATH.exists():
        raise SystemExit(f"{CSV_PATH} not found. See the README for the download link.")

    with open(CSV_PATH, newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        columns = [c.strip() for c in next(reader)]
        column_sql = ", ".join(f'"{c}" text' for c in columns)

        with psycopg.connect(url) as conn:
            conn.execute("create schema if not exists raw")
            # Create once and empty on every run. Dropping would fail because the dbt views depend on it.
            conn.execute(f"create table if not exists raw.incident_events (row_id integer, {column_sql})")
            conn.execute("truncate raw.incident_events")
            n = 0
            with conn.cursor() as cur:
                with cur.copy("copy raw.incident_events from stdin") as copy:
                    for n, row in enumerate(reader, start=1):
                        copy.write_row([n] + row)  # row_id keeps the original file order
            total = conn.execute("select count(*), count(distinct number) from raw.incident_events").fetchone()
    print(f"loaded {total[0]:,} events for {total[1]:,} incidents into raw.incident_events")


if __name__ == "__main__":
    main()
