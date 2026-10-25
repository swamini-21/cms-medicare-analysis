import pandas as pd
import pytest
import requests
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


class FakeResponse:
    def __init__(self, status_code, payload=None, headers=None):
        self.status_code = status_code
        self._payload = payload
        self.headers = headers or {}

    def json(self):
        return self._payload

    def raise_for_status(self):
        if self.status_code >= 400:
            raise requests.HTTPError(f"{self.status_code} error")


def patch_api(monkeypatch, responses):
    """Make requests.get return the given responses in order; record sleep calls."""
    it = iter(responses)
    sleeps = []
    monkeypatch.setattr(ingest.requests, "get", lambda *a, **k: next(it))
    monkeypatch.setattr(ingest.time, "sleep", sleeps.append)
    return sleeps


def test_fetch_page_retries_on_429_then_succeeds(monkeypatch):
    sleeps = patch_api(
        monkeypatch,
        [FakeResponse(429), FakeResponse(429), FakeResponse(200, [{"a": 1}])],
    )

    assert ingest.fetch_page("http://fake", 1000, 0) == [{"a": 1}]
    assert sleeps == [5, 10]  # exponential backoff


def test_fetch_page_honors_retry_after_header(monkeypatch):
    sleeps = patch_api(
        monkeypatch,
        [FakeResponse(429, headers={"Retry-After": "3"}), FakeResponse(200, [])],
    )

    ingest.fetch_page("http://fake", 1000, 0)

    assert sleeps == [3]


def test_fetch_page_gives_up_after_max_retries(monkeypatch):
    sleeps = patch_api(monkeypatch, [FakeResponse(429)] * 3)

    with pytest.raises(RuntimeError):
        ingest.fetch_page("http://fake", 1000, 0, retries=3)

    assert sleeps == [5, 10, 20]


def test_fetch_page_raises_on_other_http_errors(monkeypatch):
    sleeps = patch_api(monkeypatch, [FakeResponse(500)])

    with pytest.raises(requests.HTTPError):
        ingest.fetch_page("http://fake", 1000, 0)

    assert sleeps == []  # no retry for non-429 errors