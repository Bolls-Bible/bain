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

class Commentary(models.Model):
	translation = models.CharField(max_length=120)
	book = models.PositiveSmallIntegerField()
	chapter = models.PositiveSmallIntegerField()
	verse = models.PositiveSmallIntegerField()
	text = models.TextField()


class Note(models.Model):
	text = models.TextField()


class Bookmarks(models.Model):
	verse = models.ForeignKey(Verses, on_delete=models.CASCADE)
	user = models.ForeignKey(User, on_delete=models.CASCADE)
	date = models.BigIntegerField()
	color = models.CharField(max_length=32)
	collection = models.TextField(default=None)
	note = models.ForeignKey(Note, on_delete=models.CASCADE, null=True)


class History(models.Model):
	user = models.ForeignKey(User, on_delete=models.CASCADE)
	history = models.TextField(default=None)
