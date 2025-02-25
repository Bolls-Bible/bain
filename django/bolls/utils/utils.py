
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
