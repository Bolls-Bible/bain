import os
import ast
import math
import json
from django.db.models import Count, Q
from django.contrib.postgres.search import SearchQuery, SearchRank, SearchVector, TrigramSimilarity
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.hashers import is_password_usable
from django.contrib.auth.models import User
from django.contrib.auth import login, authenticate
from django.contrib.messages import get_messages
from django.shortcuts import render, redirect
from django.template import RequestContext
from django.http import JsonResponse, HttpResponse

from bolls.forms import SignUpForm

from .models import Verses, Bookmarks, History, Note

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def index(request):
    return render(request, 'bolls/index.html')


def getTranslation(request, translation):
    all_objects = Verses.objects.filter(
        translation=translation).order_by('book', 'chapter', 'verse')
    d = []
    for obj in all_objects:
        d.append({
            "pk": obj.pk,
            "translation": obj.translation,
            "book": obj.book,
            "chapter": obj.chapter,
            "verse": obj.verse,
            "text": obj.text
        })
    response = JsonResponse(d, safe=False)
    response["Access-Control-Allow-Origin"] = "*"
    response["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    response["Access-Control-Max-Age"] = "1000"
    response["Access-Control-Allow-Headers"] = "X-Requested-With, Content-Type"
    return response


def getChapter(translation, book, chapter):
    all_objects = Verses.objects.filter(
        book=book, chapter=chapter, translation=translation).order_by('verse')
    d = []
    for obj in all_objects:
        d.append({
            "pk": obj.pk,
            "verse": obj.verse,
            "text": obj.text
        })
    return d


def getText(request, translation, book, chapter):
    response = JsonResponse(getChapter(translation, book, chapter), safe=False)
    response["Access-Control-Allow-Origin"] = "*"
    response["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    response["Access-Control-Max-Age"] = "1000"
    response["Access-Control-Allow-Headers"] = "X-Requested-With, Content-Type"
    return response


def search(request, translation, piece):
    results_of_exec_search = []
    piece = piece.strip()
    if len(piece) > 2:
        query_set = []

        for word in piece.split():
            query_set.append("Q(translation=\"" + translation + "\", text__icontains=\"" + word + "\")")

        query = ' & '.join(query_set)
        queryres = Verses.objects.filter(eval(query))

        results_of_exec_search = Verses.objects.filter(eval(query)).order_by('book', 'chapter', 'verse')


        if len(results_of_exec_search) < 256:
            rank_threshold = 1 - math.exp(-0.003 * (len(piece) + 2) ** (2))

            vector = SearchVector('text')
            query = SearchQuery(piece)
            results_of_rank = Verses.objects.annotate(rank=SearchRank(
                vector, query)).filter(translation=translation, rank__gt=(rank_threshold * 0.5)).order_by('-rank')

            results_of_similarity = Verses.objects.annotate(rank=TrigramSimilarity(
                'text', piece)).filter(translation=translation, rank__gt=rank_threshold).order_by('-rank')
            results_of_search = list(results_of_similarity) + \
                list(set(results_of_rank) - set(results_of_similarity))

            results_of_search.sort(key=lambda verse: verse.rank, reverse=True)

            if len(results_of_exec_search) > 0:
                results_of_search = list(results_of_exec_search) + \
                    list(set(results_of_search) - set(results_of_exec_search))
        else:
            results_of_search = results_of_exec_search
    else:
        results_of_search = [
            {
                "pk": -1,
                "translation": translation,
                "book": 'BOOKLESS',
                "chapter": 'NO RESULTS',
                "verse": "WHY?",
                "text": "Because your query is not longer than 2 characters! And don't forget to trim it)"
            }
        ]


    d = []
    for obj in results_of_search:
        d.append({
            "pk": obj.pk,
            "translation": obj.translation,
            "book": obj.book,
            "chapter": obj.chapter,
            "verse": obj.verse,
            "text": obj.text
        })
    response = JsonResponse(d, safe=False)
    response["Access-Control-Allow-Origin"] = "*"
    response["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    response["Access-Control-Max-Age"] = "1000"
    response["Access-Control-Allow-Headers"] = "X-Requested-With, Content-Type"
    return response


def getDescription(verses, verse, endverse):
    if verse <= len(verses) and len(verses) > 0:
        i = 0
        description = verses[verse - 1]['text']
        if endverse > 0 and endverse - verse != 0:
            for i in range(verse, endverse):
                if i < len(verses):
                    description += ' ' + verses[i]['text']
        return description
    else:
        return 'Corrupted link!'


def linkToVerse(request, translation, book, chapter, verse):
    verses = getChapter(translation, book, chapter)
    return render(request, 'bolls/index.html', {"translation": translation, "book": book, "chapter": chapter, "verse": verse, "verses": verses, "description": getDescription(verses, verse, 0)})


def linkToVerses(request, translation, book, chapter, verse, endverse):
    verses = getChapter(translation, book, chapter)
    return render(request, 'bolls/index.html', {"translation": translation, "book": book, "chapter": chapter, "verse": verse, "endverse": endverse, "verses": verses, "description": getDescription(verses, verse, endverse)})


def linkToChapter(request, translation, book, chapter):
    verses = getChapter(translation, book, chapter)
    return render(request, 'bolls/index.html', {"translation": translation, "book": book, "chapter": chapter, "verses": verses, "description": getDescription(verses, 0, 3)})


def signUp(request):
    if request.method == 'POST':
        form = SignUpForm(request.POST)
        if form.is_valid():
            form.save()
            username = form.cleaned_data.get('username')
            raw_password = form.cleaned_data.get('password1')
            user = authenticate(username=username, password=raw_password)
            login(request, user)
            return redirect('index')
    else:
        form = SignUpForm()
    return render(request, 'registration/signup.html', {'form': form})


def deleteAccount(request):
    message = ''
    if request.user.is_authenticated:
        try:
            request.user.delete()
            message = "account_deleted"

        except Exception as e:
            return render(request, 'bolls/index.html', {'message': e.message})
    print(message)
    return render(request, 'bolls/index.html', {"message": message})


def editAccount(request):
    if request.method == 'POST':
        received_json_data = json.loads(request.body)
        newusername = received_json_data["newusername"]
        newname = newname = received_json_data.get("newname", '')
        if User.objects.filter(username=newusername).exists():
            if request.user.username != newusername:
                return HttpResponse(status=409)
        user = request.user
        user.username = newusername
        user.first_name = newname
        user.save()
        return HttpResponse(status=200)
    else:
        return HttpResponse(status=405)


def getBookmarks(request, translation, book, chapter):
    if request.user.is_authenticated:
        all_objects = Verses.objects.filter(
            book=book, chapter=chapter, translation=translation).order_by('verse')
        bookmarks = []
        for obj in all_objects:
            if list(obj.bookmarks_set.all().filter(user=request.user)):
                for bookmark in obj.bookmarks_set.all():
                    note = ''
                    if bookmark.note is not None:
                        note = bookmark.note.text
                    bookmarks.append({
                        "verse": bookmark.verse.pk,
                        "date": bookmark.date,
                        "color": bookmark.color,
                        "collection": bookmark.collection,
                        "note": note,
                    })
        return JsonResponse(bookmarks, safe=False)
    else:
        return JsonResponse([], safe=False)


def getProfileBookmarks(request, range_from, range_to):
    if request.user.is_authenticated:
        user = request.user
        bookmarks = []
        bookmarkslist = user.bookmarks_set.all().order_by(
            '-date', 'verse')[range_from:range_to]
        for bookmark in bookmarkslist:
            note = ''
            if bookmark.note is not None:
                note = bookmark.note.text
            bookmarks.append({
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
            })

        return JsonResponse(bookmarks, safe=False)
    return JsonResponse([], safe=False)


def getSearchedProfileBookmarks(request, query):
    user = request.user
    bookmarks = []
    for bookmark in user.bookmarks_set.all().filter(collection__icontains=query).order_by('-date', 'verse'):
        bookmarks.append({
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
        })
    return JsonResponse(bookmarks, safe=False)


def getCategories(request):
    if request.user.is_authenticated:
        user = request.user
        all_objects = user.bookmarks_set.values('collection').annotate(
            dcount=Count('collection')).order_by('-date')
        fresh_collections = [b for b in all_objects]
        collections = []
        for collections_dict in fresh_collections:
            for collection in collections_dict['collection'].split(' | '):
                if not collection in collections and len(collection):
                    collections.append(collection)
        return JsonResponse({"data": collections}, safe=False)
    return JsonResponse({"data": []}, safe=False)


@csrf_exempt
def getParallelVerses(request):
    if request.method == 'POST':
        received_json_data = json.loads(request.body)
        if received_json_data["chapter"] > 0 and received_json_data["book"] > 0 and len(received_json_data["translations"]) > 5 and len(received_json_data["verses"]) > 2:
            book = received_json_data["book"]
            chapter = received_json_data["chapter"]
            response = []
            query_set = []
            for translation in ast.literal_eval(received_json_data["translations"]):
                for verse in ast.literal_eval(received_json_data["verses"]):
                    query_set.append("Q(translation=\"" + translation + "\", book=" + str(
                        book) + ", chapter=" + str(chapter) + ", verse=" + str(verse) + ")")

            query = ' | '.join(query_set)
            queryres = Verses.objects.filter(eval(query))

            for translation in ast.literal_eval(received_json_data["translations"]):
                verses = []
                for verse in ast.literal_eval(received_json_data["verses"]):
                    v = [x for x in queryres if (
                        (x.verse == verse) & (x.translation == translation))]
                    if len(v):
                        for item in v:
                            verses.append({
                                "pk": item.pk,
                                "translation": item.translation,
                                "book": item.book,
                                "chapter": item.chapter,
                                "verse": item.verse,
                                "text": item.text,
                            })
                    else:
                        verses.append({
                            "translation": translation,
                        })
                response.append(verses)
            return JsonResponse(response, safe=False)
        else:
            return HttpResponse(status=400)
    else:
        return HttpResponse(status=400)


def saveBookmarks(request):
    if request.user.is_authenticated:
        received_json_data = json.loads(request.body)
        user = request.user

        def createNewBookmark():
            note = None
            if len(received_json_data["note"]):
                note = Note.objects.create(text=received_json_data["note"])
            user.bookmarks_set.create(
                verse=verse, date=received_json_data["date"], color=received_json_data["color"], collection=received_json_data["collections"], note=note)

        for verseid in ast.literal_eval(received_json_data["verses"]):
            verse = Verses.objects.get(pk=verseid)
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
                        note = Note.objects.create(
                            text=received_json_data["note"])
                        obj.note = note
                        obj.note.save()
                obj.save()
            except Bookmarks.DoesNotExist:
                createNewBookmark()
            except Bookmarks.MultipleObjectsReturned:
                deleteBookmarks(request)
                createNewBookmark()
    return JsonResponse({"response": "200"}, safe=False)


def saveHistory(request):
    if request.user.is_authenticated:
        received_json_data = json.loads(request.body)
        user = request.user
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
    else:
        return JsonResponse({"response": "200"}, safe=False)


def deleteBookmarks(request):
    received_json_data = json.loads(request.body)
    user = request.user
    for verseid in ast.literal_eval(received_json_data["verses"]):
        verse = Verses.objects.get(pk=verseid)
        user.bookmarks_set.filter(verse=verse).delete()
    return JsonResponse({"response": "200"}, safe=False)


def historyOf(user):
    if user.is_authenticated:
        try:
            obj = user.history_set.get(user=user)
            return obj.history
        except History.DoesNotExist:
            return []
    else:
        return []


def userLogged(request):
    if request.user.is_authenticated:
        return JsonResponse({"username": request.user.username, "name": request.user.first_name, "is_password_usable": is_password_usable(request.user.password), "history": historyOf(request.user)}, safe=False)
    return JsonResponse({"username": ""}, safe=False)


def robots(request):
    filename = "robots.txt"
    content = "User-agent: *\nDisallow: /admin/\nAllow: /\nSitemap: http://bolls.life/static/all_chapters.xml"
    response = HttpResponse(content, content_type='text/plain')
    response['Content-Disposition'] = 'attachment; filename={0}'.format(
        filename)
    return response


def api(request):
    return render(request, 'bolls/api.html')


def sw(request):
    # sw_file = open(BASE_DIR + '/bolls/static/bolls/dist/sw.js', 'rb')
    sw_file = open(BASE_DIR + '/static/bolls/dist/sw.js', 'rb')
    response = HttpResponse(content=sw_file)
    response['Content-Type'] = 'application/javascript'
    response['Content-Disposition'] = 'attachment; filename="%s.js"' % 'sw'
    return response


def handler404(request, *args, **argv):
    response = render('404.html', {}, context_instance=RequestContext(request))
    response.status_code = 404
    return response


def handler500(request, *args, **argv):
    response = render('500.html', {}, context_instance=RequestContext(request))
    response.status_code = 500
    return response
