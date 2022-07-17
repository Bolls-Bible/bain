import pandas as pd
import re
from books_map import *


translation = 'LBLA'

def parseLinks(text):
	if type(text) == float:
		return ''

	text = re.sub(r'(<[/]?span[^>]*)>', '', text)	# Clean up unneeded spans
	text = re.sub(r'( class=\'\w+\')', '', text)	# Avoid unneded classes on anchors

	pieces = text.split("'")

	result = ''
	for piece in pieces:
		if piece.startswith('B:'):
			result += "'/" + translation + '/'
			digits = re.findall(r'\d+', piece)
			try:
				result += str(books_map[(digits[0])]) + '/' + digits[1] + '/' + digits[2]
			except:
				print(piece)

			if len(digits) > 3:
				result += '-' + digits[3]
			result += "'"
		else:
			result += piece
	return result

# print(parseLinks("<a href='B:230 102:25'>Ps. 102:25</a>; <a href='B:290 40:21'>Is. 40:21</a>; (<a href='B:500 1:1-3'>John 1:1–3</a>; <a href='B:650 1:10'>Heb. 1:10</a>)"))


df = pd.read_csv('mybcommentaries.csv', sep=',')

del df["chapter_number_to"]
del df["verse_number_to"]
del df["marker"]

df["translation"] = translation
df['text'] = df.apply (lambda row: parseLinks(row["text"]), axis=1)
df.rename(columns = {'book_number':'book', 'chapter_number_from':'chapter',
                              'verse_number_from':'verse'}, inplace = True)

col = df.pop("translation")
df.insert(0, col.name, col)
# translation,book,chapter,verse,text

df.to_csv('commentaries.csv', index=False,)
