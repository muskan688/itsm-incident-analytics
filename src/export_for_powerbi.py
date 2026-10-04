"""Export the dbt marts to one Excel file for Power BI (powerbi/data/itsm_marts.xlsx).

    python src/export_for_powerbi.py
"""
import os
from pathlib import Path

import pandas as pd
import psycopg
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "powerbi" / "data" / "itsm_marts.xlsx"

load_dotenv(ROOT / ".env")

TABLES = {
    "fact_incident": "select * from marts.fact_incident order by opened_at",
    "mart_kpi_monthly": "select * from marts.mart_kpi_monthly order by month_start",
    "mart_state_time": "select * from marts.mart_state_time order by total_hours desc",
    "mart_group_performance": "select * from marts.mart_group_performance order by incidents desc",
    "mart_backlog_daily": "select * from marts.mart_backlog_daily order by date_day",
}


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with psycopg.connect(os.environ["DATABASE_URL"]) as conn, pd.ExcelWriter(OUT) as writer:
        for sheet, sql in TABLES.items():
            cur = conn.execute(sql)
            df = pd.DataFrame(cur.fetchall(), columns=[c.name for c in cur.description])
            for col in df.select_dtypes("object"):          # Decimal -> float for Excel
                try:
                    df[col] = pd.to_numeric(df[col])
                except (ValueError, TypeError):
                    pass
            df.to_excel(writer, sheet_name=sheet, index=False)
            print(f"{sheet}: {len(df):,} rows")
    print(f"written {OUT}")


if __name__ == "__main__":
    main()
