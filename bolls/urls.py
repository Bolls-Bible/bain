from django.urls import path
from . import views
from django.conf.urls import handler404, handler500, include

urlpatterns = [
	path('', include('social_django.urls', namespace='social')),
	path('', views.index, name="index"),
	# path('robots.txt', views.robots),
	path('signup/', views.signUp, name="signup"),
	path('api/', views.api),
	# path('sw.js', views.sw),
	path('profile/', views.index),
	path('downloads/', views.index),
	path('save-history/', views.saveHistory),
	path('get-categories/', views.getCategories),
	path('save-bookmarks/', views.saveBookmarks),
	path('delete-bookmarks/', views.deleteBookmarks),
	path('edit-account/', views.editAccount),
	path('delete-my-account/', views.deleteAccount),
	path('user-logged/', views.userLogged),

	path('get-translation/<slug:translation>/',
		views.getTranslation),
	path('get-paralel-verses/', views.getParallelVerses),
	path('get-searched-bookmarks/<str:query>/<int:range_from>/<int:range_to>/',
		views.getSearchedProfileBookmarks),
	path('get-notes-bookmarks/<int:range_from>/<int:range_to>/',
		views.getBookmarksWithNotes),
	path('search/<slug:translation>/<str:piece>/', views.search),

	# AAA
	path('<slug:translation>/<str:piece>/', views.search),
	path('get-text/<slug:translation>/<int:book>/<int:chapter>/',
		views.getText),
	path('get-bookmarks/<slug:translation>/<int:book>/<int:chapter>/',
		views.getBookmarks),
	path('get-profile-bookmarks/<int:range_from>/<int:range_to>/',
		views.getProfileBookmarks),

	path('<slug:translation>/<int:book>/<int:chapter>/',
		views.linkToChapter),
	path('<slug:translation>/<int:book>/<int:chapter>/<int:verse>/',
		views.linkToVerse),
	path('<slug:translation>/<int:book>/<int:chapter>/<int:verse>-<int:endverse>/',
		views.linkToVerses),
	path('international/<slug:translation>/<int:book>/<int:chapter>/<int:verse>/',
		views.linkToVerse),

	path('international/<slug:translation>/<int:book>/<int:chapter>/<int:verse>-<int:endverse>/',
		views.linkToVerses),
	# path('/fixBookmarks/', views.fixBookmarks)
]

handler404 = views.handler404
handler500 = views.handler500
