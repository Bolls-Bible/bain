import os
import ast
import math
import json
from django.db.models import Count, Q
from django.contrib.postgres.search import SearchQuery, SearchRank, SearchVector, TrigramSimilarity
from django.contrib.auth import login, authenticate
from django.shortcuts import render, redirect
from django.http import JsonResponse, HttpResponse
from bolls.forms import SignUpForm
from .models import Verses, Bookmarks, History
from django.template import RequestContext
from django.views.decorators.csrf import csrf_exempt

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
	if len(piece) > 2:
		results_of_exec_search = Verses.objects.filter(
			translation=translation, text__icontains=piece).order_by('book', 'chapter', 'verse')

	if len(results_of_exec_search) < 256:
		rank_threshold = 1 - math.exp(-0.001 * (len(piece) + 2) ** (2))

		vector = SearchVector('text')
		query = SearchQuery(piece)
		results_of_rank = Verses.objects.annotate(rank=SearchRank(
			vector, query)).filter(translation=translation, rank__gt=(rank_threshold*0.5)).order_by('-rank')

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


def linkToVerse(request, translation, book, chapter, verse):
	return render(request, 'bolls/index.html', {"translation": translation, "book": book, "chapter": chapter, "verse": verse, "verses": json.dumps(getChapter(translation, book, chapter))})


def linkToChapter(request, translation, book, chapter):
	return render(request, 'bolls/index.html', {"translation": translation, "book": book, "chapter": chapter, "verses": json.dumps(getChapter(translation, book, chapter))})


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


def getBookmarks(request, translation, book, chapter):
	if request.user.is_authenticated:
		all_objects = Verses.objects.filter(
			book=book, chapter=chapter, translation=translation).order_by('verse')
		bookmarks = []
		for obj in all_objects:
			if list(obj.bookmarks_set.all().filter(user=request.user)):
				for bookmark in obj.bookmarks_set.all():
					bookmarks.append({
						"verse": bookmark.verse.pk,
						"date": bookmark.date,
						"color": bookmark.color,
						"note": bookmark.note,
					})
		return JsonResponse(bookmarks, safe=False)
	else:
		return JsonResponse([], safe=False)


def getProfileBookmarks(request, range_from, range_to):
	user = request.user
	bookmarks = []
	bookmarkslist = user.bookmarks_set.all().order_by(
		'-date', 'verse')[range_from:range_to]
	for bookmark in bookmarkslist:
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
			"note": bookmark.note,
		})

	return JsonResponse(bookmarks, safe=False)


def getSearchedProfileBookmarks(request, query):
	user = request.user
	bookmarks = []
	for bookmark in user.bookmarks_set.all().filter(note__icontains=query).order_by('-date', 'verse'):
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
			"note": bookmark.note,
		})
	return JsonResponse(bookmarks, safe=False)


def getCategories(request):
	user = request.user
	all_objects = user.bookmarks_set.values('note').annotate(
		dcount=Count('note')).order_by('-date')
	return JsonResponse({"data": [b for b in all_objects]}, safe=False)

@csrf_exempt
def getParallelVerses(request):
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


def saveBookmarks(request):
	if request.user.is_authenticated:
		received_json_data = json.loads(request.body)
		user = request.user
		for verseid in ast.literal_eval(received_json_data["verses"]):
			verse = Verses.objects.get(pk=verseid)
			try:
				obj = user.bookmarks_set.get(user=user, verse=verse)
				obj.date = received_json_data["date"]
				obj.color = received_json_data["color"]
				obj.note = received_json_data["notes"]
				obj.save()
			except Bookmarks.DoesNotExist:
				user.bookmarks_set.create(
					verse=verse, date=received_json_data["date"], color=received_json_data["color"], note=received_json_data["notes"])
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


def getHistory(request):
	return JsonResponse({"history": historyOf(request.user)}, safe=False)


def userLogged(request):
	return JsonResponse({"username": request.user.username, "history": historyOf(request.user)}, safe=False)


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
	BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
	# sw_file = open(BASE_DIR + '/bolls/static/bolls/dist/sw.js', 'rb')
	sw_file = open(BASE_DIR + '/static/bolls/dist/sw.js', 'rb')
	response = HttpResponse(content=sw_file)
	response['Content-Type'] = 'application/javascript'
	response['Content-Disposition'] = 'attachment; filename="%s.js"' \
		% 'sw'
	return response


def handler404(request, *args, **argv):
	response = render('404.html', {}, context_instance=RequestContext(request))
	response.status_code = 404
	return response


def handler500(request, *args, **argv):
	response = render('500.html', {}, context_instance=RequestContext(request))
	response.status_code = 500
	return response
