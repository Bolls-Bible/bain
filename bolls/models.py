from django.db import models
from django.contrib.auth.models import User

class Verses(models.Model):
	translation = models.CharField(max_length=120)
	book = models.PositiveSmallIntegerField()
	chapter = models.PositiveSmallIntegerField()
	verse = models.PositiveSmallIntegerField()
	text = models.TextField()
	def natural_key(self):
		return (self.translation, self.book, self.chapter, self.verse, self.text)

class Bookmarks(models.Model):
	verse = models.ForeignKey(Verses, on_delete=models.CASCADE)
	user = models.ForeignKey(User, on_delete=models.CASCADE)
	date = models.BigIntegerField()
	color = models.CharField(max_length=32)
	note = models.TextField(default=None)

class History(models.Model):
	user = models.ForeignKey(User, on_delete=models.CASCADE)
	history = models.TextField(default=None)