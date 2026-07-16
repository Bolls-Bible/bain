# Bolls API Documentation

## Table of Contents

- [Bolls API Documentation](#bolls-api-documentation)
  - [Table of Contents](#table-of-contents)
  - [Before fetching Bible text](#before-fetching-bible-text)
  - [Fetch a chapter](#fetch-a-chapter)
  - [Search](#search)
  - [Get a full translation](#get-a-full-translation)
  - [Compare versions](#compare-versions)
  - [Fetch a verse](#fetch-a-verse)
  - [Soft links](#soft-links)
  - [Fetch any verses](#fetch-any-verses)
  - [Dictionary definition for Hebrew and Greek words](#dictionary-definition-for-hebrew-and-greek-words)
  - [Random verse](#random-verse)
  - [Reference Tagging Tool](#reference-tagging-tool)
  - [Notes](#notes)
  - [Contact](#contact)

## Before fetching Bible text

Updated at: 31 March 2026.

> [!Caution]
> I noticed that some of you use `get-text` and `get-chapter` endpoints to ~~scrape~~ fetch the whole Bible. Please do not do that! It is not what these endpoints are for, and it may cause performance issues, i.e. you'll ddos my single core 14€ server and crash it. If you want to get the whole Bible just [download the translation in JSON or ZIP format](#get-a-translation) and use and abuse it on your side however you want.

First of all, get:

- A list of available translations: https://bolls.life/static/bolls/app/views/languages.json
- An object with their books: https://bolls.life/static/bolls/app/views/translations_books.json

The translations list contains nodes with the following properties:

- `short_name`: ID of the translation in the database. Use it for forming a URL.
- `full_name`: Full name of the translation.
- `updated`: Date in milliseconds since 1970 when the translation was last updated.
- `dir` (optional): May specify RTL direction translations.

API for getting books of a specific translation:

```text
https://bolls.life/get-books/<slug:translation>/
```

Where `translation` is an abbreviation of desired translation. Example:

- https://bolls.life/get-books/YLT/

The books list contains books with these properties:

- `bookid`: ID of the book.
- `chronorder`: Chronological order number according to Robert Young (for apocrypha it is the same as `bookid`).
- `name`: Book name.
- `chapters`: Number of chapters.

## Fetch a chapter

Using that data, you can form a URL to fetch a chapter. You may fetch the chapter with commentaries or without them.

```text
https://bolls.life/get-text/<slug:translation>/<int:book>/<int:chapter>/     # Without commentaries
https://bolls.life/get-chapter/<slug:translation>/<int:book>/<int:chapter>/  # With commentaries
```

Where `<slug:translation>` is a translation abbreviation like `YLT`, `UBIO`, or `SYNOD`, and `<int:book>` with `<int:chapter>` are numbers of a book and chapter.

Examples:

- https://bolls.life/get-text/YLT/22/8/
- https://bolls.life/get-chapter/NKJV/22/8/

Curl examples:

```bash
curl --location --request GET 'https://bolls.life/get-text/YLT/22/8/'
curl --location --request GET 'https://bolls.life/get-chapter/NKJV/22/8/'
```

Result fields for each verse:

- `pk`: Verse ID.
- `verse`: Verse number in the chapter.
- `text`: Verse text in HTML format.
- `comment` (optional): Comments or references in HTML format.

## Search

Update: from 16 July 2026 API uses semantic vector search for queries without `match_case` or `match_whole` set to true.

To find verses by a slug or a string:

```text
https://bolls.life/v2/find/<slug:translation>?search=<str:piece>&match_case=<bool:match_case>&match_whole=<bool:match_whole>&page=<int:page>
```

Where:

- `<slug:translation>`: Translation abbreviation to search in.
- `<str:piece>`: A piece of text (slug or regular string), not case-sensitive by default.

Examples of multilingual search terms:

- `.../WLC?search=שָּׁמַ֖יִם וְאֵ֥ת`
- `.../LXX?search=ὁ θεὸς τὸν`
- `.../UBIO?search=Небо та землю`
- `.../CUV?search=淵 面 黑 暗`

Optional parameters:

- `match_case`: Case-sensitive search.
- `match_whole`: Match whole search string.
- `book`: Filter by book (`ot` and `nt` are supported).
- `page`: Pagination page.
- `limit`: Pagination page limit.

Search behavior:

- By default (`match_case=false` and `match_whole=false`), search uses vector similarity.
- If `match_case=true` or `match_whole=true`, search switches to lexical matching.
- The total number of results of semantic search is capped at 8192, you don't really need more than that.

Example:

- https://bolls.life/v2/find/YLT?search=haggi&match_case=false&match_whole=true&limit=128&page=1
- https://bolls.life/v2/find/YLT?search=haggi&limit=128&page=1

Result object fields:

- `exact_matches`: Total number of exact matches.
- `total`: Number of total results.
- `results`: Array of objects with:
  - `pk`: Verse ID
  - `translation`: Translation
  - `book`: Book ID
  - `chapter`: Chapter number
  - `verse`: Verse number
  - `text`: Verse text (HTML)
  - `comment` (optional): Commentary (HTML)

Curl example:

```bash
curl --location --request GET 'https://bolls.life/v2/find/YLT?search=haggi&match_case=false&match_whole=true'
```

## Get a full translation

You can get a full translation in zip or json:

```text
https://bolls.life/static/translations/<slug:translation>.zip
https://bolls.life/static/translations/<slug:translation>.json
```

Example:

- https://bolls.life/static/translations/YLT.json
- https://bolls.life/static/translations/TB.zip

The result is an array of all translation verses with comments.

Curl example:

```bash
curl --location --request GET 'https://bolls.life/static/translations/YLT.json'
curl --location --request GET 'https://bolls.life/static/translations/TB.zip'
```

> [!Tip]
> The zip files are just zipped json files. You can unzip them and get the same json. If json endpoint doesn't work for some reason -- zip will always work, and you can get the json from it.

## Compare versions

You can request specific verses in specific translations to compare them.

- Method: `POST`
- URL: `https://bolls.life/get-parallel-verses/`

Body fields:

- `translations`: Array of translation abbreviations, for example `['YLT', 'HOM', 'WLCC']`.
- `verses`: Array of verse numbers, for example `[1, 2, 3, 6, 45]`.
- `chapter`: Chapter number.
- `book`: Book ID.

You can request different verses in different translations only within one chapter.

Imba example:

```javascript
window
  .fetch("/get-parallel-verses/", {
    method: "POST",
    cache: "no-cache",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      // Here are list of translations for comparison
      translations: ["YLT", "WEB", "KJV"],

      // It may be a single verse there [3], or any number of verses,
      // and if they exist they will be returned
      verses: [3, 4, 5],

      book: 43, // an id of the book
      chapter: 1, // number of chapter
    }),
  })
  .then((response) => response.json())
  .then((result) => {
    // do something with the result
  });
```

Result example:

```json
[
  [
    {
      "pk": 1145257,
      "translation": "WLCC",
      "book": 18,
      "chapter": 2,
      "verse": 1,
      "text": "ויהי היום ויבאו בני האלהים להתיצב על־יהוה ויבוא גם־השטן בתכם להתיצב על־יהוה׃"
    },
    {
      "pk": 1145258,
      "translation": "WLCC",
      "book": 18,
      "chapter": 2,
      "verse": 2,
      "text": "ויאמר יהוה אל־השטן אי מזה תבא ויען השטן את־יהוה ויאמר משט בארץ ומהתהלך בה׃"
    },
    {
      "pk": 1145259,
      "translation": "WLCC",
      "book": 18,
      "chapter": 2,
      "verse": 3,
      "text": "ויאמר יהוה אל־השטן השמת לבך אל־עבדי איוב כי אין כמהו בארץ איש תם וישר ירא אלהים וסר מרע ועדנו מחזיק בתמתו ותסיתני בו לבלעו חנם׃"
    }
  ],
  [
    {
      "pk": 36107,
      "translation": "YLT",
      "book": 18,
      "chapter": 2,
      "verse": 1,
      "text": "And the day is, that sons of God come in to station themselves by Jehovah, and there doth come also the Adversary in their midst to station himself by Jehovah."
    },
    {
      "pk": 36108,
      "translation": "YLT",
      "book": 18,
      "chapter": 2,
      "verse": 2,
      "text": "And Jehovah saith unto the Adversary, 'Whence camest thou?' And the Adversary answereth Jehovah and saith, 'From going to and fro in the land, and from walking up and down in it.'"
    },
    {
      "pk": 36109,
      "translation": "YLT",
      "book": 18,
      "chapter": 2,
      "verse": 3,
      "text": "And Jehovah saith unto the Adversary, 'Hast thou set thy heart unto My servant Job because there is none like him in the land, a man perfect and upright, fearing God and turning aside from evil? and still he is keeping hold on his integrity, and thou dost move Me against him to swallow him up for nought!'"
    }
  ]
]
```

## Fetch a verse

To fetch a single verse:

```text
https://bolls.life/get-text/<slug:translation>/<int:book>/<int:chapter>/<int:verse>/
```

Where `<slug:translation>` is the translation abbreviation (for example `YLT`, `UBIO`, `SYNOD`), and `<int:book>`, `<int:chapter>`, `<int:verse>` are numbers of a book, chapter, and verse.

Example:

- https://bolls.life/get-verse/NKJV/1/1/1/

## Soft links

Do not know the numeric book ID? You can use soft links to fetch verses by book name.

Examples:

- https://bolls.life/get-text/YLT/Gen/1/
- https://bolls.life/get-verse/YLT/Exo/1/10/
- https://bolls.life/get-verse/UBIO/Буття/1/1/
- https://bolls.life/get-verse/UBIO/Бут/1/1/ (abbreviations supported)

## Fetch any verses

New since 28 June 2022.

Sometimes you may need to fetch a few verses from different places in the Bible.

- Method: `POST`
- URL: `/get-verses/`

Body item fields:

- `translation`: Translation code.
- `book`: Book code.
- `chapter`: Chapter number.
- `verses`: Array of verse numbers.

Example:

```javascript
window
  .fetch("/get-verses/", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify([
      {
        translation: "YLT",
        book: 19,
        chapter: 145,
        verses: [14, 15, 16],
      },
      {
        translation: "KJV",
        book: 19,
        chapter: 91,
        verses: [1, 2, 3],
      },
    ]),
  })
  .then((response) => response.json())
  .then((data) => console.log(data))
  .catch(console.error);
```

Result example:

```json
[
  [
    {
      "pk": 23228,
      "translation": "YLT",
      "book": 1,
      "chapter": 1,
      "verse": 14,
      "text": "And God saith, 'Let luminaries be in the expanse of the heavens, to make a separation between the day and the night, then they have been for signs, and for seasons, and for days and years,'"
    },
    {
      "pk": 23229,
      "translation": "YLT",
      "book": 1,
      "chapter": 1,
      "verse": 15,
      "text": "and they have been for luminaries in the expanse of the heavens to give light upon the earth:' and it is so."
    },
    {
      "pk": 23230,
      "translation": "YLT",
      "book": 1,
      "chapter": 1,
      "verse": 16,
      "text": "And God maketh the two great luminaries, the great luminary for the rule of the day, and the small luminary -- and the stars -- for the rule of the night;"
    }
  ],
  [
    {
      "pk": 2743734,
      "translation": "KJV",
      "book": 19,
      "chapter": 91,
      "verse": 1,
      "text": "He that dwelleth in the secret place of the most High shall abide under the shadow of the Almighty."
    },
    {
      "pk": 2743735,
      "translation": "KJV",
      "book": 19,
      "chapter": 91,
      "verse": 2,
      "text": "I will say of the LORD, He is my refuge and my fortress: my God; in him will I trust."
    },
    {
      "pk": 2743736,
      "translation": "KJV",
      "book": 19,
      "chapter": 91,
      "verse": 3,
      "text": "Surely he shall deliver thee from the snare of the fowler, and from the noisome pestilence."
    }
  ]
]
```

## Dictionary definition for Hebrew and Greek words

New since 23 December 2021.

This API returns a list of dictionary definitions for Hebrew or Greek words. If nothing is found, an empty array is returned.

```text
https://bolls.life/dictionary-definition/<slug:dict>/<str:query>/
```

Where:

- `dict`: Dictionary abbreviation. Available dictionaries:
  - `BDBT` - Brown-Driver-Briggs' Hebrew Definitions / Thayer's Greek Definitions
  - `RUSD` - Полный лексикон по Стронгу и Дворецкому, 2019
- Dictionaries list: https://bolls.life/static/bolls/app/views/dictionaries.json
- `query`: Can be Greek/Hebrew text, an English/Russian word, or a Strong number like `H125` or `G523`.

Example:

- https://bolls.life/dictionary-definition/BDBT/אֹ֑ור

Definition fields:

- `topic`: Strong number.
- `definition`: HTML string with definition text.
- `lexeme`: Found word.
- `transliteration`: Found word transliteration.
- `pronunciation`: Found word pronunciation.
- `short_definition`: Short definition used for lookup by English/Russian query.
- `weight`: Match score from 0 to 1.

Optional flag:

- `extended=true`: Returns extended search results.

Example:

- https://bolls.life/dictionary-definition/BDBT/אֹ֑ור/?extended=true

Download whole dictionary as JSON or ZIP:

```text
https://bolls.life/static/dictionaries/<slug:dictionary>.[json|zip]
```

Examples:

- https://bolls.life/static/dictionaries/BDBT.json
- https://bolls.life/static/dictionaries/BDBT.zip

## Random verse

New since 4 Feb 2024.

URL constructor:

```text
https://bolls.life/get-random-verse/<slug:translation>/
```

`<slug:translation>` is a translation abbreviation like `YLT`, `UBIO`, or `SYNOD`.

Example:

- https://bolls.life/get-random-verse/YLT/

Result example:

```json
{
  "pk": 31073,
  "translation": "YLT",
  "book": 9,
  "chapter": 24,
  "verse": 19,
  "text": "and that a man doth find his enemy, and hath sent him away in a good manner; and Jehovah doth repay thee good for that which thou didst to me this day."
}
```

Where:

- `pk`: Verse ID.
- `translation`: Translation.
- `book`: Book ID.
- `chapter`: Chapter number.
- `verse`: Verse number.
- `text`: Verse text in HTML format.

## Reference Tagging Tool

New since 28 March 2025.

- GitHub issue: https://github.com/Bolls-Bible/bain/issues/39

This API allows you to automatically tag Bible references in your text. Include JS and CSS, then call initialization methods.

```html
<head>
  <script
    type="text/javascript"
    src="https://bolls.life/reference-tool/tool.js"
  ></script>
  <link
    rel="stylesheet"
    type="text/css"
    href="https://bolls.life/reference-tool/popover.css"
  />
</head>
<body>
  <div id="text">
    <p>Some text with references to the Bible: John 3:16</p>
    <p>Another text with references to the Bible: Genesis 1:1</p>
  </div>
  <script type="text/javascript">
    ReferenceTagging.init();
    // Set defaults. Full list of public options look at the source code.
    ReferenceTagging.translation = "KJV";
    ReferenceTagging.theme = "dark"; // or 'light' (default)
    ReferenceTagging.linkVerses();
  </script>
</body>
```

Example page:

- https://bolls.life/reference-tool/test.html

By default, the regex is configured for English book names. To customize language behavior, edit:

- `ReferenceTagging.books_regex`
- `ReferenceTagging.apoc_books_regex`

Reverse engineered from:

- https://www.biblegateway.com/share/#reftag

## Notes

- Every verse text should be interpreted as an HTML string. It may contain tags like `</br>` or `<i></i>`. Either display the text as HTML or strip the tags.

## Contact

If you have any further questions:

- Email: bpavlisinec@gmail.com
- Telegram: https://t.me/Boguslavv
