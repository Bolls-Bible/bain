from django.db.models import F, Func
import re
import os
import unicodedata
import json
from django.db.models import Count, Q
from django.contrib.postgres.search import (
    SearchQuery,
    SearchRank,
    SearchVector,
    TrigramWordSimilarity,
)
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.hashers import is_password_usable
from django.contrib.auth.models import User
from django.contrib.auth import login, authenticate
from django.shortcuts import render, redirect
from django.template import RequestContext
from django.http import JsonResponse, HttpResponse

from bolls.books_map import books_map
from bolls.forms import SignUpForm

from .models import Verses, Bookmarks, History, Note, Commentary, Dictionary

from .utils.books import BOOKS, get_book_id

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

bolls_index = "bolls/index.html"
incorrect_body = "The body of the request is incorrect"


def index(request):
    return render(request, bolls_index)


def cross_origin(response, headers={}):
    response["Access-Control-Allow-Origin"] = "*"
    response["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    response["Access-Control-Max-Age"] = "1000"
    response["Access-Control-Allow-Headers"] = "X-Requested-With, Content-Type"
    response["Cross-Origin-Opener-Policy"] = "unsafe-none"
    response["Cross-Origin-Embedder-Policy"] = "unsafe-none"
    response["Cross-Origin-Resource-Policy"] = "cross-origin"
    response["Content-Security-Policy"] = "cross-origin"
    response["referrer-policy"] = "unsafe-url"
    # add custom headers
    for key, value in headers.items():
        response[key] = value
    return response


def get_translation(_, translation):
    all_verses = Verses.objects.filter(translation=translation).order_by("book", "chapter", "verse")
    all_commentaries = Commentary.objects.filter(translation=translation).order_by("book", "chapter", "verse")

    # Index first the commentary to speed up the process
    commentary_index = {}
    for item in all_commentaries:
        if (
            item.book,
            item.chapter,
            item.verse,
        ) not in commentary_index:
            commentary_index[(item.book, item.chapter, item.verse)] = []
        commentary_index[(item.book, item.chapter, item.verse)].append(item)

    def serialize_verse(obj):
        verse = {
            "pk": obj.pk,
            "translation": obj.translation,
            "book": obj.book,
            "chapter": obj.chapter,
            "verse": obj.verse,
            "text": obj.text,
        }
        comment = ""
        if (obj.book, obj.chapter, obj.verse) in commentary_index:
            for item in commentary_index[(obj.book, obj.chapter, obj.verse)]:
                if len(comment) > 0:
                    comment += "<br>"
                comment = "%s%s" % (comment, item.text)

        if len(comment) > 0:
            verse["comment"] = comment
        return verse

    verses = [serialize_verse(obj) for obj in all_verses]
    return cross_origin(JsonResponse(verses, safe=False))


def get_chapter(translation, book, chapter):
    bookid = get_book_id(translation, book)
    all_objects = Verses.objects.filter(book=bookid, chapter=chapter, translation=translation).order_by("verse")
    d = []
    for obj in all_objects:
        d.append({"pk": obj.pk, "verse": obj.verse, "text": obj.text})
    return d


def get_text(_, translation, book, chapter):
    return cross_origin(JsonResponse(get_chapter(translation, book, chapter), safe=False))


def get_chapter_with_commentaries(translation, book, chapter):
    bookid = get_book_id(translation, book)

    all_verses = Verses.objects.filter(book=bookid, chapter=chapter, translation=translation).order_by("verse")

    all_commentaries = Commentary.objects.filter(book=bookid, chapter=chapter, translation=translation).order_by("verse")

    d = []
    for obj in all_verses:
        verse = {"pk": obj.pk, "verse": obj.verse, "text": obj.text}
        comment = ""
        for item in all_commentaries:
            if item.verse == obj.verse:
                if len(comment) > 0:
                    comment += "<br>"
                comment += item.text
        if len(comment) > 0:
            verse["comment"] = comment
        d.append(verse)
    return d


def get_chapter_with_comments(_, translation, book, chapter):
    return cross_origin(JsonResponse(get_chapter_with_commentaries(translation, book, chapter), safe=False))


def find(translation, piece, book, match_case, match_whole):
    d = []
    results_of_search = []
    if match_whole:
        linear_search_params = {
            "translation": translation,
        }

        if book:
            if isinstance(book, str):
                if book == "ot":
                    linear_search_params["book__lt"] = 40
                else:
                    linear_search_params["book__gt"] = 40
            else:
                linear_search_params["book"] = book

        if match_case:
            linear_search_params["text__contains"] = piece
        else:
            linear_search_params["text__icontains"] = piece
        results_of_search = Verses.objects.filter(**linear_search_params).order_by("book", "chapter", "verse")
    else:
        query_set = []

        for word in piece.split():
            if match_case:
                query_set.append('Q(translation="' + translation + '", text__contains=' + json.dumps(word) + ")")
            else:
                query_set.append('Q(translation="' + translation + '", text__icontains=' + json.dumps(word) + ")")
        if book:
            if isinstance(book, str):
                if book == "ot":
                    query_set.append("Q(book__lt=40)")
                else:
                    query_set.append("Q(book__gt=40)")
            else:
                query_set.append('Q(book="' + book + '")')

        query = " & ".join(query_set)

        results_of_exec_search = Verses.objects.filter(eval(query)).order_by("book", "chapter", "verse")

        if len(results_of_exec_search) < 24:
            vector = SearchVector("text")
            query = SearchQuery(piece)

            search_params = {
                "translation": translation,
            }
            if book:
                if isinstance(book, str):
                    if book == "ot":
                        search_params["book__lt"] = 40
                    else:
                        search_params["book__gt"] = 40
                else:
                    search_params["book"] = book

            results_of_rank = Verses.objects.annotate(rank=SearchRank(vector, query)).filter(**search_params, rank__gt=(0.05)).order_by("-rank")

            results_of_search = []
            if len(results_of_rank) < 24:
                results_of_similarity = (
                    Verses.objects.annotate(rank=TrigramWordSimilarity(piece, "text")).filter(**search_params, rank__gt=0.5).order_by("-rank")
                )

                results_of_search = list(results_of_similarity) + list(set(results_of_rank) - set(results_of_similarity))

            results_of_search.sort(key=lambda verse: verse.rank, reverse=True)

            if len(results_of_exec_search) > 0:
                results_of_search = list(results_of_exec_search) + list(set(results_of_search) - set(results_of_exec_search))
        else:
            results_of_search = results_of_exec_search

    def highlight_headline(text):
        highlighted_text = text
        mark_replacement = re.compile(re.escape(piece), re.IGNORECASE)
        highlighted_text = mark_replacement.sub("<mark>" + piece + "</mark>", highlighted_text)
        if not match_whole:
            for word in piece.split():
                if word == piece:
                    break
                # word may be just an article or an `I` which may replace all i`s in all words
                if len(word) < 2:
                    continue
                mark_replacement = re.compile(re.escape(word), re.IGNORECASE)
                highlighted_text = mark_replacement.sub("<mark>" + word + "</mark>", highlighted_text)
        return highlighted_text

    # count number of all exact matches
    exact_matches = 0
    for obj in results_of_search:
        exact_matches += len(re.findall(piece, obj.text, re.IGNORECASE))

    for obj in results_of_search[0:1024]:
        d.append(
            {
                "pk": obj.pk,
                "translation": obj.translation,
                "book": obj.book,
                "chapter": obj.chapter,
                "verse": obj.verse,
                "text": highlight_headline(obj.text),
            }
        )
    return {"results": d, "exact_matches": exact_matches}


def search(request, translation, piece=""):
    if len(piece) == 0:
        piece = request.GET.get("search", "")
    match_case = request.GET.get("match_case", "") == "true"
    match_whole = request.GET.get("match_whole", "") == "true"
    book = request.GET.get("book", None)

    piece = piece.strip()

    if len(piece) > 2 or piece.isdigit():
        result = find(translation, piece, book, match_case, match_whole)
        return cross_origin(JsonResponse(result["results"], safe=False), headers={"Exact_matches": result["exact_matches"]})
    else:
        return cross_origin(JsonResponse([{"readme": "Your query is not longer than 2 characters! And don't forget to trim it)"}], safe=False, status=400))


def v2_search(request, translation):
    piece = request.GET.get("search", "")
    match_case = request.GET.get("match_case", "") == "true"
    match_whole = request.GET.get("match_whole", "") == "true"
    book = request.GET.get("book", None)

    piece = piece.strip()
    if len(piece) > 2 or piece.isdigit():
        result = find(translation, piece, book, match_case, match_whole)
        return cross_origin(JsonResponse(result, safe=False))
    else:
        return cross_origin(JsonResponse([{"readme": "Your query is not longer than 2 characters! And don't forget to trim it)"}], safe=False, status=400))


def clean_up_html(raw_html):
    # remove strong numbers. They are not needed in the description
    raw_html = re.sub(r"<S>(.*?)</S>", "", raw_html)
    clean_regex = re.compile("<.*?>|&([a-z0-9]+|#[0-9]{1,6}|#x[0-9a-f]{1,6});")
    clean_text = re.sub(clean_regex, "", raw_html)
    return clean_text


def get_description(verses, verse, endverse):
    if verse <= len(verses) and len(verses) > 0:
        i = 0
        description = verses[verse - 1]["text"]
        if endverse > 0 and endverse - verse != 0:
            for i in range(verse, endverse):
                if i < len(verses):
                    description += " " + verses[i]["text"]
        return clean_up_html(description)
    else:
        return "Corrupted link!"


def link_to_verse(request, translation, book, chapter, verse):
    verses = get_chapter_with_commentaries(translation, book, chapter)
    return render(
        request,
        bolls_index,
        {
            "translation": translation,
            "book": book,
            "chapter": chapter,
            "verse": verse,
            "verses": verses,
            "description": get_description(verses, verse, 0),
        },
    )


def link_to_verses(request, translation, book, chapter, verse, endverse):
    verses = get_chapter_with_commentaries(translation, book, chapter)
    return render(
        request,
        bolls_index,
        {
            "translation": translation,
            "book": book,
            "chapter": chapter,
            "verse": verse,
            "endverse": endverse,
            "verses": verses,
            "description": get_description(verses, verse, endverse),
        },
    )


def link_to_chapter(request, translation, book, chapter):
    verses = get_chapter_with_commentaries(translation, book, chapter)
    return render(
        request,
        bolls_index,
        {
            "translation": translation,
            "book": book,
            "chapter": chapter,
            "verses": verses,
            "description": get_description(verses, 1, 3),
        },
    )


def sign_up(request):
    if request.method == "POST":
        form = SignUpForm(request.POST)
        if form.is_valid():
            form.save()
            username = form.cleaned_data.get("username")
            raw_password = form.cleaned_data.get("password1")
            user = authenticate(username=username, password=raw_password)
            login(request, user)
            return redirect("index")
    else:
        form = SignUpForm()
    return render(request, "registration/signup.html", {"form": form})


def delete_my_account(request):
    message = ""
    if request.user.is_authenticated:
        try:
            request.user.delete()
            message = "account_deleted"

        except Exception as e:
            return render(
                request,
                bolls_index,
                {
                    "message": e.message,
                },
            )
    return render(
        request,
        bolls_index,
        {
            "message": message,
        },
    )


def edit_account(request):
    if request.method == "POST":
        received_json_data = json.loads(request.body)
        new_username = received_json_data["newusername"]
        newname = newname = received_json_data.get("newname", "")
        if User.objects.filter(username=new_username).exists():
            if request.user.username != new_username:
                return HttpResponse(status=409)
        user = request.user
        user.username = new_username
        user.first_name = newname
        user.save()
        return HttpResponse(status=200)
    else:
        return HttpResponse(status=405)


def get_bookmarks(request, translation, book, chapter):
    if request.user.is_authenticated:
        all_objects = Verses.objects.filter(translation=translation, book=book, chapter=chapter).order_by("verse")
        bookmarks = []
        for obj in all_objects:
            for bookmark in obj.bookmarks_set.filter(user=request.user):
                note = ""
                if bookmark.note is not None:
                    note = bookmark.note.text
                bookmarks.append(
                    {
                        "verse": bookmark.verse.pk,
                        "date": bookmark.date,
                        "color": bookmark.color,
                        "collection": bookmark.collection,
                        "note": note,
                    }
                )
        return JsonResponse(bookmarks, safe=False)
    else:
        return JsonResponse([], safe=False)


def map_bookmarks(bookmarkslist):
    bookmarks = []
    for bookmark in bookmarkslist:
        note = ""
        if bookmark.note is not None:
            note = bookmark.note.text
        bookmarks.append(
            {
                "verse": {
                    "pk": bookmark.verse.pk,
                    "translation": bookmark.verse.translation,
                    "book": bookmark.verse.book,
                    "chapter": bookmark.verse.chapter,
                    "verse": bookmark.verse.verse,
                    "text": bookmark.verse.text,
                },
                "date": bookmark.date,
                "color": bookmark.color,
                "collection": bookmark.collection,
                "note": note,
            }
        )
    return bookmarks


def get_profile_bookmarks(request, range_from, range_to):
    if request.user.is_authenticated:
        user = request.user

        translation = request.GET.get("translation", "")
        book = request.GET.get("book", None)
        filter_options = {}
        if translation:
            filter_options["verse__translation"] = translation
        if book:
            filter_options["verse__book"] = book

        bookmarks = map_bookmarks(user.bookmarks_set.filter(**filter_options).order_by("-date", "verse")[range_from:range_to])
        return JsonResponse(bookmarks, safe=False)
    return JsonResponse([], safe=False)


def search_profile_bookmarks(request, query, range_from, range_to):
    user = request.user
    bookmarks = (map_bookmarks(user.bookmarks_set.all().filter(collection__icontains=query).order_by("-date", "verse")[range_from:range_to]),)
    return JsonResponse(bookmarks, safe=False)


def get_bookmarks_with_notes(request, range_from, range_to):
    if not request.user.is_authenticated:
        return JsonResponse([], safe=False)
    user = request.user
    bookmarks = (map_bookmarks(user.bookmarks_set.all().filter(note__isnull=False).order_by("-date", "verse")[range_from:range_to]),)
    return JsonResponse(bookmarks, safe=False)


def get_categories(request):
    if request.user.is_authenticated:
        user = request.user
        all_objects = user.bookmarks_set.values("collection").annotate(dcount=Count("collection")).order_by("-date")
        fresh_collections = [b for b in all_objects]
        collections = []
        for collections_dict in fresh_collections:
            for collection in collections_dict["collection"].split(" | "):
                if collection not in collections and len(collection):
                    collections.append(collection)
        return JsonResponse({"data": collections}, safe=False)
    return JsonResponse({"data": []}, safe=False)


# Backward compatibility with the old version of the API
# For some weird reasons, before I required lists stringified separately in the body
def get_safe_array(array):
    # if array is string, convert it to array
    if isinstance(array, str):
        return json.loads(array)
    return array


@csrf_exempt
def get_parallel_verses(request):
    if request.method != "POST":
        return cross_origin(HttpResponse("The request should be POSTed", status=400))
    try:
        received_json_data = json.loads(request.body)
        if (
            received_json_data["chapter"] > 0
            and received_json_data["book"] > 0
            and len(received_json_data["translations"]) > 0
            and len(received_json_data["verses"]) > 0
        ):
            book = received_json_data["book"]
            chapter = received_json_data["chapter"]
            response = []
            query_set = []
            for translation in get_safe_array(received_json_data["translations"]):
                for verse in get_safe_array(received_json_data["verses"]):
                    query_set.append('Q(translation="' + translation + '", book=' + str(book) + ", chapter=" + str(chapter) + ", verse=" + str(verse) + ")")

            query = " | ".join(query_set)
            queryres = Verses.objects.filter(eval(query))

            for translation in get_safe_array(received_json_data["translations"]):
                verses = []
                for verse in get_safe_array(received_json_data["verses"]):
                    v = [x for x in queryres if ((x.verse == verse) & (x.translation == translation))]
                    if len(v):
                        for item in v:
                            verses.append(
                                {
                                    "pk": item.pk,
                                    "translation": item.translation,
                                    "book": item.book,
                                    "chapter": item.chapter,
                                    "verse": item.verse,
                                    "text": item.text,
                                }
                            )
                    else:
                        verses.append(
                            {
                                "translation": translation,
                            }
                        )
                response.append(verses)
            return cross_origin(JsonResponse(response, safe=False))
        else:
            return cross_origin(HttpResponse(incorrect_body, status=400))
    except:
        return cross_origin(HttpResponse("Body json is incorrect", status=400))


@csrf_exempt
def get_verses(request):
    if request.method == "POST":
        try:
            received_json_data = json.loads(request.body)
            if received_json_data:
                response = []
                query_set = []
                for text in received_json_data:
                    for verse in text["verses"]:
                        query_set.append(
                            'Q(translation="'
                            + text["translation"]
                            + '", book='
                            + str(text["book"])
                            + ", chapter="
                            + str(text["chapter"])
                            + ", verse="
                            + str(verse)
                            + ")"
                        )

                query = " | ".join(query_set)
                queryset = Verses.objects.filter(eval(query))

                for text in received_json_data:
                    verses = []
                    for verse in text["verses"]:
                        for item in queryset:
                            if (
                                item.translation == text["translation"]
                                and item.book == text["book"]
                                and item.chapter == text["chapter"]
                                and item.verse == verse
                            ):
                                verses.append(
                                    {
                                        "pk": item.pk,
                                        "translation": item.translation,
                                        "book": item.book,
                                        "chapter": item.chapter,
                                        "verse": item.verse,
                                        "text": item.text,
                                    }
                                )
                    response.append(verses)
                return cross_origin(JsonResponse(response, safe=False))
            else:
                return cross_origin(HttpResponse(incorrect_body, status=400))
        except:
            return cross_origin(HttpResponse(incorrect_body + str(request.body), status=400))
    else:
        return cross_origin(HttpResponse("The request should be POSTed", status=400))


def get_a_verse(_, translation, book, chapter, verse):
    bookid = get_book_id(translation, book)
    verses = Verses.objects.filter(book=bookid, chapter=chapter, translation=translation, verse=verse)

    result_verse = {}
    if len(verses):
        result_verse = {
            "pk": verses[0].pk,
            "verse": verses[0].verse,
            "text": verses[0].text,
        }
    else:
        return cross_origin(HttpResponse("The verse is not found", status=404))

    commentaries = Commentary.objects.filter(book=book, chapter=chapter, translation=translation, verse=verse)

    comment = ""
    for item in commentaries:
        if item.verse == result_verse["verse"]:
            if len(comment) > 0:
                comment += "<br>"
            comment += item.text
    if len(comment) > 0:
        result_verse["comment"] = comment

    return cross_origin(JsonResponse(result_verse, safe=False))


def save_bookmarks(request):
    if not request.user.is_authenticated:
        return HttpResponse(status=401)
    if request.method != "POST":
        return HttpResponse(status=405)

    received_json_data = json.loads(request.body)
    user = request.user

    def create_new_bookmark():
        note = None
        if len(received_json_data["note"]):
            note = Note.objects.create(text=received_json_data["note"])
        user.bookmarks_set.create(
            verse=verse,
            date=received_json_data["date"],
            color=received_json_data["color"],
            collection=received_json_data["collections"],
            note=note,
        )

    for verse_id in get_safe_array(received_json_data["verses"]):
        try:
            verse = Verses.objects.get(pk=verse_id)
            # If there is an existing bookmark -- update it
            try:
                obj = user.bookmarks_set.get(user=user, verse=verse)
                obj.date = received_json_data["date"]
                obj.color = received_json_data["color"]
                obj.collection = received_json_data["collections"]
                note = obj.note
                if note is not None:
                    if len(received_json_data["note"]):
                        obj.note.text = received_json_data["note"]
                        obj.note.save()
                    else:
                        obj.note.delete()
                        obj.note = None
                else:
                    if len(received_json_data["note"]):
                        note = Note.objects.create(text=received_json_data["note"])
                        obj.note = note
                        obj.note.save()
                obj.save()
            # Else create a new one
            except Bookmarks.DoesNotExist:
                create_new_bookmark()
            # If there accidentsly are a few bookmarks for a single verse -- remove them all and create a new bookmark
            except Bookmarks.MultipleObjectsReturned:
                remove_bookmarks(user, [verse_id])
                create_new_bookmark()

        except Verses.DoesNotExist:
            return HttpResponse(status=418)
    return JsonResponse({"status_code": 200}, safe=False)


def delete_bookmarks(request):
    if request.user.is_authenticated:
        received_json_data = json.loads(request.body)
        remove_bookmarks(request.user, get_safe_array(received_json_data["verses"]))
        return JsonResponse({"response": "200"}, safe=False)
    else:
        return HttpResponse(status=401)


def remove_bookmarks(user, verses):
    for verse_id in verses:
        verse = Verses.objects.get(pk=verse_id)
        user.bookmarks_set.filter(verse=verse).delete()


def get_user_history(user):
    default_response_obj = {"history": "[]", "purge_date": 0, "compare_translations": "[]", "favorite_translations": "[]"}
    if user.is_authenticated:
        try:
            obj = user.history_set.get(user=user)
            return {
                "history": obj.history,
                "purge_date": obj.purge_date,
                "compare_translations": obj.compare_translations,
                "favorite_translations": obj.favorite_translations,
            }
        except History.MultipleObjectsReturned:
            user.history_set.filter(user=user).delete()
            return default_response_obj
        except History.DoesNotExist:
            return default_response_obj
    else:
        return default_response_obj


def history(request):
    if request.user.is_authenticated:
        user = request.user

        if request.method == "PUT":
            received_json_data = json.loads(request.body)
            try:
                obj = user.history_set.get(user=user)
                obj.history = received_json_data["history"]
                obj.save()

            except History.DoesNotExist:
                user.history_set.create(history=received_json_data["history"])

            except History.MultipleObjectsReturned:
                user.history_set.all().delete()
                user.history_set.create(history=received_json_data["history"])

            return JsonResponse({"response": "200"}, safe=False)

        elif request.method == "DELETE":
            received_json_data = json.loads(request.body)
            try:
                obj = user.history_set.get(user=user)
                obj.history = received_json_data["history"]
                obj.purge_date = received_json_data["purge_date"]
                obj.save()

            except History.DoesNotExist:
                user.history_set.create(history=received_json_data["history"])

            except History.MultipleObjectsReturned:
                user.history_set.all().delete()
                user.history_set.create(history=received_json_data["history"])

            return JsonResponse({"response": "200"}, safe=False)

        else:
            return JsonResponse(get_user_history(request.user), safe=False)

    else:
        if request.method == "POST":
            return HttpResponse(status=405)
        else:
            return JsonResponse([], safe=False)


def get_user_bookmarks_map(request):
    if not request.user.is_authenticated:
        return {}

    # Filter by user and only if collection or note is not empty
    bookmarks = Bookmarks.objects.filter(user=request.user).select_related("verse")

    # Now create the next map
    # {translation: {book: {chapter: {color, color,}}}}
    result = {}
    for bookmark in bookmarks:
        translation = bookmark.verse.translation
        book = bookmark.verse.book
        chapter = bookmark.verse.chapter
        color = bookmark.color
        if translation not in result:
            result[translation] = {}
        if book not in result[translation]:
            result[translation][book] = {}
        if chapter not in result[translation][book]:
            result[translation][book][chapter] = []
        if color not in result[translation][book][chapter]:
            result[translation][book][chapter].append(color)

    return result


def get_me_if_am_logged_in(request):
    if request.user.is_authenticated:
        return JsonResponse(
            {
                "username": request.user.username,
                "name": request.user.first_name,
                "is_password_usable": is_password_usable(request.user.password),
                "bookmarksMap": get_user_bookmarks_map(request),
            },
            safe=False,
        )
    return JsonResponse({"username": ""}, safe=False)


def api(request):
    return render(request, "bolls/api.html")


def handler404(request, *args, **argv):
    response = render("404.html", {}, context_instance=RequestContext(request))
    response.status_code = 404
    return response


def handler500(request, *args, **argv):
    response = render("500.html", {}, context_instance=RequestContext(request))
    response.status_code = 500
    return response


def strip_vowels(raw_string):
    res = ""
    if len(re.findall("[α-ωΑ-Ω]", raw_string)):
        nfkd_form = unicodedata.normalize("NFKD", raw_string)
        res = "".join([c for c in nfkd_form if not unicodedata.combining(c)])

    else:
        res = re.sub(r"[\u0591-\u05C7]", "", raw_string)

        # Replace some letters, which are not present in a given unicode range, manually.
        res = res.replace("שׁ", "ש")
        res = res.replace("שׂ", "ש")
        res = res.replace("ץ", "צ")
        res = res.replace("ם", "מ")
        res = res.replace("ן", "נ")
        res = res.replace("ך", "כ")
        res = res.replace("ף", "פ")

    res = res.replace("‎", "")
    return res


# Parse Bible links
def parse_links(text, translation):
    if isinstance(text, float):
        return ""

    text = re.sub(r"(<[/]?span[^>]*)>", "", text)  # Clean up unneeded spans
    # Avoid unneded classes on anchors
    text = re.sub(r"( class=\'\w+\')", "", text)

    pieces = text.split("'")

    result = ""
    for piece in pieces:
        if piece.startswith("B:"):
            result += "'https://bolls.life/" + translation + "/"
            digits = re.findall(r"\d+", piece)
            try:
                result += str(books_map[(digits[0])]) + "/" + digits[1] + "/" + digits[2]
            except:
                print(piece)

            if len(digits) > 3:
                result += "-" + digits[3]
            result += "' target='_blank'"
        else:
            result += piece
    return result


def dictionary_search(request, dict, query):
    query = query.strip()
    unaccented_query = strip_vowels(query.lower())

    similarity_rank = 0.5
    if request.GET.get("extended", False):
        similarity_rank = 0.3

    # Rank search
    search_vector = SearchVector("lexeme__unaccent")
    search_query = SearchQuery(unaccented_query)
    results_of_rank = (
        Dictionary.objects.annotate(rank=SearchRank(search_vector, search_query))
        .filter(
            Q(short_definition__search=unaccented_query) | Q(topic=query.upper()) | Q(rank__gt=0),
            dictionary=dict,
        )
        .order_by("-rank")
    )

    # SImilarity search
    results_of_similarity = (
        Dictionary.objects.annotate(rank=TrigramWordSimilarity(unaccented_query, "lexeme__unaccent"))
        .filter(dictionary=dict, rank__gt=similarity_rank)
        .order_by("-rank")
    )

    # Merge both kinds of search
    results_of_search = list(results_of_similarity) + list(set(results_of_rank) - set(results_of_similarity))
    results_of_search.sort(key=lambda verse: verse.rank, reverse=True)

    # for farther refactoring of inner Bible links
    translation = ""
    if dict == "RUSD":
        translation = "international/SYNOD"
    else:
        translation = "international/KJV"

    # Serialize final data
    d = []
    for result in results_of_search:
        serialized_result = {
            "topic": result.topic,
            "definition": parse_links(result.definition, translation),
            "lexeme": result.lexeme,
            "transliteration": result.transliteration,
            "pronunciation": result.pronunciation,
            "weight": result.rank,
        }
        if result.short_definition:
            serialized_result["short_definition"] = result.short_definition

        d.append(serialized_result)
    return cross_origin(JsonResponse(d, safe=False))


def get_dictionary(_, dictionary):
    definitions = Dictionary.objects.annotate(unaccented_lexeme=Func(F("lexeme"), function="unaccent")).filter(dictionary=dictionary)

    d = []
    for definition in definitions:
        serialized_definition = {
            "topic": definition.topic,
            "definition": definition.definition,
        }
        if definition.lexeme:
            serialized_definition["lexeme"] = definition.lexeme
        if definition.transliteration:
            serialized_definition["transliteration"] = definition.transliteration
        if definition.pronunciation:
            serialized_definition["pronunciation"] = definition.pronunciation
        if definition.short_definition:
            serialized_definition["short_definition"] = definition.short_definition
        d.append(serialized_definition)

    return cross_origin(JsonResponse(d, safe=False))


def get_books(_, translation):
    try:
        return cross_origin(JsonResponse(BOOKS[translation], safe=False))
    except:
        return cross_origin(HttpResponse("There is no such translation: " + translation, status=404))


def download_notes(request):
    if request.user.is_authenticated:
        bookmarks = Bookmarks.objects.filter(user=request.user)
        response = HttpResponse(content_type="text/json")
        response["Content-Disposition"] = 'attachment; filename="notes.json"'
        data = []
        for bookmark in bookmarks:
            data.append(
                {
                    "verse": bookmark.verse.pk,
                    "date": bookmark.date,
                    "color": bookmark.color,
                    "collection": bookmark.collection,
                    "note": bookmark.note.text if bookmark.note else "",
                }
            )
        response.write(json.dumps(data))
        return response
    else:
        return HttpResponse(status=401)


def import_notes(request):
    if request.method == "POST" and request.user.is_authenticated:
        received_json_data = json.loads(request.body)
        existing_bookmarks = request.user.bookmarks_set.all()

        for item in received_json_data["data"]:
            existing_bookmark_set = existing_bookmarks.filter(verse=item["verse"])
            if len(existing_bookmark_set) > 0:
                if received_json_data["merge_replace"] == "true":
                    existing_bookmark = existing_bookmark_set[0]
                    if existing_bookmark.note is not None:
                        if len(item["note"]):
                            existing_bookmark.note.text = item["note"]
                            existing_bookmark.note.save()
                        else:
                            existing_bookmark.note.delete()
                            existing_bookmark.note = None
                    else:
                        if len(item["note"]):
                            note = Note.objects.create(text=item["note"])
                            existing_bookmark.note = note

                    existing_bookmark.color = item["color"]
                    existing_bookmark.date = item["date"]
                    existing_bookmark.collections = item["collection"]
                    existing_bookmark.save()
            else:
                note = None
                if len(item["note"]):
                    note = Note.objects.create(text=item["note"])
                request.user.bookmarks_set.create(
                    verse=Verses.objects.get(id=item["verse"]),
                    date=item["date"],
                    color=item["color"],
                    collection=item["collection"],
                    note=note,
                )
        return HttpResponse(status=200)
    else:
        return HttpResponse(status=405)


def sw(_):
    # return HttpResponse(status=404) # for dev only
    # get the file for the service worker
    sw_file = open(os.path.join(BASE_DIR, "bolls/static/service-worker.js"), "r")
    sw_content = sw_file.read()
    sw_file.close()
    # and sent it to the client
    return HttpResponse(sw_content, content_type="application/javascript")


def save_compare_translations(request):
    if request.method == "PUT" and request.user.is_authenticated:
        received_json_data = json.loads(request.body)
        user = request.user
        try:
            history = user.history_set.get(user=user)
            history.compare_translations = received_json_data["translations"]
            history.save()

        except History.DoesNotExist:
            user.history_set.create(history="[]", compare_translations=received_json_data["translations"])

        except History.MultipleObjectsReturned:
            user.history_set.all().delete()
            user.history_set.create(history="[]", compare_translations=received_json_data["translations"])
        return HttpResponse(status=200)
    else:
        return HttpResponse(status=405)


def save_favorite_translations(request):
    if request.method == "PUT" and request.user.is_authenticated:
        received_json_data = json.loads(request.body)
        user = request.user
        try:
            history = user.history_set.get(user=user)
            history.favorite_translations = received_json_data["translations"]
            history.save()

        except History.DoesNotExist:
            user.history_set.create(history="[]", favorite_translations=received_json_data["translations"])

        except History.MultipleObjectsReturned:
            user.history_set.all().delete()
            user.history_set.create(history="[]", favorite_translations=received_json_data["translations"])
        return HttpResponse(status=200)
    else:
        return HttpResponse(status=405)


def get_verse_counts(_, translation):
    try:
        verses = Verses.objects.filter(translation=translation)
        verses_coun_map = {}
        for verse in verses:
            if verse.book not in verses_coun_map:
                verses_coun_map[verse.book] = {}
            if verse.chapter not in verses_coun_map[verse.book]:
                verses_coun_map[verse.book][verse.chapter] = 0
            verses_coun_map[verse.book][verse.chapter] += 1
        return cross_origin(JsonResponse(verses_coun_map, safe=False))
    except:
        return HttpResponse(status=400, content="Translation is not found")


def get_random_verse(_, translation):
    try:
        verse = Verses.objects.filter(translation=translation).order_by("?").first()
        return cross_origin(
            JsonResponse(
                {
                    "pk": verse.pk,
                    "translation": verse.translation,
                    "book": verse.book,
                    "chapter": verse.chapter,
                    "verse": verse.verse,
                    "text": verse.text,
                },
                safe=False,
            )
        )
    except Exception as error:
        print(error)
        return HttpResponse(status=400, content="Translation is not found")
