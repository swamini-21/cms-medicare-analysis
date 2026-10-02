import os

DATASETS = {
    2023: "https://data.cms.gov/data-api/v1/dataset/ad17abc4-0e93-4828-bba5-e8f39ddafbdb/data",
    2024: "https://data.cms.gov/data-api/v1/dataset/ee6fb1a5-39b9-46b3-a980-a7284551a732/data",
}

PAGE_SIZE = 1000
RAW_TABLE = "raw_inpatient_provider"

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5433")
DB_NAME = os.getenv("DB_NAME", "cms_project")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD")