import json
from unittest.mock import patch

import bolls.views as views
from django.contrib.auth.models import User
from django.test import SimpleTestCase, TestCase, override_settings
from django.urls import reverse

from bolls.models import History
from bolls.views import is_strongs_number_query


@override_settings(
    CACHES={
        "default": {
            "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
            "LOCATION": "unique-snowflake",
        }
    }
)
class BollsTestCase(TestCase):
    def test_health_live(self):
        request = self.client.get("/health/live/")
        self.assertEqual(request.status_code, 204)

    def test_health_ready(self):
        request = self.client.get("/health/ready/")
        self.assertEqual(request.status_code, 200)
        self.assertJSONEqual(request.content, {"status": "ok", "database": "ok"})

    # check if translation books are returned
    def test_get_books(self):
        request = self.client.get("/get-books/YLT/")
        self.assertEqual(request.status_code, 200)
        self.assertRegex(request.content, b"Genesis")

    # check if the text is returned
    def test_get_text(self):
        request = self.client.get("/get-text/YLT/22/8/")
        self.assertEqual(request.status_code, 200)
        self.assertIn(
            b"Who doth make thee as a brother to me, Sucking the breasts of my mother? I find thee without, I kiss thee, Yea, they do not despise me",
            request.content,
        )

    # check if the chapter is returned
    def test_get_chapter(self):
        request = self.client.get("/get-chapter/YLT/22/8/")
        self.assertIn(
            (
                b"Many waters are not able to quench the love, And floods do not wash it away. "
                b"If one give all the wealth of his house for love, Treading down -- they tread upon it."
            ),
            request.content,
        )
        self.assertEqual(request.status_code, 200)

    # Check if search returns results
    def test_search(self):
        request = self.client.get("/search/KJV/?search=Haggi&match_case=false&match_whole=true")
        self.assertIn(b"Haggi", request.content)
        self.assertEqual(request.status_code, 200)

    def test_v2_search_vector_default_uses_page_and_limit(self):
        with patch("bolls.views._vector_search") as mocked_vector_search:
            mocked_vector_search.return_value = ([], 0)

            request = self.client.get("/v2/find/KJV?search=Haggi&page=3&limit=10&match_case=false&match_whole=false")

            self.assertEqual(request.status_code, 200)
            mocked_vector_search.assert_called_once_with("KJV", "Haggi", None, 3, 10)

    def test_v2_search_match_case_disables_vector_default(self):
        with patch("bolls.views._vector_search") as mocked_vector_search:
            request = self.client.get("/v2/find/KJV?search=Haggi&page=1&limit=10&match_case=true&match_whole=false")

            self.assertEqual(request.status_code, 200)
            mocked_vector_search.assert_not_called()

    # NOTE: Tests semantic vector search. Disabled if you have no embeddings generated for the verses.
    # You can generate embeddings by running `python manage.py embed_verses --translation KJV` and `python manage.py embed_verses --translation KJV`.
    def test_find_web(self):
        request = self.client.get("/find/KJV/?search=Do%20not%20kill&limit=60")
        self.assertIn(b"Thou <mark>do</mark>st <mark>not</mark> murder", request.content)
        self.assertEqual(request.status_code, 200)

    # NOTE: Tests semantic vector search. Disabled if you have no embeddings generated for the verses.
    # You can generate embeddings by running `python manage.py embed_verses --translation KJV` and `python manage.py embed_verses --translation YLT`.
    def test_search_web_mary_magdalene(self):
        request = self.client.get("/search/YLT/MARY%20MAGDALENE/")
        self.assertIn(b"<mark>Mary</mark> the <mark>Magdalene</mark>", request.content)
        self.assertEqual(request.status_code, 200)

    # add test with emojies in the query
    def test_search_with_emojies(self):
        request = self.client.get("/search/KJV/?search=love%20💖&match_case=false&match_whole=false")
        self.assertEqual(request.status_code, 200)

    # check if dictionary search works
    def test_dictionary(self):
        request = self.client.get("/dictionary-definition/BDBT/אֹ֑ור/")
        self.assertIn(b"to be or become light, shine", request.content)
        self.assertEqual(request.status_code, 200)

    # test if book filter works for search in a translation with apocrypha like KJV
    def test_search_with_book_filter_ot(self):
        request = self.client.get("/search/KJV/?search=Jesus wept&match_case=false&match_whole=&book=ot")
        self.assertEqual(request.status_code, 200)
        # every book in the result should be less than 40 (the first book of the NT) and more than 66 (the last book of the NT)
        for verse in json.loads(request.content):
            self.assertTrue(verse["book"] < 40 or verse["book"] > 66)

    def test_search_with_book_filter_nt(self):
        request = self.client.get("/search/KJV/?search=Jesus wept&match_case=false&match_whole=&book=nt")
        self.assertEqual(request.status_code, 200)
        # every book in the result should be greater than or equal to 40 (the first book of the NT) and less than 67 (the last book of the NT + 1)
        for verse in json.loads(request.content):
            self.assertTrue(verse["book"] >= 40 and verse["book"] < 67)

    def test_search_with_book_filter_specific_book(self):
        request = self.client.get("/search/KJV/?search=Jesus wept&match_case=false&match_whole=&book=43")
        self.assertEqual(request.status_code, 200)
        # every book in the result should be equal to 43 (the book of John)
        for verse in json.loads(request.content):
            self.assertEqual(verse["book"], 43)

    def test_is_strongs_number_query(self):
        self.assertTrue(is_strongs_number_query("H123"))
        self.assertTrue(is_strongs_number_query("g1"))
        self.assertFalse(is_strongs_number_query("H12345"))
        self.assertFalse(is_strongs_number_query("X123"))
        self.assertFalse(is_strongs_number_query("light"))

    # get-parallel-verses
    # check if verses are returned
    def test_get_verses(self):
        request = self.client.post(
            reverse("getVerses"),
            data=[
                {"translation": "UBIO", "book": 19, "chapter": 91, "verses": [14, 15, 16]},
                {"translation": "YLT", "book": 19, "chapter": 91, "verses": [1, 2, 3]},
            ],
            content_type="application/json",
        )
        self.assertIn(b"My refuge, and my bulwark, my God, I trust in Him", request.content)

    def test_parallel_verses(self):
        request = self.client.post(
            "/get-parallel-verses/",
            data={
                "translations": '["YLT","WEB","UBIO"]',
                "verses": "[3, 4, 5]",
                "book": 43,
                "chapter": 1,
            },
            content_type="application/json",
        )
        self.assertIn(b"and the light in the darkness did shine, and the darkness did not perceive it.", request.content)
        # Same test but with translations and verses as lists
        request = self.client.post(
            "/get-parallel-verses/",
            data={
                "translations": ["YLT", "WEB", "UBIO"],
                "verses": [3, 4, 5],
                "book": 43,
                "chapter": 1,
            },
            content_type="application/json",
        )
        self.assertIn(b"and the light in the darkness did shine, and the darkness did not perceive it.", request.content)

    def test_history_v2_deduplicates_dict_identity_fields(self):
        user = User.objects.create_user(username="history-user", password="secret")
        self.client.force_login(user)

        existing_entry = {
            "translation": {"short_name": "KJV"},
            "book": 43,
            "chapter": 3,
            "verse": 16,
            "date": 10,
        }
        newer_duplicate = {
            "translation": {"short_name": "KJV"},
            "book": 43,
            "chapter": 3,
            "verse": 16,
            "date": 20,
        }

        History.objects.create(
            user=user,
            history=json.dumps([existing_entry]),
            purge_date=0,
            compare_translations="[]",
            favorite_translations="[]",
        )

        request = self.client.put(
            "/v2/history/",
            data=json.dumps({"history": json.dumps([newer_duplicate]), "purge_date": 0}),
            content_type="application/json",
        )

        self.assertEqual(request.status_code, 200)
        self.assertJSONEqual(
            request.content,
            {
                "history": json.dumps([newer_duplicate]),
                "purge_date": 0,
                "compare_translations": "[]",
                "favorite_translations": "[]",
            },
        )

    # /v2/find/KJV?search=searched+the+scriptures&page=1&limit=30 returns 6 while total is 9
    def test_paginate_results_materializes_iterables_before_slicing(self):
        class IterableWithoutSlice:
            def __init__(self, values):
                self.values = values

            def __iter__(self):
                return iter(self.values)

        self.assertEqual(views._paginate_results(IterableWithoutSlice([1, 2, 3, 4]), 0, 10), [1, 2, 3, 4])


class BollsPaginationTests(SimpleTestCase):
    def test_paginate_results_materializes_iterables_before_slicing(self):
        class IterableWithoutSlice:
            def __init__(self, values):
                self.values = values

            def __iter__(self):
                return iter(self.values)

        self.assertEqual(views._paginate_results(IterableWithoutSlice([1, 2, 3, 4]), 0, 10), [1, 2, 3, 4])
