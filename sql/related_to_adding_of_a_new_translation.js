for (index in ylt) {
	let book = ylt[index]

  books.find((el) => {return el.bookid == book.bookid}).chronorder = book.chronorder
}
console.log(books)



for (index in chapters) {
	let chapter = chapters[index]

  books.find((el) => {return el.bookid == chapter.bookid}).chapters = chapter.chapters
}
console.log(books)
