
# When translation is fully replaced -- this may be helpful
# def fixBookmarks(request):
#     # rename KJV to OKJC
#     # push new KJV to the db
#     # map bookmarks in given range to the new KJV

#     # bookmarks = Bookmarks.objects.all().filter(verse__gte=992272, verse__lte=1023502)
#     bookmarks = Bookmarks.objects.all()
#     length = len(bookmarks)
#     for bookmark in bookmarks:
#         if bookmark.verse.id >= 992272 and bookmark.verse.id <= 1023502:
#             print(bookmark.verse.book, bookmark.verse.chapter, bookmark.verse.verse, bookmark.verse.translation)
#             new_verse = Verses.objects.get(translation="KJV", book=bookmark.verse.book, chapter=bookmark.verse.chapter, verse=bookmark.verse.verse)
#             if new_verse:
#                 bookmark.verse = new_verse
#                 bookmark.save()
#             else:
#                 print('AAAAAAAAA')

#    return HttpResponse(length)


# def clean_up_html(raw_html):
#     # remove strong numbers. They are not needed in the description
#     raw_html = re.sub(r"<S>(.*?)</S>", "", raw_html)
#     clean_regex = re.compile("<.*?>|&([a-z0-9]+|#[0-9]{1,6}|#x[0-9a-f]{1,6});")
#     clean_text = re.sub(clean_regex, "", raw_html)
#     return clean_text


# def get_description(verses, verse, endverse):
#     if verse <= len(verses) and len(verses) > 0:
#         i = 0
#         description = verses[verse - 1]["text"]
#         if endverse > 0 and endverse - verse != 0:
#             for i in range(verse, endverse):
#                 if i < len(verses):
#                     description += " " + verses[i]["text"]
#         return clean_up_html(description)
#     else:
#         return "Corrupted link!"
