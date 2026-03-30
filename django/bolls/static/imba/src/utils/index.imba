export * from './localStorage'
export * from './scoreSearch.js'

import { bookNameIndex } from '../constants'

export def getBookName translation\string, bookid\number
	return bookNameIndex.get("{translation}:{bookid}") || bookid
