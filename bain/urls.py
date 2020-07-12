from django.contrib import admin
from django.urls import include, path
from django.views.generic.base import RedirectView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/', include('django.contrib.auth.urls')),
    path('', include('bolls.urls')),
    path('favicon.ico', RedirectView.as_view(url='/static/favicon.ico', permanent=True))
]
