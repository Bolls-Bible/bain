import json

from django.contrib.auth.models import User
from django.test import TestCase, override_settings
from django.contrib.staticfiles import finders
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
            b"Many waters are not able to quench the love, And floods do not wash it away. If one give all the wealth of his house for love, Treading down -- they tread upon it.",
            request.content,
        )
        self.assertEqual(request.status_code, 200)

    # Check if search returns results
    def test_search(self):
        request = self.client.get("/search/KJV/?search=Haggi&match_case=false&match_whole=true")
        self.assertIn(b"Haggi", request.content)
        self.assertEqual(request.status_code, 200)

    # check if dictionary search works
    def test_dictionary(self):
        request = self.client.get("/dictionary-definition/BDBT/אֹ֑ור/")
        self.assertIn(b"to be or become light, shine", request.content)
        self.assertEqual(request.status_code, 200)

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
