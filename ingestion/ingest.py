import logging
import time
import pandas as pd
import requests
from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect, text
from sqlalchemy.engine import URL

load_dotenv()  # must run before config is imported
from ingestion import config  # noqa: E402

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("ingest")


def fetch_page(url, size, offset, retries=5):
    for attempt in range(retries):
        r = requests.get(url, params={"size": size, "offset": offset}, timeout=60)
        if r.status_code == 429:
            try:
                wait = int(r.headers.get("Retry-After", ""))
            except ValueError:
                wait = 5 * 2**attempt
            log.warning(
                "Rate limited (429) at offset %s, waiting %ss (attempt %s/%s)",
                offset, wait, attempt + 1, retries,
            )
            time.sleep(wait)
            continue
        r.raise_for_status()
        return r.json()
    raise RuntimeError(f"Still rate limited after {retries} attempts at offset {offset}")


def fetch_all(url, size=config.PAGE_SIZE):
    rows, offset = [], 0
    while True:
        page = fetch_page(url, size, offset)
        if not page:
            break
        rows.extend(page)
        offset += size
    return rows


def get_engine():
    url = URL.create(
        "postgresql+psycopg2",
        username=config.DB_USER,
        password=config.DB_PASSWORD,
        host=config.DB_HOST,
        port=int(config.DB_PORT),
        database=config.DB_NAME,
    )
    return create_engine(url)


def load_year(engine, year, rows):
    df = pd.DataFrame(rows)
    df.columns = df.columns.str.lower()
    df["year"] = year
    with engine.begin() as conn:
        if inspect(conn).has_table(config.RAW_TABLE):
            conn.execute(
                text(f"DELETE FROM {config.RAW_TABLE} WHERE year = :y"), {"y": year}
            )
        df.to_sql(config.RAW_TABLE, conn, if_exists="append", index=False)
    return len(df)


def main():
    engine = get_engine()
    for year, url in config.DATASETS.items():
        log.info("Fetching %s", year)
        rows = fetch_all(url)
        n = load_year(engine, year, rows)
        log.info("Loaded %s rows for %s into %s", n, year, config.RAW_TABLE)


if __name__ == "__main__":
    main()