from django.urls import path
from . import views
from django.conf.urls import handler404, handler500, include

urlpatterns = [
    path("", include("social_django.urls", namespace="social")),
    path("", views.index, name="index"),
    path("signup/", views.sign_up, name="signup"),
    path("api/", views.api),
    path("history/", views.history),
    path("save-bookmarks/", views.save_bookmarks),
    path("delete-bookmarks/", views.delete_bookmarks),
    path("edit-account/", views.edit_account),
    path("delete-my-account/", views.delete_my_account),
    path("user-logged/", views.get_me_if_am_logged_in),
    path("download-notes/", views.download_notes),
    path("import-notes/", views.import_notes),
    path("save-compare-translations/", views.save_compare_translations),
    path("api/save-favorite-translations/", views.save_favorite_translations),
    path("api/tag-tool-reference/<slug:translation>/<str:book>/<int:chapter>/<slug:verses>/", views.tag_tool_reference),
    path("get-translation/<slug:translation>/", views.get_translation),
    path("get-paralel-verses/", views.get_parallel_verses),  # typo, DEPRECATED
    path("get-parallel-verses/", views.get_parallel_verses),
    path("get-verses/", views.get_verses, name="getVerses"),
    path(
        "get-searched-bookmarks/<str:query>/<int:range_from>/<int:range_to>/",
        views.search_profile_bookmarks,
    ),
    path(
        "get-notes-bookmarks/<int:range_from>/<int:range_to>/",
        views.get_bookmarks_with_notes,
    ),
    path("search/<slug:translation>/<str:piece>/", views.search),
    path("search/<slug:translation>/", views.search),
    path("find/<slug:translation>/<str:piece>/", views.search),
    path("find/<slug:translation>/", views.search),
    path("v2/find/<slug:translation>", views.v2_search),
    path("get-books/<slug:translation>/", views.get_books),
    path("get-text/<slug:translation>/<slug:book>/<int:chapter>/", views.get_text),
    path(
        "get-chapter/<slug:translation>/<slug:book>/<int:chapter>/",
        views.get_chapter_with_comments,
    ),
    path(
        "get-verse/<slug:translation>/<int:book>/<int:chapter>/<int:verse>/",
        views.get_a_verse,
    ),
    path("get-bookmarks/<slug:translation>/<int:book>/<int:chapter>/", views.get_bookmarks),
    path(
        "get-profile-bookmarks/<int:range_from>/<int:range_to>/",
        views.get_profile_bookmarks,
    ),
    path("get-verse-counts/<slug:translation>/", views.get_verse_counts),
    path("get-random-verse/<slug:translation>/", views.get_random_verse),
    path("dictionary-definition/<slug:dict>/<str:query>/", views.dictionary_search),
    path("dictionary-definition/<slug:dict>/<str:query>", views.dictionary_search),
    path("get-dictionary/<slug:dictionary>/", views.get_dictionary),
    # AAA
    path("<slug:translation>/<str:piece>/", views.search),
]

handler404 = views.handler404
handler500 = views.handler500
