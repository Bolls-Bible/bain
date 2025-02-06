from django.test import TestCase
from django.contrib.staticfiles import finders
from django.urls import reverse


class BollsTestCase(TestCase):
    # check if translation books are returned
    def test_get_books(self):
        request = self.client.get('/get-books/YLT/')
        self.assertEqual(request.status_code, 200)
        self.assertRegex(request.content, b'Genesis')

    # check if the text is returned
    def test_get_text(self):
        request = self.client.get('/get-text/YLT/22/8/')
        self.assertEqual(request.status_code, 200)
        self.assertIn(
            b'Who doth make thee as a brother to me, Sucking the breasts of my mother? I find thee without, I kiss thee, Yea, they do not despise me',
            request.content
        )

    # check if the chapter is returned
    def test_get_chapter(self):
        request = self.client.get('/get-chapter/YLT/22/8/')
        self.assertIn(
            b'Many waters are not able to quench the love, And floods do not wash it away. If one give all the wealth of his house for love, Treading down -- they tread upon it.',
            request.content
        )
        self.assertEqual(request.status_code, 200)

    # Check if search returns results
    def test_search(self):
        request = self.client.get(
            '/search/KJV/?search=Haggi&match_case=false&match_whole=true')
        self.assertIn(b'Haggi', request.content)
        self.assertEqual(request.status_code, 200)

    # check if dictionary search works
    def test_dictionary(self):
        request = self.client.get('/dictionary-definition/BDBT/אֹ֑ור/')
        self.assertIn(b'to be or become light, shine', request.content)
        self.assertEqual(request.status_code, 200)

    # get-parallel-verses
    # check if verses are returned
    def test_get_verses(self):
        request = self.client.post(reverse('getVerses'), data=[
            {
                'translation': 'UBIO',
                'book': 19,
                'chapter': 91,
                'verses': [14, 15, 16]
            },
            {
                'translation': 'YLT',
                'book': 19,
                'chapter': 91,
                'verses': [1, 2, 3]
            }
        ], content_type='application/json')
        self.assertIn(
            b'My refuge, and my bulwark, my God, I trust in Him', request.content)

    def test_parallel_verses(self):
        request = self.client.post('/get-parallel-verses/', data={
            "translations": "[\"YLT\",\"WEB\",\"UBIO\"]",
            "verses": "[3, 4, 5]",
            "book": 43,
            "chapter": 1,
        }, content_type='application/json')
        self.assertIn(
            b'and the light in the darkness did shine, and the darkness did not perceive it.', request.content)
        # Same test but with translations and verses as lists
        request = self.client.post('/get-parallel-verses/', data={
            "translations": ['YLT', 'WEB', 'UBIO'],
            "verses": [3, 4, 5],
            "book": 43,
            "chapter": 1,
        }, content_type='application/json')
        self.assertIn(
            b'and the light in the darkness did shine, and the darkness did not perceive it.', request.content)

    # these files should be in place
    # https://bolls.life/static/bolls/app/views/languages.json
    # https://bolls.life/static/bolls/app/views/translations_books.json
    # https://bolls.life/static/translations/YLT.zip
    def test_static(self):
        languages = finders.find('bolls/app/views/languages.json')
        self.assertIsNotNone(languages)
        books = finders.find('bolls/app/views/translations_books.json')
        self.assertIsNotNone(books)
        translation_zip = finders.find('translations/YLT.zip')
        self.assertIsNotNone(translation_zip)
