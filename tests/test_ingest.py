import pandas as pd
from sqlalchemy import create_engine

from ingestion import config, ingest


def test_fetch_all_collects_every_page(monkeypatch):
    pages = [[{"a": 1}, {"a": 2}], [{"a": 3}], []]
    calls = iter(pages)
    monkeypatch.setattr(ingest, "fetch_page", lambda url, size, offset: next(calls))

    assert ingest.fetch_all("http://fake", size=2) == [{"a": 1}, {"a": 2}, {"a": 3}]


def test_fetch_all_returns_empty_list_when_no_data(monkeypatch):
    monkeypatch.setattr(ingest, "fetch_page", lambda url, size, offset: [])

    assert ingest.fetch_all("http://fake") == []


def test_get_engine_uses_config_settings(monkeypatch):
    monkeypatch.setattr(config, "DB_HOST", "dbhost")
    monkeypatch.setattr(config, "DB_PORT", "5555")
    monkeypatch.setattr(config, "DB_PASSWORD", "secret")

    engine = ingest.get_engine()

    assert engine.url.host == "dbhost"
    assert engine.url.port == 5555


def test_load_year_is_idempotent():
    engine = create_engine("sqlite://")
    rows = [{"Rndrng_Prvdr_CCN": "1"}, {"Rndrng_Prvdr_CCN": "2"}]

    ingest.load_year(engine, 2023, rows)
    ingest.load_year(engine, 2023, rows)  # run twice

    count = pd.read_sql(f"SELECT COUNT(*) AS n FROM {config.RAW_TABLE}", engine)["n"][0]
    assert count == 2