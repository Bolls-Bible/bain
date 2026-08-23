#!/usr/bin/env python3

from __future__ import annotations

import csv
import json
import re
import shutil
import sqlite3
import sys
import tempfile
from pathlib import Path
from contextlib import contextmanager


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent


VERSE_CONCORDANCE_SQL = REPO_ROOT / "sql" / "myBible_concordance.sql"
COMMENTARY_CONCORDANCE_SQL = REPO_ROOT / "commentaries" / "commentaries_concordance.sql"
BOOKS_REFERENCE_JSON = REPO_ROOT / "django" / "bolls" / "static" / "imba" / "src" / "data" / "translations_books.json"


def load_commentary_books_map() -> dict[str, int]:
    if str(REPO_ROOT) not in sys.path:
        sys.path.insert(0, str(REPO_ROOT))

    from commentaries.books_map import books_map

    return books_map


def discover_modules(folder: Path) -> dict[str, dict[str, Path]]:
    modules: dict[str, dict[str, Path]] = {}
    for sqlite_file in folder.glob("*.SQLite3"):
        name = sqlite_file.name
        if name.endswith(".commentaries.SQLite3"):
            translation = name.removesuffix(".commentaries.SQLite3")
            role = "commentaries"
        else:
            translation = name.removesuffix(".SQLite3")
            role = "verses"

        modules.setdefault(translation, {})[role] = sqlite_file

    return modules


def load_reference_books() -> dict[int, int]:
    with BOOKS_REFERENCE_JSON.open(encoding="utf-8") as handle:
        reference = json.load(handle)

    books = reference.get("YLT", []) if isinstance(reference, dict) else reference
    chronorder_by_bookid: dict[int, int] = {}

    for book in books:
        bookid = int(book["bookid"])
        chronorder_by_bookid[bookid] = int(book["chronorder"])

    return chronorder_by_bookid


BOOK_CHRONORDER = load_reference_books()
BOOKS_MAP = load_commentary_books_map()


def run_sql_script(connection: sqlite3.Connection, sql_path: Path) -> None:
    connection.executescript(sql_path.read_text(encoding="utf-8"))
    connection.commit()


@contextmanager
def mutable_sqlite_copy(sqlite_file: Path):
    fd, temp_name = tempfile.mkstemp(suffix=sqlite_file.suffix)
    Path(temp_name).unlink(missing_ok=True)
    temp_path = Path(temp_name)
    shutil.copy2(sqlite_file, temp_path)

    try:
        with sqlite3.connect(temp_path) as connection:
            yield connection
    finally:
        temp_path.unlink(missing_ok=True)


def normalize_verse_text(text: object) -> str:
    if text is None:
        return ""

    normalized = str(text)
    normalized = normalized.replace("<pb/>", "")
    normalized = normalized.replace("<J>", "").replace("</J>", "")
    normalized = normalized.replace("<t>", "")
    # normalized = normalized.replace("</t>", "<br/>")
    normalized = normalized.replace("</t>", "")  # In some cases I outright delete them
    normalized = normalized.replace("<e>", "<b>").replace("</e>", "</b>")
    normalized = normalized.replace("<f>", "<sup>").replace("</f>", "</sup>")
    normalized = normalized.replace("<n>", "<sup>").replace("</n>", "</sup>")
    return normalized


def parse_links(text: object, translation: str) -> str:
    if text is None:
        return ""

    # in some cases the double quotes may be escaped, so we need to handle that as well. replace "" with '
    normalized = str(text)
    # normalized = normalized.replace('""', "'")
    # normalized = normalized.replace('"', "'")
    normalized = re.sub(r"(<[/]?span[^>]*)>", "", normalized)  # Clean up unneeded spans
    normalized = re.sub(r"( class=\'\w+\')", "", normalized)  # Avoid unneeded classes on anchors

    pieces = normalized.split("'")
    result = ""

    for piece in pieces:
        if piece.startswith("B:"):
            result += "'/" + translation + "/"
            digits = re.findall(r"\d+", piece)
            try:
                result += str(BOOKS_MAP[digits[0]]) + "/" + digits[1] + "/"
                if len(digits) > 2:
                    result += digits[2]
            except Exception:
                print(piece, digits)

            if len(digits) > 3:
                result += "-" + digits[3]
            result += "'"
        else:
            result += piece

    # result = result.replace("<a href=C:@1006 0:0>Intro</a> - <a href=C:@1000 0:0>key</a> - <a href=C:@1010 0:0>mss list</a>", "")
    # result = result.replace('<a href=S:NA28_bullet>•</a> ', "")
    # # Replace <a href=S:NA28_exp-sy-hmg><font size=-2>hmg</font></a> with <font size=-2>hmg</font>
    # result = re.sub(r"<a href=S:[^>]+>(<font[^>]+>[^<]+</font>)</a>", r"\1", result)
    # # <a href=S:NA28_M-01>ℵ</a> too
    # result = re.sub(r"<a href=S:[^>]+>([^<]+)</a>", r"\1", result)
    # # Replace  \[<a href=C:@1008 0:0>all</a>\] with nothing
    # result = re.sub(r" \[<a href=C:@1008 0:0>all</a>\]", "", result)
    # # and  [<a href=C:@1009 0:0>all</a>]
    # result = re.sub(r" \[<a href=C:@1009 0:0>all</a>\]", "", result)
    # # and  <a href=S:NA28_m-1006>1006</a>
    # result = re.sub(r" <a href=S:NA28_m-1006>1006</a>", "", result)
    return result


def export_books_json(connection: sqlite3.Connection, output_path: Path) -> None:
    connection.row_factory = sqlite3.Row

    chapter_counts = {
        int(row[0]): int(row[1])
        for row in connection.execute(
            """
            select book_number, count(chapter)
            from verses
            where verse = 1
            group by book_number
            """
        )
    }

    books = []
    for row in connection.execute("select book_number, long_name from books order by book_number"):
        bookid = int(row["book_number"])
        books.append(
            {
                "bookid": bookid,
                "name": row["long_name"],
                "chronorder": BOOK_CHRONORDER.get(bookid, bookid),
                "chapters": chapter_counts.get(bookid, 0),
            }
        )

    with output_path.open("w", encoding="utf-8") as handle:
        json.dump(books, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def export_verses_csv(connection: sqlite3.Connection, translation: str, output_path: Path) -> None:
    connection.row_factory = sqlite3.Row

    with output_path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["translation", "book", "chapter", "verse", "text"])

        for row in connection.execute("select book_number, chapter, verse, text from verses order by book_number, chapter, verse"):
            writer.writerow(
                [
                    translation,
                    int(row["book_number"]),
                    int(row["chapter"]),
                    int(row["verse"]),
                    normalize_verse_text(row["text"]),
                ]
            )


# print module info, description, and version
def print_module_info(connection: sqlite3.Connection) -> None:
    connection.row_factory = sqlite3.Row

    for row in connection.execute("select name, value from info"):
        if row["name"] == "description":
            print(f"Successfully exported: {row['value']}")


def export_commentaries_csv(connection: sqlite3.Connection, translation: str, output_path: Path) -> None:
    connection.row_factory = sqlite3.Row

    with output_path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["translation", "book", "chapter", "verse", "text"])

        for row in connection.execute(
            """
            select book_number, chapter_number_from, verse_number_from, marker, text
            from commentaries
            order by book_number, chapter_number_from, verse_number_from
            """
        ):
            text = f"{row['marker']} {row['text']}".strip()
            # if row["book_number"] < 1000:
            #     print(f"Exporting commentary: {translation} {row['book_number']}:{row['chapter_number_from']}:{row['verse_number_from']}: {text}")
            writer.writerow(
                [
                    translation,
                    int(row["book_number"]),
                    int(row["chapter_number_from"]),
                    int(row["verse_number_from"]),
                    parse_links(text, translation),
                ]
            )


def process_verses_module(translation: str, sqlite_file: Path) -> None:
    with mutable_sqlite_copy(sqlite_file) as connection:
        run_sql_script(connection, VERSE_CONCORDANCE_SQL)
        export_books_json(connection, SCRIPT_DIR / "books.json")
        export_verses_csv(connection, translation, SCRIPT_DIR / "verses.csv")
        print_module_info(connection)


def process_commentaries_module(translation: str, sqlite_file: Path) -> None:
    with mutable_sqlite_copy(sqlite_file) as connection:
        run_sql_script(connection, COMMENTARY_CONCORDANCE_SQL)
        export_commentaries_csv(connection, translation, SCRIPT_DIR / "commentaries.csv")


def main() -> None:
    modules = discover_modules(SCRIPT_DIR)
    if not modules:
        raise SystemExit(f"No MyBible SQLite3 files found in {SCRIPT_DIR}")

    for translation, module_files in sorted(modules.items()):
        if "verses" not in module_files:
            print(f"Skipping {translation}: no verses database found")
            continue

        print(f"Processing {translation}")
        process_verses_module(translation, module_files["verses"])

        commentary_file = module_files.get("commentaries")
        if commentary_file is not None:
            process_commentaries_module(translation, commentary_file)


if __name__ == "__main__":
    # print(parse_links("<a href='B:230 102:25'>Ps. 102:25</a>; <a href='B:290 40:21'>Is. 40:21</a>; (<a href='B:500 1:1-3'>John 1:1–3</a>; <a href='B:650 1:10'>Heb. 1:10</a>)", "YLT"))
    print(parse_links("""<div class=""versehead""><span class=""verseid"">Matthew 1:1</span><span class=""appHeadInfoLinks""><a class=""C"" href=""C:@1006 0:0"">Intro</a> - <a class=""C"" href=""C:@1000 0:0"">key</a> - <a class=""C"" href=""C:@1010 0:0"">mss list</a></span><br/><span class=""ecnum"">Eusebian section/canon number: <div class=""ec""><table><tr><td>1</td></tr><tr><td>III</td></tr></table></div> [<a class=""C"" href=""C:@1008 0:0"">all</a>]</span></div> <div class=""versetext""> Βίβλος γενέσεως Ἰησοῦ Χριστοῦ υἱοῦ Δαυὶδ υἱοῦ Ἀβραάμ. </div> <div class=""xrefs""> <div class=""xrefHead""><span class=""xrefHeadTitle"">Cross references:</span></div> <div class=""xrefEnt""> <a class=""B"" href=""B:10 2:4"">Gen 2:4</a>; <a class=""B"" href=""B:10 5:1"">Gen 5:1</a>; <a class=""B"" href=""B:470 1:18"">Mat 1:18</a>; <a class=""B"" href=""B:470 9:27"">Mat 9:27</a></div> <div class=""xrefSeeAlso"">Also see cross references for: <a class=""B"" href=""B:470 9:27"">Mat 9:27</a></div> </div>""", "YLT"))
    main()
