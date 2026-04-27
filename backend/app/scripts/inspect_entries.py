import json
from pathlib import Path

RAW_DIR = Path(__file__).resolve().parents[2] / "data" / "raw"


def load_entries():
    entries = []

    for path in RAW_DIR.glob("*.json"):
        with path.open("r", encoding="utf-8") as file:
            print(f"Loading {path.name}")
            data = json.load(file)

        if not isinstance(data, list):
            raise ValueError(f"{path.name} should contain a JSON list")

        entries.extend(data)

    return entries


def main():
    entries = load_entries()

    total = len(entries)
    aliases = sum(1 for e in entries if e.get("metadata", {}).get("is_alias") is True)
    empty_content = sum(1 for e in entries if not e.get("content", "").strip())
    usable = total - empty_content

    print(f"Total entries: {total}")
    print(f"Alias entries: {aliases}")
    print(f"Empty content entries: {empty_content}")
    print(f"Usable entries with content: {usable}")

    print("\nFirst 5 usable entries:")
    count = 0

    for entry in entries:
        content = entry.get("content", "").strip()
        if not content:
            continue

        print("-" * 80)
        print("ID:", entry.get("id"))
        print("Title:", entry.get("title"))
        print("Source:", entry.get("metadata", {}).get("source"))
        print("Page:", entry.get("metadata", {}).get("page"))
        print("Content preview:", content[:300].replace("\n", " "))

        count += 1
        if count == 5:
            break


if __name__ == "__main__":
    main()