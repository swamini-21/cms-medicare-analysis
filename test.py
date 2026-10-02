import requests

url = "https://data.cms.gov/data-api/v1/dataset/ee6fb1a5-39b9-46b3-a980-a7284551a732/data"
size, offset, total, pages = 1000, 0, 0, 0

while True:
    r = requests.get(url, params={"size": size, "offset": offset}, timeout=60)
    r.raise_for_status()
    rows = r.json()
    if not rows:
        break
    total += len(rows)
    pages += 1
    offset += size

print("pages:", pages, "total rows:", total)