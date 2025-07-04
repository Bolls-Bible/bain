import json

from .score_search import score_search


BOOKS = []
with open("/imba/src/data/translations_books.json") as json_file:
    BOOKS = json.load(json_file)


triple_shortcuts = {
    "GEN": 1,
    "EXO": 2,
    "LEV": 3,
    "NUM": 4,
    "DEU": 5,
    "JOS": 6,
    "JDG": 7,
    "RUT": 8,
    "1SA": 9,
    "2SA": 10,
    "1KI": 11,
    "2KI": 12,
    "1CH": 13,
    "2CH": 14,
    "EZR": 15,
    "NEH": 16,
    "EST": 17,
    "JOB": 18,
    "PSA": 19,
    "PRO": 20,
    "ECC": 21,
    "SNG": 22,
    "ISA": 23,
    "JER": 24,
    "LAM": 25,
    "EZK": 26,
    "DAN": 27,
    "HOS": 28,
    "JOL": 29,
    "AMO": 30,
    "OBA": 31,
    "JON": 32,
    "MIC": 33,
    "NAM": 34,
    "HAB": 35,
    "ZEP": 36,
    "HAG": 37,
    "ZEC": 38,
    "MAL": 39,
    "MAT": 40,
    "MRK": 41,
    "LUK": 42,
    "JHN": 43,
    "ACT": 44,
    "ROM": 45,
    "1CO": 46,
    "2CO": 47,
    "GAL": 48,
    "EPH": 49,
    "PHP": 50,
    "COL": 51,
    "1TH": 52,
    "2TH": 53,
    "1TI": 54,
    "2TI": 55,
    "TIT": 56,
    "PHM": 57,
    "HEB": 58,
    "JAS": 59,
    "1PE": 60,
    "2PE": 61,
    "1JN": 62,
    "2JN": 63,
    "3JN": 64,
    "JUD": 65,
    "REV": 66,
}

twin_shortcuts = {
    "GN": 1,
    "EX": 2,
    "LV": 3,
    "NU": 4,
    "DT": 5,
    "JS": 6,
    "JG": 7,
    "RT": 8,
    "S1": 9,
    "S2": 10,
    "K1": 11,
    "K2": 12,
    "R1": 13,
    "R2": 14,
    "ER": 15,
    "NH": 16,
    "ET": 17,
    "JB": 18,
    "PS": 19,
    "PR": 20,
    "EC": 21,
    "SS": 22,
    "IS": 23,
    "JR": 24,
    "LM": 25,
    "EK": 26,
    "DN": 27,
    "HS": 28,
    "JL": 29,
    "AM": 30,
    "OB": 31,
    "JH": 32,
    "MC": 33,
    "NM": 34,
    "HK": 35,
    "ZP": 36,
    "HG": 37,
    "ZC": 38,
    "ML": 39,
    "MT": 40,
    "MK": 41,
    "LK": 42,
    "JN": 43,
    "AC": 44,
    "RM": 45,
    "C1": 46,
    "C2": 47,
    "GL": 48,
    "EP": 49,
    "PP": 50,
    "CL": 51,
    "H1": 52,
    "H2": 53,
    "T1": 54,
    "T2": 55,
    "TT": 56,
    "PM": 57,
    "HB": 58,
    "JM": 59,
    "P1": 60,
    "P2": 61,
    "J1": 62,
    "J2": 63,
    "J3": 64,
    "JD": 65,
    "RV": 66,
}


def is_number(n):
    if isinstance(n, (int, float, complex)):
        return True
    try:
        int(n)
        return True
    except ValueError:
        return False


def get_book_id(translation, book_slug):
    # if book_slug is already a number return it
    if is_number(book_slug):
        return int(book_slug)

    book_slug = book_slug.upper()

    if book_slug in triple_shortcuts:
        return triple_shortcuts[book_slug]
    if book_slug in twin_shortcuts:
        return twin_shortcuts[book_slug]

    book_slug = book_slug.lower()

    suggestions = []
    for b in BOOKS[translation]:
        if b["name"].lower() == book_slug:
            return b["bookid"]
        score = score_search(b["name"], book_slug)
        if score:
            suggestions.append((b, score))
    suggestions.sort(key=lambda x: x[1], reverse=True)
    if len(suggestions) > 0:
        return suggestions[0][0]["bookid"]

    raise ValueError(
        f"Book '{book_slug}' not found in translation '{translation}'. "
        f"Please check the book name or use a different translation."
    )


# print(get_book_id("KJV", "ot"))
# print(get_book_id("KJV", "jo"))
# print(get_book_id("KJV", "gen"))
# print(get_book_id("KJV", "Matthaw"))
# print(get_book_id("ESV", "Genesis"))
# print(get_book_id("ESV", "Acts"))
