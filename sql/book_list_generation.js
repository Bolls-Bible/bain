// This is the array were you might get chronorder values. Only 66 books.
const ylt = [
		{
			"bookid": 1,
			"chronorder": 1,
			"name": "Genesis",
			"chapters": 50
		},
		{
			"bookid": 2,
			"chronorder": 3,
			"name": "Exodus",
			"chapters": 40
		},
		{
			"bookid": 3,
			"chronorder": 4,
			"name": "Leviticus",
			"chapters": 27
		},
		{
			"bookid": 4,
			"chronorder": 5,
			"name": "Numbers",
			"chapters": 36
		},
		{
			"bookid": 5,
			"chronorder": 6,
			"name": "Deuteronomy",
			"chapters": 34
		},
		{
			"bookid": 6,
			"chronorder": 7,
			"name": "Joshua",
			"chapters": 24
		},
		{
			"bookid": 7,
			"chronorder": 8,
			"name": "Judges",
			"chapters": 21
		},
		{
			"bookid": 8,
			"chronorder": 9,
			"name": "Ruth",
			"chapters": 4
		},
		{
			"bookid": 9,
			"chronorder": 10,
			"name": "1 Samuel",
			"chapters": 31
		},
		{
			"bookid": 10,
			"chronorder": 11,
			"name": "2 Samuel",
			"chapters": 24
		},
		{
			"bookid": 11,
			"chronorder": 15,
			"name": "1 Kings",
			"chapters": 22
		},
		{
			"bookid": 12,
			"chronorder": 28,
			"name": "2 Kings",
			"chapters": 25
		},
		{
			"bookid": 13,
			"chronorder": 12,
			"name": "1 Chronicles",
			"chapters": 29
		},
		{
			"bookid": 14,
			"chronorder": 16,
			"name": "2 Chronicles",
			"chapters": 36
		},
		{
			"bookid": 15,
			"chronorder": 37,
			"name": "Ezra",
			"chapters": 10
		},
		{
			"bookid": 16,
			"chronorder": 38,
			"name": "Nehemiah",
			"chapters": 13
		},
		{
			"bookid": 17,
			"chronorder": 36,
			"name": "Esther",
			"chapters": 10
		},
		{
			"bookid": 18,
			"chronorder": 2,
			"name": "Job",
			"chapters": 42
		},
		{
			"bookid": 19,
			"chronorder": 13,
			"name": "Psalm",
			"chapters": 150
		},
		{
			"bookid": 20,
			"chronorder": 17,
			"name": "Proverbs",
			"chapters": 31
		},
		{
			"bookid": 21,
			"chronorder": 18,
			"name": "Ecclesiastes",
			"chapters": 12
		},
		{
			"bookid": 22,
			"chronorder": 14,
			"name": "Song of Solomon",
			"chapters": 8
		},
		{
			"bookid": 23,
			"chronorder": 25,
			"name": "Isaiah",
			"chapters": 66
		},
		{
			"bookid": 24,
			"chronorder": 29,
			"name": "Jeremiah",
			"chapters": 52
		},
		{
			"bookid": 25,
			"chronorder": 30,
			"name": "Lamentations",
			"chapters": 5
		},
		{
			"bookid": 26,
			"chronorder": 32,
			"name": "Ezekiel",
			"chapters": 48
		},
		{
			"bookid": 27,
			"chronorder": 33,
			"name": "Daniel",
			"chapters": 12
		},
		{
			"bookid": 28,
			"chronorder": 23,
			"name": "Hosea",
			"chapters": 14
		},
		{
			"bookid": 29,
			"chronorder": 20,
			"name": "Joel",
			"chapters": 3
		},
		{
			"bookid": 30,
			"chronorder": 21,
			"name": "Amos",
			"chapters": 9
		},
		{
			"bookid": 31,
			"chronorder": 31,
			"name": "Obadiah",
			"chapters": 1
		},
		{
			"bookid": 32,
			"chronorder": 19,
			"name": "Jonah",
			"chapters": 4
		},
		{
			"bookid": 33,
			"chronorder": 22,
			"name": "Micah",
			"chapters": 7
		},
		{
			"bookid": 34,
			"chronorder": 24,
			"name": "Nahum",
			"chapters": 3
		},
		{
			"bookid": 35,
			"chronorder": 27,
			"name": "Habakkuk",
			"chapters": 3
		},
		{
			"bookid": 36,
			"chronorder": 26,
			"name": "Zephaniah",
			"chapters": 3
		},
		{
			"bookid": 37,
			"chronorder": 34,
			"name": "Haggai",
			"chapters": 2
		},
		{
			"bookid": 38,
			"chronorder": 35,
			"name": "Zechariah",
			"chapters": 14
		},
		{
			"bookid": 39,
			"chronorder": 39,
			"name": "Malachi",
			"chapters": 4
		},
		{
			"bookid": 40,
			"chronorder": 40,
			"name": "Matthew",
			"chapters": 28
		},
		{
			"bookid": 41,
			"chronorder": 58,
			"name": "Mark",
			"chapters": 16
		},
		{
			"bookid": 42,
			"chronorder": 52,
			"name": "Luke",
			"chapters": 24
		},
		{
			"bookid": 43,
			"chronorder": 66,
			"name": "John",
			"chapters": 21
		},
		{
			"bookid": 44,
			"chronorder": 54,
			"name": "Acts",
			"chapters": 28
		},
		{
			"bookid": 45,
			"chronorder": 46,
			"name": "Romans",
			"chapters": 16
		},
		{
			"bookid": 46,
			"chronorder": 44,
			"name": "1 Corinthians",
			"chapters": 16
		},
		{
			"bookid": 47,
			"chronorder": 45,
			"name": "2 Corinthians",
			"chapters": 13
		},
		{
			"bookid": 48,
			"chronorder": 41,
			"name": "Galatians",
			"chapters": 6
		},
		{
			"bookid": 49,
			"chronorder": 47,
			"name": "Ephesians",
			"chapters": 6
		},
		{
			"bookid": 50,
			"chronorder": 49,
			"name": "Philippians",
			"chapters": 4
		},
		{
			"bookid": 51,
			"chronorder": 50,
			"name": "Colossians",
			"chapters": 4
		},
		{
			"bookid": 52,
			"chronorder": 42,
			"name": "1 Thessalonians",
			"chapters": 5
		},
		{
			"bookid": 53,
			"chronorder": 43,
			"name": "2 Thessalonians",
			"chapters": 3
		},
		{
			"bookid": 54,
			"chronorder": 55,
			"name": "1 Timothy",
			"chapters": 6
		},
		{
			"bookid": 55,
			"chronorder": 59,
			"name": "2 Timothy",
			"chapters": 4
		},
		{
			"bookid": 56,
			"chronorder": 57,
			"name": "Titus",
			"chapters": 3
		},
		{
			"bookid": 57,
			"chronorder": 51,
			"name": "Philemon",
			"chapters": 1
		},
		{
			"bookid": 58,
			"chronorder": 53,
			"name": "Hebrews",
			"chapters": 13
		},
		{
			"bookid": 59,
			"chronorder": 48,
			"name": "James",
			"chapters": 5
		},
		{
			"bookid": 60,
			"chronorder": 56,
			"name": "1 Peter",
			"chapters": 5
		},
		{
			"bookid": 61,
			"chronorder": 60,
			"name": "2 Peter",
			"chapters": 3
		},
		{
			"bookid": 62,
			"chronorder": 61,
			"name": "1 John",
			"chapters": 5
		},
		{
			"bookid": 63,
			"chronorder": 62,
			"name": "2 John",
			"chapters": 1
		},
		{
			"bookid": 64,
			"chronorder": 63,
			"name": "3 John",
			"chapters": 1
		},
		{
			"bookid": 65,
			"chronorder": 64,
			"name": "Jude",
			"chapters": 1
		},
		{
			"bookid": 66,
			"chronorder": 65,
			"name": "Revelation",
			"chapters": 22
		}
]

let books = [
	// Here should be that books
];

for (index in ylt) {
  let book = ylt[index];
  new_book = books.find((el) => {
    return el.bookid == book.bookid;
  });
  if (new_book) {
    new_book.chronorder = book.chronorder;
  }
}

// In a case when the ylt array doesn't contain some apocrifal books -- assign to the chronorder bookid of the book
for (index in books) {
	if (books[index].chronorder == undefined) {
		books[index].chronorder = books[index].bookid
	}
	books[index].name = books[index].name.trim();
}

// console.log(books)


// After that you need to assign proper chapters number to every book
// The chapters may be got with the next sql command from the sqlite db

// SELECT book_number, count(chapter) FROM verses where verse = 1 GROUP BY book_number;

// After you got that chapters format them into array, similar to others and run the next code.

const chapters = [
	// Here should be that chapters
];

for (index in chapters) {
	let chapter = chapters[index]

  books.find((el) => {return el.bookid == chapter.bookid}).chapters = chapter.chapters
}
console.log(books)

// The output -- books -- should be the appropriate array of book of given translation
// It should looks like the ylt array.