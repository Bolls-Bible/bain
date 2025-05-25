import pandas as pd
import re
from books_map import books_map, books_short_names


translation = "HFA"


def parseLinks(text):
    if type(text) is float:
        return ""

    text = re.sub(r"(<[/]?span[^>]*)>", "", text)  # Clean up unneeded spans
    text = re.sub(r"( class=\'\w+\')", "", text)  # Avoid unneeded classes on anchors

    pieces = text.split("'")

    result = ""
    for piece in pieces:
        if piece.startswith("B:"):
            result += "'/" + translation + "/"
            digits = re.findall(r"\d+", piece)
            try:
                result += str(books_map[(digits[0])]) + "/" + digits[1] + "/"
                if len(digits) > 2:
                    result += digits[2]
            except:
                print(piece, digits)

            if len(digits) > 3:
                result += "-" + digits[3]
            result += "'"
        else:
            result += piece
    return result


# print(parseLinks("<a href='B:230 102:25'>Ps. 102:25</a>; <a href='B:290 40:21'>Is. 40:21</a>; (<a href='B:500 1:1-3'>John 1:1–3</a>; <a href='B:650 1:10'>Heb. 1:10</a>)"))


def generate_links_from_cross_references(row):
    # book,chapter,verse,verse_end,book_to,chapter_to,verse_to_start,verse_to_end,votes</a>
    # Result should be something liek <a href='/NBV07/1/25/20'>20</a>
    link = f"<a href='/{translation}/{row['book_to']}/{row['chapter_to']}/{row['verse_to_start']}"
    if row["verse_to_end"] > 0:
        link += f"-{row['verse_to_end']}"
    link += f"'>{books_short_names[row['book_to']]} {row['chapter_to']}:{row['verse_to_start']}"
    if row["verse_to_end"] > 0:
        link += f"-{row['verse_to_end']}"
    link += "</a>"
    return link


def convert_cross_references_into_links():
    # load the cross_references.csv
    df = pd.read_csv("cross_references.csv", sep=",")
    # book,chapter,verse,verse_end,book_to,chapter_to,verse_to_start,verse_to_end,votes
    del df["votes"]

    df["text"] = df.apply(generate_links_from_cross_references, axis=1)

    # resulting dataframe should look like this: translation,book,chapter,verse,text
    del df["book_to"]
    del df["chapter_to"]
    del df["verse_to_start"]
    del df["verse_to_end"]
    del df["verse_end"]

    # add the translation column
    # df["translation"] = translation
    # col = df.pop("translation")
    df.insert(0, "translation", translation)
    return df


def main():
    df = pd.read_csv("mybcommentaries.csv", sep=",")

    del df["chapter_number_to"]
    del df["verse_number_to"]
    del df["is_preceding"]

    df["text"] = df.apply(lambda row: parseLinks(f'{row["marker"]} {row["text"]}'), axis=1)
    df.rename(columns={"book_number": "book", "chapter_number_from": "chapter", "verse_number_from": "verse"}, inplace=True)
    del df["marker"]

    df.insert(0, "translation", translation)
    # translation,book,chapter,verse,text
    # cross_references_df = convert_cross_references_into_links()
    # # add the cross_references_df to df
    # df = pd.concat([df, cross_references_df], ignore_index=True)

    print("Transformed data:")
    print(df.head())
    print(df.columns)

    df.to_csv(
        "commentaries.csv",
        index=False,
    )


if __name__ == "__main__":
    main()
